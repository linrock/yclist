from models import Company
from elixir import session
import datetime


stuff = [r for r in open('tmp/cleaned-output.txt','r').read().split('\n') if r]

for s in stuff:
    info = s.split('|')
    url = info[6]
    if url and url[-1] == '/': url = url[:-1]
    Company(
        name=info[1],
        class_year=datetime.datetime.strptime(info[2], '%m/%d/%Y'),
        dead=info[4] == 'Y',
        exited=info[5] == 'Y',
        aq_price=info[8],
        url=url
    )
session.commit()
