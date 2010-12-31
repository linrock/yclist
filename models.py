from datetime import datetime, timedelta
import urlparse
import locale
import os
import re

from elixir import *
import mechanize
import urllib2

from radiant.tools import wash_url
from radiant.browser import Browser
from radiant.interfaces.alexa import get_alexa_rank
from radiant.interfaces.pagerank import get_pagerank

locale.setlocale(locale.LC_ALL, '')

favicon_dir = 'data/favicons'
valid_filetypes = [
    'image/vnd.microsoft.icon',
    'image/x-icon',
    'image/png',
    'image/gif',
    'application/octet-stream'
]


class Company(Entity):
    using_options(tablename='companies')
    using_table_options(useexisting=True)

    has_field('id',                 Integer, primary_key=True)
    # has_field('name',               String(32), unique=True)
    has_field('name',               String(32))
    has_field('class_year',         Date)
    has_field('hostname',           String(128))
    has_field('url',                String(128))
    has_field('dead',               Boolean)
    has_field('exited',             Boolean)
    has_field('aq_price',           Integer)
    has_field('notes',              Text)
    has_field('data_checked_at',    DateTime)
    has_field('favicon_url',        String(128))
    has_field('favicon_filename',   String(128))
    has_field('title',              String(128))
    has_field('meta_desc',          String(128))
    has_field('pagerank',           Integer)
    has_field('alexa',              Integer)
    has_field('stats_checked_at',   DateTime)

    def _update_alexa(self):
        try:
            if self.url:
                alexa = get_alexa_rank(self.url.replace('https://', 'http://'))
                print '%s - Alexa: %s' % (self.url, alexa)
                self.alexa = alexa
            else:
                print '%s has invalid URL!' % self.name
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            print '%s fucked up!!!' % self.url

    def _update_pagerank(self):
        try:
            if self.url:
                pr = get_pagerank(self.url)
                print '%s PR: %s' % (self.url, pr)
                self.pagerank = pr
            else:
                print '%s has invalid URL!' % self.name
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            print '%s fucked up!!!' % self.url

    @staticmethod
    def scrape_all():
        b = Browser()
        for company in Company.query.filter(Company.url > '').filter(Company.dead == False):
            print 'Checking: %s' % company.url
            try:
                url = 'http://www.%s' % company.hostname
                print 'Checking: %s' % url
                b.open(url)
            except mechanize.URLError:
                print '%s appears dead' % company.url
                continue
            current_url = b.geturl()
            split_url = urlparse.urlsplit(current_url)
            print 'Current URL: %s' % current_url
            if urlparse.urlsplit(company.url).netloc.replace('www.','') in current_url:
                company.url = split_url.scheme + '://' + split_url.netloc
            title = b.parser.xpath('//title/text()')
            if title:
                company.title = title[0]
            meta_desc = b.parser.xpath('//meta[@name="description"]/@content')
            if meta_desc:
                company.meta_desc = meta_desc[0]
            favicon_url = b.parser.xpath('//link[contains(@rel, "icon") or contains(@rel, "Icon")]/@href')
            if not favicon_url:
                favicon_url = wash_url(current_url) + '/favicon.ico'
            elif favicon_url:
                new_base_url = split_url.scheme + '://' + split_url.netloc
                favicon_url = favicon_url[0]
                if favicon_url[0] == '/':
                    favicon_url = new_base_url + favicon_url
                elif not re.match('^https?://', favicon_url):
                    favicon_url = new_base_url + '/' + favicon_url
                else:
                    favicon_url = favicon_url
            try:
                response = urllib2.urlopen(favicon_url)
                # if any(i in response.headers.getheader('content-type') for i in ['image/x-icon', 'image/png']):
                favicon_filename = '%s.ico' % urlparse.urlsplit(company.url).netloc
                open(os.path.join(favicon_dir, favicon_filename), 'w').write(response.read())
            except urllib2.HTTPError:
                print '404 - %s' % favicon_url
            except urllib2.URLError:
                print 'URLError - %s' % favicon_url
            except TypeError:
                print 'TypeError WTF - %s' % favicon_url
            else:
                company.favicon_filename = favicon_filename
                company.favicon_url = favicon_url
            session.commit()

    @staticmethod
    def update_all_stats():
        companies = Company.query.filter(Company.url > '').filter(Company.dead == False)
        for company in companies:
            if not company.stats_checked_at or company.stats_checked_at < datetime.now()-timedelta(days=1):
                company._update_pagerank()
                company._update_alexa()
                company.stats_checked_at = datetime.now()
                session.commit()

    @staticmethod
    def convert_and_merge_favicons():
        icon_names = [f for f in os.listdir('icons') if f.endswith('.ico')]
        for name in icon_names:
            old_icon = os.path.join(favicon_dir, name)
            new_icon = os.path.join(favicon_dir, '%s.png' % name[:-4])
            os.system('convert %s[0] -resize 16x16 -flatten %s' % (old_icon, new_icon))
        companies = Company.query.all()
        favicon_sequence = []
        num_valid = 0
        for company in companies:
            host = urlparse.urlsplit(company.url).netloc
            path = os.path.join(favicon_dir, '%s.png' % host)
            if os.path.isfile(path):
                favicon_sequence.append(path)
                num_valid += 1
            else:
                print '%s favicon invalid: %s' % (company.url, path)
                favicon_sequence.append('public/img/blank.png')
        print '#valid: %d' % num_valid
        os.system('convert %s +append public/img/favicons.png' % ' '.join(favicon_sequence))

    def formatted_date(self):
        return self.class_year.strftime('%Y/%m') if self.class_year else ''

    def formatted_aq_price(self):
        return locale.currency(int(self.aq_price), grouping=True)[:-3] if self.aq_price else ''


metadata.bind = 'sqlite:///data.sqlite'
metadata.bind.echo = False
setup_all(True)
