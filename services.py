from database import db, Car, Sale, Status, BodyType, Engine, Employee
from models import CarNotAvailableException

class CarPurchaseTemplate:
    def __init__(self, database_instance):
        self.db_instance = database_instance

    def purchase(self, body_name, engine_type, colour, employee_id):
        return self.process_purchase(body_name, engine_type, colour, employee_id)

    def process_purchase(self, body_name, engine_type, colour, employee_id):
        # Zaawansowany wielokrotny JOIN (BodyType + Status + Engine)
        car = Car.query.join(BodyType).join(Status).join(Engine).filter(
            BodyType.TypeName == body_name,
            Status.StatusName == 'Available',
            Engine.FuelType == engine_type,
            Car.Colour == colour
        ).first()

        if not car:
            raise CarNotAvailableException()

        try:
            # Transakcja: Zmiana statusu na 'Sold' (ID=2)
            car.StatusID = 2 
            
            # Zapis transakcji w bazie danych z dynamicznym przypisaniem pracownika
            new_sale = Sale(
                CarID=car.CarID, 
                CustomerID=1, 
                EmployeeID=int(employee_id),  # <-- Dynamiczny wybór sprzedawcy!
                FinalPrice=car.Price
            )
            
            db.session.add(new_sale)
            db.session.commit() 
            return float(car.Price)
        except Exception as e:
            db.session.rollback()
            raise e

class ClientPurchase(CarPurchaseTemplate):
    pass

class ResetCarCommand:
    def __init__(self, car_id):
        self.car_id = car_id

    def execute(self):
        car = Car.query.get(self.car_id)
        if car:
            car.StatusID = 1 # Reset do 'Available'
            db.session.commit()