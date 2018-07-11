from flask import render_template
from app import app

@app.route('/')
@app.route('/index')
def index():
    user = {'username': 'Wazza'}
    posts = [
        {
            'author': {'username': 'Alison'},
            'body':   'Beautiful day in Sydney!'
        },
        {
            'author': {'username': 'Brian'},
            'body':   'The Avengers movie was so cool!'
        },
        {
            'author': {'username': 'Charlie'},
            'body':   'Brrrrr ... winter is getting colder!'
        }
    ]
    return render_template('index.html', title='Home', user=user, posts=posts)
