from models import Company
from elixir import session


stuff = [r for r in open('tmp/cleaned-output.txt','r').read().split('\n') if r]

for s in stuff:
    info = s.split('|')
    url = info[6]
    if url and url[-1] == '/': url = url[:-1]
    Company(
        name=info[1],
        dead=info[4] == 'Y',
        exited=info[5] == 'Y',
        url=url
    )
session.commit()
