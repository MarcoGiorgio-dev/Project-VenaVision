import base64
from io import BytesIO
from flask import Flask, render_template 
from matplotlib.figure import Figure
import os
from dotenv import load_dotenv
from flask import Flask, render_template, request, redirect, url_for, flash
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required
from werkzeug.security import generate_password_hash, check_password_hash
import psycopg2




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
            return redirect(url_for("patienter"))
        flash("Wrong username or password")
    return render_template("login.html")

def get_db():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("venavision"),
        user=os.getenv("venavision_user"),
        password=os.getenv("gruppe4"),
        port=os.getenv("DB_PORT", "5432"),
    )


@app.route("/logout")
def logout():
    logout_user()
    return redirect(url_for("login"))

@app.route("/Patienter", methods=["GET", "POST"])
@login_required
def patienter():
    conn = get_db()
    cur = conn.cursor()
    try:
        if request.method == "POST":
            # Ingen notes/visits her - de håndteres kun inde på patienten
            cur.execute(
                """
                INSERT INTO patients
                (first_name, last_name, birth_date, sex, cpr, blood_type, diagnose)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    request.form["first_name"].strip(),
                    request.form["last_name"].strip(),
                    request.form["birth_date"],
                    request.form["sex"],
                    request.form["cpr_number"],
                    request.form["blood_type"],
                    request.form.get("diagnose", ""),
                    request.form["follow_up"],
                ),
            )
            conn.commit()
            return redirect(url_for("patienter"))

        cur.execute(
            "SELECT id, first_name, last_name, birth_date, sex, cpr_number, blood_type, diagnose, follow_up"
            "FROM patients ORDER BY last_name, first_name"
        )
        patients = cur.fetchall()
        return render_template("patienter.html", patients=patients)
    finally:
        cur.close()
        conn.close()


@app.route("/patient/<int:patient_id>", methods=["GET", "POST"])
@login_required
def patient(patient_id):
    conn = get_db()
    cur = conn.cursor()
    try:
        if request.method == "POST":
            form_type = request.form.get("form_type")

            if form_type == "patient_info":
                # Opdaterer notes og visits på selve patienten
                visits = int(request.form.get("visits") or 0)
                cur.execute(
                    "UPDATE patients SET notes = %s, visits = %s WHERE id = %s",
                    (request.form["notes"], visits, patient_id),
                )
            elif form_type == "session":
                cur.execute(
                    "INSERT INTO patient_sessions (patient_id, last_prick, notes) "
                    "VALUES (%s, %s, %s)",
                    (patient_id, request.form["last_prick"], request.form["notes"]),
                )

            conn.commit()
            return redirect(url_for("patient", patient_id=patient_id))

        cur.execute(
            "SELECT id, first_name, last_name, birth_date, gender, cpr, blood_type, "
            "diagnosis, notes, visits FROM patients WHERE id = %s",
            (patient_id,),
        )
        p = cur.fetchone()
        if p is None:
            return "Patient not found", 404

        cur.execute(
            "SELECT id, age, notes, created_at FROM patient_sessions "
            "WHERE patient_id = %s ORDER BY created_at DESC",
            (patient_id,),
        )
        sessions = cur.fetchall()
        return render_template("patient.html", patient=p, sessions=sessions)
    finally:
        cur.close()
        conn.close()



@app.route("/index")
def index():
    return render_template("index.html")

         

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
