import base64
from io import BytesIO
from flask import Flask, render_template 
from matplotlib.figure import Figure
import os
from dotenv import load_dotenv
from flask import Flask, render_template, request, redirect, url_for, flash
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required
from werkzeug.security import generate_password_hash, check_password_hash



load_dotenv()
app = Flask(__name__)
app.config["SECRET_KEY"] = os.getenv("JWT_SECRET_KEY")  # Use the secret key from the .env file

login_manager = LoginManager(app)
login_manager.login_view = "login"   # where to send people who aren't logged in

# Demo user store, replace with a database later
USERS = {"admin": generate_password_hash("1234")}

class User(UserMixin):
    def __init__(self, username):
        self.id = username

@login_manager.user_loader
def load_user(user_id):
    return User(user_id) if user_id in USERS else None

@app.route("/")
def Veinfinder(): 
    return render_template ("index.html")

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]
        if username in USERS and check_password_hash(USERS[username], password):
            login_user(User(username))
            return redirect(url_for("Patienter"))
        flash("Wrong username or password")
    return render_template("login.html")

@app.route("/logout")
def logout():
    logout_user()
    return redirect(url_for("login"))

@app.route("/Patienter")
@login_required          # only logged-in users can open this page
def patienter():
    return render_template("Patienter.html")

@app.route("/Malte_session")
@login_required 
def Malte_session(): 
    return render_template ("Malte_session.html")



@app.route("/index")
def index():
    return render_template("index.html")

@app.route("/Patienter")
def Patienter(): 
    return render_template ("Patienter.html")
   
      
if __name__ == "__main__":
	app.run(host="0.0.0.0", port=5000, debug=True)


