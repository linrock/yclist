from models import Company
import locale; locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')
from datetime import date

OUTFILE = 'public/index.html'


class YCList(object):
    companies = []

    def __init__(self):
        for i,company in enumerate(Company.query.all()):
            cl = []
            if (not company.url and not company.exited and not company.dead) or not company.class_year:
                cl.append('unknown')
            elif company.url > '' and not company.exited and not company.dead:
                cl.append('active')
            if company.exited == True:
                cl.append('exited')
            elif company.dead == True:
                cl.append('dead')
            self.companies.append((i, company, ' '.join(cl)))

    def serve(self):
        from flask import Flask, render_template
        app = Flask(__name__)
        app.debug = True

        @app.route('/')
        def show():
            return render_template('index.jinja', companies=self.companies)

        app.run()

    def generate_static(self):
        from jinja2 import Template
        print 'Generating static HTML (%s)...' % OUTFILE
        t = Template(open('templates/index.jinja', 'r').read())
        kwargs = {
            'companies': self.companies,
            'last_updated': date.strftime(date.today(), '%m/%d/%Y')
        }
        open(OUTFILE, 'w').write(t.render(**kwargs).encode('UTF-8'))


if __name__ == '__main__':
    # YCList().serve()
    YCList().generate_static()
