import urlparse
import datetime
import yaml
import re

from radiant.browser import Browser

from models import Company
from elixir import session


def import_spreadsheet():
    b = Browser(use_proxy=False)
    b.open('https://spreadsheets.google.com/lv?key=t_toYuVyy6fci0MAiIaZ30A&f=false&gid=0')
    rows = b.parser.xpath('//td[@class="rowNum"]/..')
    data = []
    for row in rows:
        data.append([t.text_content() for t in row.xpath('./td')])
    assert len(data) >= 208, 'Wrong number of rows! - %d' % len(data)

    print '%d companies found' % len(data)
    yaml_data = []
    for row in data:
        url = row[7]
        if url and url[-1] == '/': url = url[:-1]
        price = re.sub('[^\d]','',row[9])
        hostname = urlparse.urlsplit(url).netloc.replace('www.','')
        yaml_data.append({
            'name': str(row[1]),
            'class_year': datetime.datetime.strptime(row[2], '%m/%d/%Y'),
            'dead': row[4] == 'Y',
            'exited': row[6] == 'Y',
            'aq_price': str(price) if price else None,
            'hostname': hostname,
            'notes': str(row[8]),
            'url': str(url)
        })
    with open('data/company_list.yaml','w') as f:
        yaml.dump(yaml_data, f, default_flow_style=False)

def load_yaml_data():
    for row in yaml.load(open('data/company_list.yaml','r').read()):
        Company(**row)
    session.commit()


if __name__ == '__main__':
    pass
    # load_yaml_data()
