import sqlite3

# Własny wyjątek
class CarNotAvailableException(Exception):
    pass

# Klasa bazowa Car
class Car:
    def __init__(self, car_id, body, engine, drive, colour, price, sold):
        self._car_id = car_id
        self._body = body
        self._engine = engine
        self._drive = drive
        self._colour = colour
        self._price = price
        self._sold = sold

    @property
    def car_id(self):
        return self._car_id

    @property
    def price(self):
        return self._price

    @property
    def sold(self):
        return self._sold

    @sold.setter
    def sold(self, value):
        if value not in ('s', None):
            raise ValueError("Invalid sold status")
        self._sold = value

    def __str__(self):
        return f"{self._body} {self._engine} {self._drive} {self._colour} - {self._price} - {self._sold or 'Not Sold'}"

# Dziedziczenie - Klasa dla dostępnego auta
class AvailableCar(Car):
    def sell(self):
        if self.sold == 's':
            raise CarNotAvailableException("Car already sold!")
        self.sold = 's'
        return self.price

# Dziedziczenie - Klasa dla sprzedanego auta
class SoldCar(Car):
    def refund(self):
        self.sold = None
        return self.price

# Klasa fabryczna - kilka konstruktorów
class CarFactory:
    @staticmethod
    def create_from_row(row):
        car = AvailableCar(*row) if row[-1] != 's' else SoldCar(*row)
        return car

    @classmethod
    def create_from_form(cls, form_data):
        return Car(
            None,
            form_data['body'],
            form_data['engine'],
            form_data['drive'],
            form_data['colour'],
            form_data['price'],
            None
        )
