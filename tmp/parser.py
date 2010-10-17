import lxml.html

soup = lxml.html.fromstring(open('yc-companies.html','r').read())
good_rows = []
junk_rows = soup.xpath('//tbody/tr')
for row in junk_rows:
    if row[0].attrib.get('class') == 'hd':
        good_rows.append([r for r in row if (r.attrib.get('class') and 'dn' not in r.attrib.get('class')) or not r.attrib])
with open('cleaned-output.txt','w') as f:
    for row in good_rows[1:]:
        f.write('|'.join([r.text_content() for r in row]) + '\n')
