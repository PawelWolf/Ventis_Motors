from flask import Flask, render_template, request, redirect, url_for
from database import Database
from services import ClientPurchase, ResetCarCommand, ResetAllCarsCommand
from models import CarNotAvailableException

app = Flask(__name__, static_url_path='/media', static_folder='media')
db = Database()
"""Użycie klas"""

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
        """Użycie klas"""
        try:
            price = purchase.purchase(body, engine, drive, colour)
            """Użycie metod w klasach"""
            car_image = f"{body.lower()}_{colour.lower()}.png"
            return render_template("client_result.html", price=price, car_image=car_image)
        except CarNotAvailableException:
            """Użycie dziedziczenia, Utworzenie i użycie swojego wyjątku"""
            return render_template("client_result.html", price=None, car_image=None)
    return render_template("client_form.html")

@app.route('/dealer')
def dealer():
    cars = db.get_all_cars()
    """Użycie metod w klasach"""
    return render_template("dealer.html", cars=cars)

@app.route('/reset/<int:car_id>')
def reset(car_id):
    cmd = ResetCarCommand(db, car_id)
    """Użycie klas, Zastosowanie wzorca Command"""
    cmd.execute()
    """Użycie metod w klasach, Polimorfizm"""
    return redirect(url_for('dealer'))

@app.route("/reset_all", methods=["POST"])
def reset_all():
    command = ResetAllCarsCommand(db)
    """Użycie klas, Zastosowanie wzorca Command"""
    command.execute()
    """Użycie metod w klasach, Polimorfizm"""
    return redirect(url_for("dealer"))

if __name__ == '__main__':
    app.run(debug=True)