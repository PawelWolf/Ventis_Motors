import sqlite3
from models import CarFactory


class Database:

    def __init__(self, db_path='cars.db'):
        """
        Inicjalizuje obiekt Database.

        Args:
            db_path (str, optional): Ścieżka do pliku bazy danych.
                                   Domyślnie 'cars.db'.
        """
        self.db_path = db_path

    def get_connection(self):
        """
        Tworzy i zwraca połączenie z bazą danych SQLite.

        Returns:
            sqlite3.Connection: Obiekt połączenia z bazą danych

        Raises:
            sqlite3.Error: Gdy nie można nawiązać połączenia z bazą danych
        """
        return sqlite3.connect(self.db_path)

    def get_all_cars(self):
        """
        Pobiera wszystkie samochody z bazy danych.

        Returns:
            list: Lista obiektów Car utworzonych z rekordów bazy danych

        Raises:
            sqlite3.Error: Gdy wystąpi błąd podczas wykonywania zapytania SQL
        """
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT id, body, engine, drive, colour, price, selled FROM cars")
            rows = cursor.fetchall()
            return [CarFactory.create_from_row(row) for row in rows]

    def find_car(self, body, engine, drive, colour):
        """
        Wyszukuje samochód według podanych parametrów.

        Args:
            body (str): Typ nadwozia samochodu
            engine (str): Typ silnika
            drive (str): Typ napędu
            colour (str): Kolor samochodu

        Returns:
            Car or None: Obiekt Car jeśli znaleziono, None w przeciwnym razie

        Raises:
            sqlite3.Error: Gdy wystąpi błąd podczas wykonywania zapytania SQL
        """
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
        """
        Aktualizuje status sprzedaży samochodu.

        Args:
            car_id (int): ID samochodu w bazie danych
            sold_status (bool): Nowy status sprzedaży (True = sprzedany)

        Raises:
            sqlite3.Error: Gdy wystąpi błąd podczas aktualizacji
        """
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("UPDATE cars SET selled=? WHERE id=?", (sold_status, car_id))
            conn.commit()

    def reset_all(self):
        """
        Resetuje statusy sprzedaży wszystkich samochodów na NULL.

        Ustawia pole 'selled' na NULL dla wszystkich rekordów w tabeli cars.

        Raises:
            sqlite3.Error: Gdy wystąpi błąd podczas resetowania
        """
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("UPDATE cars SET selled = NULL")
            conn.commit()