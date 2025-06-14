import sqlite3
from models import CarFactory

class Database:
    def __init__(self, db_path='cars.db'):
        self.db_path = db_path

    def get_connection(self):
        return sqlite3.connect(self.db_path)

    def get_all_cars(self):
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT id, body, engine, drive, colour, price, selled FROM cars")
            rows = cursor.fetchall()
            return [CarFactory.create_from_row(row) for row in rows]

    def find_car(self, body, engine, drive, colour):
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT id, body, engine, drive, colour, price, selled 
                FROM cars 
                WHERE body=? AND engine=? AND drive=? AND colour=?""",
                (body, engine, drive, colour)
            )
            row = cursor.fetchone()
            if row:
                return CarFactory.create_from_row(row)
            return None

    def update_car_status(self, car_id, sold_status):
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("UPDATE cars SET selled=? WHERE id=?", (sold_status, car_id))
            conn.commit()
    
    def reset_all(self):
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("UPDATE cars SET selled = NULL")
            conn.commit()