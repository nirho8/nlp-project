from flask import Flask
from flask_cors import CORS

from src.config import FLASK_TEMPLATE_FOLDER

app = Flask(__name__, template_folder=FLASK_TEMPLATE_FOLDER)
CORS(app,  resources={r"/api/*": {"origins": "*"}})
app.config['SECRET_KEY'] = '123456789'
app.config['Access-Control-Allow-Origin'] = '*'

from src.server.server_utils import routes
