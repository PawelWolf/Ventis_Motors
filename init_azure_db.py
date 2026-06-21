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

def execute_sql_file(conn, cursor, file_path):
    if not os.path.exists(file_path):
        print(f"Nie znaleziono pliku: {file_path}")
        return False
    
    print(f"Wczytywanie i uruchamianie: {file_path}...")
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Usuwamy tylko twarde słowa GO z nowej linii, pozostawiając resztę nienaruszoną
    import re
    content = re.sub(r'^\s*GO\s*$', '', content, flags=re.IGNORECASE | re.MULTILINE)
    
    try:
        cursor.execute(content)
        conn.commit()
    except Exception as e:
        # Jeśli mimo to baza krzyknie o duplikacie, ignorujemy to w tym potoku
        if "already an object" in str(e) or "already exists" in str(e):
            return True
        print(f"Blad podczas wykonywania pliku {file_path}: {e}")
        raise e
    return True

try:
    print(f"Laczenie z Azure SQL: {server}...")
    conn = pyodbc.connect(conn_str, autocommit=False)
    cursor = conn.cursor()

    print("Tworzenie struktury tabel (database/schema.sql)...")
    execute_sql_file(conn, cursor, "database/schema.sql")

    print("Tworzenie rekordu CustomerID = 1...")
    try:
        cursor.execute("INSERT INTO Customers (FirstName, LastName, Email, Phone) VALUES ('Pierwszy', 'Klient', 'klient@ventis.pl', '123456789')")
        conn.commit()
    except Exception:
        pass

    print("Uruchamianie skryptu danych (database/data.sql)...")
    execute_sql_file(conn, cursor, "database/data.sql")
    print("Wstrzykiwanie danych zakonczone.")

    cursor.close()
    conn.close()
    print("Inicjalizacja bazy zakonczona sukcesem!")

except Exception as e:
    print(f"Krytyczny blad skryptu: {e}")
    sys.exit(1)