import os
import sys
import pyodbc
import re

server = os.getenv("DB_SERVER")
database = os.getenv("DB_NAME", "ventis-db")
username = os.getenv("DB_USER")
password = os.getenv("DB_PASSWORD")

if not all([server, database, username, password]):
    print("Blad: Brak wymaganych zmiennych srodowiskowych!")
    sys.exit(1)

conn_str = (
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"UID={username};"
    f"PWD={password};"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
    "Connection Timeout=30;"
)

def execute_sql_file(conn, cursor, file_path):
    if not os.path.exists(file_path):
        print(f"Nie znaleziono pliku: {file_path}")
        return False
    
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Rozbijamy plik za pomoca słowa GO jako osobne bloki transakcyjne
    statements = re.split(r'\bGO\b', content, flags=re.IGNORECASE)
    
    for statement in statements:
        stmt = statement.strip()
        if stmt:
            try:
                cursor.execute(stmt)
                conn.commit()  # Wymuszamy natychmiastowe zapisanie tabeli w Azure przed kolejnym krokiem!
            except Exception as e:
                if "already an object named" in str(e) or "already exists" in str(e):
                    continue
                else:
                    print(f"Blad instrukcji SQL w {file_path}: {e}")
                    if "schema.sql" in file_path:
                        raise e
    return True

try:
    print(f"Laczenie z Azure SQL: {server}...")
    # Wyłączamy autocommit, żeby kontrolować moment zapisu transakcji
    conn = pyodbc.connect(conn_str, autocommit=False)
    cursor = conn.cursor()

    print("Czyszczenie starych tabel przed świeżym wdrożeniem...")
    cursor.execute("""
        DROP TABLE IF EXISTS ServiceParts, ServiceHistory, Parts, Sales, 
                             Cars, Statuses, Employees, Customers, Series, BodyTypes;
    """)
    conn.commit()
    print("Baza zostala wyczyszczona.")

    print("Tworzenie struktury tabel (database/schema.sql)...")
    execute_sql_file(conn, cursor, "database/schema.sql")

    print("Tworzenie rekordu CustomerID = 1 dla relacji klucza obcego...")
    cursor.execute("INSERT INTO Customers (FirstName, LastName, Email, Phone) VALUES ('Pierwszy', 'Klient', 'klient@ventis.pl', '123456789')")
    conn.commit()

    print("Uruchamianie skryptu danych (database/data.sql)...")
    execute_sql_file(conn, cursor, "database/data.sql")
    print("Wstrzykiwanie danych zakonczone.")

    cursor.close()
    conn.close()
    print("Inicjalizacja bazy zakonczona sukcesem!")

except Exception as e:
    print(f"Krytyczny blad skryptu: {e}")
    sys.exit(1)