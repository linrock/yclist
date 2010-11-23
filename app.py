from models import Company
from flask import Flask, render_template
import locale


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
        app = Flask(__name__)
        app.debug = True

        @app.route('/')
        def show():
            return render_template('index.html', companies=self.companies)

        app.run()

if __name__ == '__main__':
    # locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')
    locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')
    YCList().serve()
