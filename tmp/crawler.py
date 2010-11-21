from radiant.browser import Browser
from radiant.tools import wash_url
from models import Company
from elixir import session
import mechanize

import urlparse
import urllib2
import re
import os

valid_filetypes = [
    'image/x-icon',
    'image/png',
    'application/octet-stream'
]

def get_favicons():
    b = Browser()
    for company in Company.query.filter(Company.url > '').filter(Company.dead == False):
        print 'Checking: %s' % company.url
        try:
            b.open(company.url)
        except mechanize.URLError:
            print '%s appears dead' % company.url
            continue
        current_url = b.geturl()
        split_url = urlparse.urlsplit(current_url)
        print 'Current URL: %s' % current_url
        if urlparse.urlsplit(company.url).netloc in current_url:
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
        session.commit()

def convert_favicons():
    icon_names = [f for f in os.listdir('icons') if f.endswith('.ico')]
    for i in icon_names:
        old_icon = 'icons/%s' % i
        new_icon = 'icons/%s.png' % i[:-4]
        os.system('convert %s[0] -resize 16x16 -flatten %s' % (old_icon, new_icon))
