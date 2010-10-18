from models import Company
from flask import Flask, render_template
app = Flask(__name__)
app.debug = True


all_companies = list(enumerate(Company.query.all()))
# filtered = Company.query.filter(Company.url > '').filter(Company.dead == False).filter(Company.exited == False)
# dead = Company.query.filter(Company.url > '').filter(Company.dead == False)
filtered = []
exited = []
for i,company in all_companies:
    if company.url > '' and company.dead == False and company.exited == False:
        filtered.append((i,company))
    if company.exited == True:
        exited.append((i,company))


@app.route('/')
def show_active():
    return render_template('index.html', companies=filtered, title="Active")

@app.route('/all')
def show_all():
    return render_template('index.html', companies=all_companies, title="All")

@app.route('/exited')
def show_exited():
    return render_template('index.html', companies=exited, title="Exited")


if __name__ == '__main__':
    app.run()
