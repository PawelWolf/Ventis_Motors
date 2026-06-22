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

def execute_sql_file_safely(conn, cursor, file_path):
    if not os.path.exists(file_path):
        print(f"Nie znaleziono pliku: {file_path}")
        return False
    
    print(f"Wczytywanie i uruchamianie: {file_path}...")
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Podział pliku na paczki komend według słowa GO na początku/końcu linii
    statements = re.split(r'^\s*GO\s*$', content, flags=re.IGNORECASE | re.MULTILINE)
    
    for statement in statements:
        stmt = statement.strip()
        if stmt:
            try:
                cursor.execute(stmt)
                conn.commit()
            except Exception as e:
                # Jeśli mimo czyszczenia obiekt już istnieje, ignorujemy duplikat
                if "already an object named" in str(e) or "already exists" in str(e):
                    continue
                else:
                    print(f"Blad instrukcji w {file_path}: {e}")
                    raise e
    return True

try:
    print(f"Laczenie z Azure SQL: {server}...")
    conn = pyodbc.connect(conn_str, autocommit=False)
    cursor = conn.cursor()

    # --- KROK 1: PEŁNE ZAORANIE BAZY PRZED KAZDYM URUCHOMIENIEM ---
    print("Czyszczenie starych tabel przed świeżym wdrożeniem...")
    for table in ["ServiceParts", "ServiceHistory", "Parts", "Sales", "Cars", "Statuses", "Employees", "Customers", "Series", "BodyTypes"]:
        try:
            cursor.execute(f"DROP TABLE IF EXISTS {table};")
            conn.commit()
        except Exception as e:
            print(f"Pominięto usuwanie tabeli {table}: {e}")
    print("Baza zostala wyczyszczona.")

    # --- KROK 2: STWORZENIE CZYSYCH TABEL Z PLIKU SCHEMATU ---
    print("Tworzenie struktury tabel (database/schema.sql)...")
    execute_sql_file_safely(conn, cursor, "database/schema.sql")

    # --- KROK 3: WYMUSZENIE REKORDU CUSTOMER ID = 1 DLA RELACJI W DATA.SQL ---
    print("Tworzenie rekordu CustomerID = 1...")
    try:
        cursor.execute("INSERT INTO Customers (FirstName, LastName, Email, Phone) VALUES ('Pierwszy', 'Klient', 'klient@ventis.pl', '123456789')")
        conn.commit()
    except Exception:
        pass

    # --- KROK 4: ZASILENIE DANYCH I URUCHOMIENIE GENERATORA DANYCH ---
    print("Uruchamianie skryptu danych (database/data.sql)...")
    execute_sql_file_safely(conn, cursor, "database/data.sql")
    print("Wstrzykiwanie danych i losowanie sprzedazy zakonczone.")

    cursor.close()
    conn.close()
    print("Inicjalizacja bazy zakonczona sukcesem!")

except Exception as e:
    print(f"Krytyczny blad skryptu: {e}")
    sys.exit(1)