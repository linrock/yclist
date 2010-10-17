import datetime
for k,v in data.items():
    c = Company.query.filter(Company.name==k).first()
    c.class_year = datetime.datetime.strptime(v, '%m/%d/%Y')
