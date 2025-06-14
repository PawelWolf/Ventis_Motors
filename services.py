from models import CarNotAvailableException

class CarPurchaseTemplate:
    def __init__(self, db):
        self.db = db

    def purchase(self, body, engine, drive, colour):
        car = self.db.find_car(body, engine, drive, colour)
        if not car:
            raise Exception("Car not found!")

        price = self.process_purchase(car)
        self.db.update_car_status(car.car_id, car.sold)
        return price

    def process_purchase(self, car):
        raise NotImplementedError

class ClientPurchase(CarPurchaseTemplate):
    def process_purchase(self, car):
        if car.sold == 's':
            raise CarNotAvailableException("Car already sold!")
        car.sell()
        return car.price

class Command:
    def execute(self):
        pass

class ResetCarCommand(Command):
    def __init__(self, db, car_id):
        self.db = db
        self.car_id = car_id

    def execute(self):
        self.db.update_car_status(self.car_id, None)
