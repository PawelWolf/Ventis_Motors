from database import db, Car, Sale, Status, BodyType
from models import CarNotAvailableException

class CarPurchaseTemplate:
    def __init__(self, database_instance):
        self.db_instance = database_instance

    def purchase(self, body_name, engine_type, colour):
        return self.process_purchase(body_name, engine_type, colour)

    def process_purchase(self, body_name, engine_type, colour):
        # Szukamy auta o zadanych parametrach, które jest 'Available'
        car = Car.query.join(BodyType).join(Status).filter(
            BodyType.TypeName == body_name,
            Status.StatusName == 'Available',
            Car.Colour == colour
        ).first()

        if not car:
            raise CarNotAvailableException()

        try:
            # Transakcja: Zmień status na 'Sold' (zakładamy ID=2 dla Sold)
            car.StatusID = 2 
            
            # DOdanie rekordu sprzedaży
            new_sale = Sale(CarID=car.CarID, CustomerID=1, EmployeeID=1, FinalPrice=car.Price)
            
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