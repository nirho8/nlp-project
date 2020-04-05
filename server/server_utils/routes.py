from flask import render_template, flash, redirect, url_for, jsonify
# from server import app
# from server.forms import CheckTweet
from flask_cors import cross_origin

from server_utils.model import Model
from server_utils import app
from flask import request


@app.route('/')
def home():
    return render_template('index.html', title='home')


@app.route('/about')
def about():
    return render_template('About.html', title='about')


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


@app.route('/tweet_prediction', methods=['POST'])
@cross_origin()
def tweet_prediction():
    print(request)
    # tweet_details = CheckTweet()
    # print(tweet_details)
    tweet = request.json["tweet"]
    time = request.json["time"]
    user = request.json["user"]
    # model = Model("dummy model")
    # model.prediction(tweet)
    return jsonify(
        like=5,
    )
    # if tweet_details.validate_on_submit():
    #     if True:
    #         flash(model.prediction(tweet_details.account_name.data, tweet_details.tweet.data, tweet_details.time.data), 'success')
    #
    #         return redirect(url_for('home'))
    #     else:
    #         flash("wrong input", 'danger')
    # return render_template('/tweet_prediction.html', title='tweet_prediction', tweet_details=tweet_details)