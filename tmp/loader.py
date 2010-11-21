from models import Company
from elixir import session

import urlparse
import datetime
import re


stuff = [r for r in open('tmp/cleaned-output.txt','r').read().split('\n') if r]

for s in stuff:
    info = s.split('|')
    url = info[6]
    if url and url[-1] == '/': url = url[:-1]
    price = re.sub('[^\d]','',info[8])
    hostname = urlparse.urlsplit(url).netloc.replace('www.', '')

    Company(
        name=info[1],
        class_year=datetime.datetime.strptime(info[2], '%m/%d/%Y'),
        dead=info[4] == 'Y',
        exited=info[5] == 'Y',
        aq_price=price if price else None,
        hostname=hostname,
        url=url
    )
session.commit()
