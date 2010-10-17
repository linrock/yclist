from elixir import *
import mechanize
from radiant.browser import Browser
from radiant.interfaces.alexa import get_alexa_rank
from radiant.interfaces.pagerank import get_pagerank

import urlparse
import locale
import os


locale.setlocale(locale.LC_ALL, '')

class Company(Entity):
    using_table_options(useexisting=True)
    using_options(tablename='companies')

    has_field('name',           String(32), index=True)
    has_field('class_year',     DateTime)
    has_field('url',            String(128))
    has_field('title',          String(128))
    has_field('meta_desc',      String(128))

    has_field('pagerank',       Integer)
    has_field('alexa',          Integer)

    has_field('dead',           Boolean)
    has_field('exited',         Boolean)
    has_field('favicon',        Boolean)
    has_field('snapshot',       Boolean)
    has_field('aq_price',       Integer)

    def hostname(self):
        return urlparse.urlsplit(self.url).netloc

    def get_favicon(self):
        if self.url > '' and not self.dead:
            host = urlparse.urlsplit(self.url).netloc
            if not os.path.isfile('public/img/%s/favicon.ico' % host):
                try:
                    print 'Trying... %s' % self.url
                    b = Browser(use_proxy=True)
                    b.open(self.url)
                except mechanize.HTTPError:
                    print 'FAILED!!!'
                else:
                    dl_host = urlparse.urlsplit(b.geturl()).netloc
                    favicon_url = b.parser.xpath('//link[contains(@rel, "icon") or contains(@rel, "Icon")]/@href')
                    if not favicon_url:
                        favicon_url = 'http://' + dl_host + '/favicon.ico'
                    elif favicon_url:
                        if not favicon_url[0].startswith('http://'):
                            favicon_url = 'http://' + dl_host + favicon_url[0]
                        else:
                            favicon_url = favicon_url[0]
                    os.system('wget %s -O public/img/%s/favicon.ico' % (favicon_url, host))
                    if os.path.isfile('public/img/%s/favicon.ico' % host):
                        self.favicon = True
                        session.commit()

    def convert_favicon(self):
        directory = 'public/img/%s' % self.url[7:]
        if 'favicon.ico' in os.listdir(directory):
            self.favicon = True
            old_icon = '"%s/favicon.ico[0]"' % directory
            new_icon = '%s/favicon.png' % directory
            if not os.path.isfile(new_icon):
                os.system('convert %s -resize 16x16 %s' % (old_icon, new_icon))
        else:
            self.favicon = False
        session.commit()

    def get_pagerank(self):
        pr = get_pagerank(self.url)
        print '%s PR: %s' % (self.url, pr)
        self.pagerank = pr
        session.commit()

    def formatted_date(self):
        return self.class_year.strftime('%m/%Y') if self.class_year else ''

    def formatted_title(self):
        return self.title if self.title != 'None' else ''

    def formatted_meta_desc(self):
        return self.meta_desc if self.meta_desc != 'None' else ''

    def formatted_aq_price(self):
        return locale.currency(self.aq_price, grouping=True)[:-3] if self.aq_price else ''


metadata.bind = 'sqlite:///data.sqlite'
metadata.bind.echo = False
setup_all(True)
