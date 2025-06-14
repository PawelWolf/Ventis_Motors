from flask import Flask, render_template, request, redirect, url_for
from database import Database
from services import ClientPurchase, ResetCarCommand, ResetAllCarsCommand
from models import CarNotAvailableException

app = Flask(__name__)
db = Database()

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/client', methods=['GET', 'POST'])
def client():
    if request.method == 'POST':
        body = request.form['body']
        engine = request.form['engine']
        drive = request.form['drive']
        colour = request.form['colour']
        purchase = ClientPurchase(db)
        try:
            price = purchase.purchase(body, engine, drive, colour)
            return render_template("client_result.html", price=price)
        except CarNotAvailableException:
            return render_template("client_result.html", price=None)
    return render_template("client_form.html")

@app.route('/dealer')
def dealer():
    cars = db.get_all_cars()
    return render_template("dealer.html", cars=cars)

@app.route('/reset/<int:car_id>')
def reset(car_id):
    cmd = ResetCarCommand(db, car_id)
    cmd.execute()
    return redirect(url_for('dealer'))

if __name__ == '__main__':
    app.run(debug=True)
