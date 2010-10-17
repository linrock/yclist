from radiant.browser import Browser
from models import Company
from elixir import session
import mechanize

import urlparse
import os


def get_favicons():
    b = Browser()
    for company in Company.query.filter(Company.url > '').filter(Company.dead == False):
        print 'Checking: %s' % company.url
        try:
            b.open(company.url)
        except mechanize.URLError:
            print '%s appears dead' % company.url
        else:
            host = urlparse.urlsplit(company.url).netloc
            try:
                company.title = b.parser.xpath('//title/text()')[0]
            except IndexError:
                pass
            try:
                company.meta_desc = b.parser.xpath('//meta[@name="description"]/@content')[0]
            except IndexError:
                pass
            favicon_url = b.parser.xpath('//link[contains(@rel, "icon")]/@href')
            if not favicon_url:
                favicon_url = company.url + '/favicon.ico'
            elif favicon_url:
                if not favicon_url[0].startswith('http://'):
                    favicon_url = company.url + favicon_url[0]

            os.system('wget %s -O public/%s/favicon.ico' % (favicon_url, host))
            session.commit()

def convert_favicons():
    for directory in os.listdir('public'):
        if 'favicon.ico' in os.listdir('public/%s' % directory):
            old_icon = 'public/%s/favicon.ico' % directory
            new_icon = 'public/%s/favicon.gif' % directory
            os.system('convert %s %s' % (old_icon, new_icon))

def create_directories():
    for company in Company.query.filter(Company.url > ''):
        host = urlparse.urlsplit(company.url).netloc
        public_dir = 'public/%s' % host
        if not os.path.isdir(public_dir):
            os.mkdir(public_dir)


