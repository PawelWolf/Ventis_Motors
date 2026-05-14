from flask_sqlalchemy import SQLAlchemy
import os

db = SQLAlchemy()

class Series(db.Model):
    __tablename__ = 'Series'
    SeriesID = db.Column(db.Integer, primary_key=True)
    SeriesName = db.Column(db.String(50), nullable=False)

class BodyType(db.Model):
    __tablename__ = 'BodyTypes'
    BodyTypeID = db.Column(db.Integer, primary_key=True)
    TypeName = db.Column(db.String(30), nullable=False)

class Status(db.Model):
    __tablename__ = 'Statuses'
    StatusID = db.Column(db.Integer, primary_key=True)
    StatusName = db.Column(db.String(30), nullable=False)

class Engine(db.Model):
    __tablename__ = 'Engines'
    EngineID = db.Column(db.Integer, primary_key=True)
    Capacity = db.Column(db.Float)
    FuelType = db.Column(db.String(20))
    Horsepower = db.Column(db.Integer)

class Car(db.Model):
    __tablename__ = 'Cars'
    CarID = db.Column(db.Integer, primary_key=True)
    SeriesID = db.Column(db.Integer, db.ForeignKey('Series.SeriesID'))
    BodyTypeID = db.Column(db.Integer, db.ForeignKey('BodyTypes.BodyTypeID'))
    EngineID = db.Column(db.Integer, db.ForeignKey('Engines.EngineID'))
    StatusID = db.Column(db.Integer, db.ForeignKey('Statuses.StatusID'))
    Colour = db.Column(db.String(30), nullable=False)
    Price = db.Column(db.Numeric(18, 2), nullable=False)
    ProductionYear = db.Column(db.Integer)

    # Relacje ułatwiające dostęp do danych
    body_rel = db.relationship('BodyType', backref='cars')
    status_rel = db.relationship('Status', backref='cars')

class Sale(db.Model):
    __tablename__ = 'Sales'
    SaleID = db.Column(db.Integer, primary_key=True)
    CarID = db.Column(db.Integer, db.ForeignKey('Cars.CarID'))
    CustomerID = db.Column(db.Integer, db.ForeignKey('Customers.CustomerID'))
    EmployeeID = db.Column(db.Integer, db.ForeignKey('Employees.EmployeeID'))
    SaleDate = db.Column(db.DateTime, server_default=db.func.now())
    FinalPrice = db.Column(db.Numeric(18, 2), nullable=False)

class Customer(db.Model):
    __tablename__ = 'Customers'
    CustomerID = db.Column(db.Integer, primary_key=True)
    FirstName = db.Column(db.String(50))
    LastName = db.Column(db.String(50))
    Email = db.Column(db.String(100), unique=True)
    Phone = db.Column(db.String(20))