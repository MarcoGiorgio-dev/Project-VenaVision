
import os
from flask import Flask, render_template, request, redirect, url_for, flash
from dotenv import load_dotenv
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required
from werkzeug.security import generate_password_hash, check_password_hash
import psycopg2

load_dotenv()

app = Flask(__name__)
app.config["SECRET_KEY"] = os.getenv("JWT_SECRET_KEY")

login_manager = LoginManager(app)
login_manager.login_view = "login"

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
    return render_template("index.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        if username in USERS and check_password_hash(USERS[username], password):
            login_user(User(username))
            return redirect(url_for("session"))

        flash("Wrong username or password")

    return render_template("login.html")


def get_db():
    print("DB_PASSWORD present:", bool(os.getenv("DB_PASSWORD")), flush=True)
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("DB_NAME", "venavision"),
        user=os.getenv("DB_USER", "venavision_user"),
        password=os.getenv("DB_PASSWORD"),
        port=os.getenv("DB_PORT", "5432"),
    )


@app.route("/logout")
def logout():
    logout_user()
    return redirect(url_for("login"))


@app.route("/session", methods=["GET", "POST"])
@login_required
def session():
    conn = get_db()
    cur = conn.cursor()

    try:
        if request.method == "POST":
            cur.execute(
                """
                INSERT INTO patients
                (first_name, last_name, birth_date, diagnose, last_prick,
                 blood_type, sex, follow_up, cpr_number)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    request.form["first_name"].strip(),
                    request.form["last_name"].strip(),
                    request.form["birth_date"],
                    request.form["diagnose"],
                    request.form["last_prick"],
                    request.form["blood_type"],
                    request.form["sex"],
                    request.form["follow_up"],
                    request.form["cpr_number"],
                ),
            )

            conn.commit()
            return redirect(url_for("session"))

        cur.execute(
            """
            SELECT id, first_name, last_name, birth_date, sex,
                   cpr_number, blood_type, diagnose, follow_up
            FROM patients
            ORDER BY last_name, first_name
            """
        )

        patients = cur.fetchall()
        return render_template("session.html", patients=patients)

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
            cur.execute(
                """
                UPDATE patients
                SET notes = %s
                WHERE id = %s
                """,
                (request.form["notes"], patient_id),
            )

            conn.commit()
            return redirect(url_for("patient", patient_id=patient_id))

        cur.execute(
            """
            SELECT id, first_name, last_name, birth_date, sex,
                   cpr_number, blood_type, diagnose, last_prick,
                   follow_up, notes
            FROM patients
            WHERE id = %s
            """,
            (patient_id,),
        )

        p = cur.fetchone()

        if p is None:
            return "Patient not found", 404

        return render_template("patient.html", patient=p)

    finally:
        cur.close()
        conn.close()


@app.route("/index")
def index():
    return render_template("index.html")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
