from models import Company
from elixir import session

companies = Company.query.filter(Company.url > '').filter(Company.dead == False)
for company in companies:
    company.update_pagerank()
    company.update_alexa()
    session.commit()
