from radiant.browser import Browser
import urlparse
import sqlite3


conn = sqlite3.connect('data.sqlite')
urls = conn.execute('SELECT (url) FROM companies').fetchall()
urls = [u[0] for u in urls if u[0]]

b = Browser()
for url in urls:
    host = urlparse.urlsplit(url).netloc
    title = b.parser.xpath('//title/text()')[0]
    favicon_url = b.parser.xpath('//link[contains(@rel, "icon")]/@href')
    if not favicon_url:
        favicon_url = url + '/favicon.ico'
    elif favicon_url:
        if not favicon_url.startswith('http://'):
            favicon_url = url + favicon_url[0]

