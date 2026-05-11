from flask import Flask, render_template, request, redirect, url_for
from database import db, Car
from services import ClientPurchase, ResetCarCommand
from models import CarNotAvailableException

app = Flask(__name__, static_url_path='/media', static_folder='media')

# KONFIGURACJA POŁĄCZENIA Z AZURE SQL
# Podstaw dane ze swojego Terraform (server, user, password)
SQL_CONN = "mssql+pyodbc://wilqu:pawel2137!@ventis-sql-server.database.windows.net/ventis-db?driver=ODBC+Driver+17+for+SQL+Server"
app.config['SQLALCHEMY_DATABASE_URI'] = SQL_CONN
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/client', methods=['GET', 'POST'])
def client():
    if request.method == 'POST':
        body = request.form['body']
        colour = request.form['colour']
        purchase = ClientPurchase(db)
        try:
            price = purchase.purchase(body, None, colour)
            car_image = f"{body.lower()}_{colour.lower()}.png"
            return render_template("client_result.html", price=price, car_image=car_image)
        except CarNotAvailableException:
            return render_template("client_result.html", price=None, car_image=None)
    return render_template("client_form.html")

@app.route('/dealer')
def dealer():
    # Pobieramy wszystkie auta z Azure przez ORM
    cars = Car.query.all()
    return render_template("dealer.html", cars=cars)

@app.route('/reset/<int:car_id>')
def reset(car_id):
    cmd = ResetCarCommand(car_id)
    cmd.execute()
    return redirect(url_for('dealer'))

if __name__ == '__main__':
    app.run(debug=True)