from flask import render_template, jsonify, request
from flask_cors import cross_origin

from src.server.server_utils import app
from src.main_model import predict, predict_load_model, predict_load_vocab
from src.user_utils import get_user


model = predict_load_model()
vocab = predict_load_vocab()


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
    tweet_text = request.json["tweet"]
    time = request.json["time"]
    screen_name = request.json["user"]
    user = get_user(screen_name)
    predicted_likes = predict(model, vocab, tweet_text, user)
    return jsonify(
        like=predicted_likes,
    )

