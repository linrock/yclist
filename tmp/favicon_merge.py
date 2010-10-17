from models import Company
import os

companies = Company.query.all()
favicon_sequence = []
for company in companies:
    path = 'public/img/%s/favicon.png' % company.hostname()
    if os.path.isfile(path):
        favicon_sequence.append(path)
    else:
        favicon_sequence.append('public/img/blank.png')
os.system('convert %s +append public/img/favicons.png' % ' '.join(favicon_sequence))
