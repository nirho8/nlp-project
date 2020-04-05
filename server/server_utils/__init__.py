from flask import Flask
from flask_cors import CORS

app = Flask(__name__)
CORS(app,  resources={r"/api/*": {"origins": "*"}})
app.config['SECRET_KEY'] = '123456789'
app.config['Access-Control-Allow-Origin'] = '*'

from server_utils import routes
