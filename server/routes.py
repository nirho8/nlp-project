from flask import render_template, flash, redirect, url_for
from server import app
from server.forms import CheckTweet
from server.model import Model


@app.route('/')
def home():
    return render_template('index.html', title='home')


@app.route('/about')
def about():
    return render_template('about.html', title='about')


@app.route('/registration')
def registration():
    return render_template('registration.html', title='registration')


@app.route('/login')
def login():
    return render_template('login.html', title='login')


@app.route('/account')
def account():
    return render_template('account.html', title='account')


@app.route('/admin_management')
def admin_management():
    return render_template('admin_management.html', title='admin management')


@app.route('/tweet_prediction', methods=['GET', 'POST'])
def tweet_prediction():
    tweet_details = CheckTweet()
    print(tweet_details)
    model = Model("dummy model")
    if tweet_details.validate_on_submit():
        if True:
            flash(model.prediction(tweet_details.account_name.data, tweet_details.tweet.data, tweet_details.time.data), 'success')

            return redirect(url_for('home'))
        else:
            flash("wrong input", 'danger')
    return render_template('/tweet_prediction.html', title='tweet_prediction', tweet_details=tweet_details)

