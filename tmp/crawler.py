from radiant.browser import Browser
from models import Company
from elixir import session
import urlparse


b = Browser()
for company in Company.query.filter(Company.url > ''):
    host = urlparse.urlsplit(company.url).netloc
    title = b.parser.xpath('//title/text()')[0]
    favicon_url = b.parser.xpath('//link[contains(@rel, "icon")]/@href')
    if not favicon_url:
        favicon_url = company.url + '/favicon.ico'
    elif favicon_url:
        if not favicon_url.startswith('http://'):
            favicon_url = company.url + favicon_url[0]

session.commit()
