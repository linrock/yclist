from models import Company
from flask import Flask, render_template
app = Flask(__name__)

@app.route('/')
def index():
    companies = Company.query.all()
    return render_template('index.html', companies=companies)


if __name__ == '__main__':
    app.run()
