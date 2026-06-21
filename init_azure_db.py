import os
import sys
import pyodbc

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

def execute_full_file(conn, cursor, file_path):
    if not os.path.exists(file_path):
        print(f"Nie znaleziono pliku: {file_path}")
        return False
    
    print(f"Wczytywanie i uruchamianie: {file_path}...")
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Pozbywamy się ewentualnych ukrytych instrukcji GO w tekście, jeśli jakieś zostały
    content = content.replace("GO\n", "\n").replace("GO\r", "\r")
    
    try:
        cursor.execute(content)
        conn.commit()
    except Exception as e:
        print(f"Blad podczas wykonywania pliku {file_path}: {e}")
        raise e
    return True

try:
    print(f"Laczenie z Azure SQL: {server}...")
    conn = pyodbc.connect(conn_str, autocommit=False)
    cursor = conn.cursor()

    print("Czyszczenie starych tabel przed świeżym wdrożeniem...")
    cursor.execute("""
        DROP TABLE IF EXISTS ServiceParts, ServiceHistory, Parts, Sales, 
                             Cars, Statuses, Employees, Customers, Series, BodyTypes;
    """)
    conn.commit()
    print("Baza zostala wyczyszczona.")

    print("Tworzenie struktury tabel i triggera...")
    execute_full_file(conn, cursor, "database/schema.sql")

    print("Tworzenie rekordu CustomerID = 1...")
    cursor.execute("INSERT INTO Customers (FirstName, LastName, Email, Phone) VALUES ('Pierwszy', 'Klient', 'klient@ventis.pl', '123456789')")
    conn.commit()

    print("Uruchamianie skryptu danych...")
    execute_full_file(conn, cursor, "database/data.sql")
    print("Wstrzykiwanie danych zakonczone.")

    cursor.close()
    conn.close()
    print("Inicjalizacja bazy zakonczona sukcesem!")

except Exception as e:
    print(f"Krytyczny blad skryptu: {e}")
    sys.exit(1)