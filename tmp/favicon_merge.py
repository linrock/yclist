from models import Company
import urlparse
import os

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
