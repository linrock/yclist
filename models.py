from elixir import *
import mechanize
import urllib2

from radiant.tools import wash_url
from radiant.browser import Browser
from radiant.interfaces.alexa import get_alexa_rank
from radiant.interfaces.pagerank import get_pagerank

import urlparse
import locale
import os
import re


locale.setlocale(locale.LC_ALL, '')

class Company(Entity):
    using_table_options(useexisting=True)
    using_options(tablename='companies')

    has_field('name',           String(32), index=True)
    has_field('class_year',     Date)
    has_field('hostname',       String(128))
    has_field('url',            String(128))
    has_field('favicon_url',    String(128))
    has_field('title',          String(128))
    has_field('meta_desc',      String(128))
    has_field('pagerank',       Integer)
    has_field('alexa',          Integer)
    has_field('dead',           Boolean)
    has_field('exited',         Boolean)
    has_field('aq_price',       Integer)

    @staticmethod
    def scrape_all():
        b = Browser()
        for company in Company.query.filter(Company.url > '').filter(Company.dead == False):
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
                open('icons/%s.ico' % urlparse.urlsplit(company.url).netloc, 'w').write(response.read())
            except urllib2.HTTPError:
                print '404 - %s' % favicon_url
            except urllib2.URLError:
                print 'URLError - %s' % favicon_url
            except TypeError:
                print 'TypeError WTF - %s' % favicon_url
            else:
                company.favicon_url = favicon_url
            session.commit()

    @staticmethod
    def update_all_stats():
        companies = Company.query.filter(Company.url > '').filter(Company.dead == False)
        for company in companies:
            company.update_pagerank()
            company.update_alexa()
            session.commit()

    @staticmethod
    def convert_and_merge_favicons():
        icon_names = [f for f in os.listdir('icons') if f.endswith('.ico')]
        for i in icon_names:
            old_icon = 'icons/%s' % i
            new_icon = 'icons/%s.png' % i[:-4]
            os.system('convert %s[0] -resize 16x16 -flatten %s' % (old_icon, new_icon))
        companies = Company.query.all()
        favicon_sequence = []
        num_valid = 0
        for company in companies:
            host = urlparse.urlsplit(company.url).netloc
            path = 'icons/%s.png' % host
            if os.path.isfile(path):
                favicon_sequence.append(path)
                num_valid += 1
            else:
                print 'Not valid: icons/%s.png' % host
                print company.url
                favicon_sequence.append('public/img/blank.png')
        print '#valid: %d' % num_valid
        os.system('convert %s +append public/img/favicons.png' % ' '.join(favicon_sequence))

    def update_alexa(self):
        try:
            if self.url:
                alexa = get_alexa_rank(self.url)
                print '%s - Alexa: %s' % (self.url, alexa)
                self.alexa = alexa
            else:
                print '%s has invalid URL!' % self.name
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            print '%s fucked up!!!' % self.url

    def update_pagerank(self):
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

    def formatted_date(self):
        return self.class_year.strftime('%Y/%m') if self.class_year else ''

    def formatted_title(self):
        return self.title if self.title != 'None' else ''

    def formatted_meta_desc(self):
        return self.meta_desc if self.meta_desc != 'None' else ''

    def formatted_aq_price(self):
        return locale.currency(int(self.aq_price), grouping=True)[:-3] if self.aq_price else ''


metadata.bind = 'sqlite:///data.sqlite'
metadata.bind.echo = False
setup_all(True)
