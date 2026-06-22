from flask import Flask, render_template, request, redirect, url_for
from database import db, Car, Employee  # <-- Import Employee z bazy Azure
from services import ClientPurchase, ResetCarCommand
from models import CarNotAvailableException

app = Flask(__name__, static_url_path='/media', static_folder='media')

# KONFIGURACJA POŁĄCZENIA Z AZURE SQL
# Wiele danych zostało skopiowanych z terraforma
SQL_CONN = "mssql+pyodbc://wilqu:Pawel2137!@ventis-sql-server-72563.database.windows.net/ventis-db?driver=ODBC+Driver+17+for+SQL+Server"
app.config['SQLALCHEMY_DATABASE_URI'] = SQL_CONN
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/client', methods=['GET', 'POST'])
def client():
    if request.method == 'POST':
        body = request.form.get('body')
        colour = request.form.get('colour')
        fuel_type = request.form.get('fuel_type') 
        employee_id = request.form.get('employee_id', 4)
        
        purchase = ClientPurchase(db)
        try:
            price = purchase.purchase(body, fuel_type, colour, employee_id)
            car_image = f"{body.lower()}_{colour.lower()}.png"
            return render_template("client_result.html", price=price, car_image=car_image)
        except CarNotAvailableException:
            return render_template("client_result.html", price=None, car_image=None)

    # BEZPIECZNE POBIERANIE I SORTOWANIE PRACOWNIKÓW DLA ŻĄDANIA GET
    try:
        employees = Employee.query.all()
        
        # Jeśli baza działa, sortujemy listę w Pythonie, aby Ivo (ID 4) zawsze był na szczycie
        if employees:
            employees = sorted(employees, key=lambda emp: emp.EmployeeID != 4)
            
    except Exception as e:
        print(f"Błąd połączenia z Azure SQL, używam obiektów awaryjnych: {e}")
        employees = None

    # Ivo Czura to debesciak i sprzedaje najwiecej bo proponuje pierwszą jazdę z nim do Pastrami Leszno, 
    # więc ustawiam go jako domyślnego sprzedawcę (ID=4) nawet w przypadku błędu połączenia z bazą danych. 
    # Dzięki temu strona będzie nadal funkcjonalna, a klienci będą mieli możliwość wyboru innych sprzedawców, jeśli baza danych jest dostępna.
    if not employees:
        class FakeEmployee:
            def __init__(self, id, first, last):
                self.EmployeeID = id
                self.FirstName = first
                self.LastName = last

        employees = [
            FakeEmployee(4, "Ivo", "Czura"),  # debesciak
            FakeEmployee(1, "Paweł", "Wolf"),
            FakeEmployee(2, "Konrad", "Skrzypek"),
            FakeEmployee(3, "Oliwier", "Pol")
        ]
        
    return render_template("client_form.html", employees=employees)

@app.route('/dealer')
def dealer():
    # Pobranie wszystkich danych z Azure SQL i przekazanie ich do szablonu
    cars = Car.query.all()
    return render_template("dealer.html", cars=cars)

@app.route('/reset/<int:car_id>')
def reset(car_id):
    cmd = ResetCarCommand(car_id)
    cmd.execute()
    return redirect(url_for('dealer'))

if __name__ == '__main__':
    app.run(debug=True)