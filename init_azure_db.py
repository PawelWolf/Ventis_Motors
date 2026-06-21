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
    
    # Pancerny podział: wyłapuje 'GO' otoczone dowolnymi białymi znakami lub liniami
    statements = re.split(r'^\s*GO\s*$', content, flags=re.IGNORECASE | re.MULTILINE)
    
    for statement in statements:
        stmt = statement.strip()
        if stmt:
            try:
                cursor.execute(stmt)
                conn.commit()
            except Exception as e:
                # Jeśli obiekt już istnieje, ignorujemy i idziemy dalej
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

    print("Czyszczenie starych tabel przed świeżym wdrożeniem...")
    # Usuwamy tabele w kolejności zależności kluczy obcych
    for table in ["ServiceParts", "ServiceHistory", "Parts", "Sales", "Cars", "Statuses", "Employees", "Customers", "Series", "BodyTypes"]:
        try:
            cursor.execute(f"DROP TABLE IF EXISTS {table};")
            conn.commit()
        except Exception:
            pass
    print("Baza zostala wyczyszczona.")

    print("Tworzenie struktury tabel (database/schema.sql)...")
    execute_sql_file_safely(conn, cursor, "database/schema.sql")

    print("Tworzenie automatycznego triggera magazynowego...")
    trigger_sql = """
    CREATE TRIGGER TR_OdejmijZMagazynu
    ON ServiceParts
    AFTER INSERT
    AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE p
        SET p.StockQuantity = p.StockQuantity - i.Quantity
        FROM Parts p
        INNER JOIN inserted i ON p.PartID = i.PartID;
    END;
    """
    try:
        cursor.execute(trigger_sql)
        conn.commit()
        print("Trigger zostal pomyslnie utworzony.")
    except Exception as e:
        if "already exists" in str(e) or "already an object" in str(e):
            print("Trigger juz istnieje, pomijam.")
        else:
            raise e

    print("Tworzenie rekordu CustomerID = 1...")
    try:
        cursor.execute("INSERT INTO Customers (FirstName, LastName, Email, Phone) VALUES ('Pierwszy', 'Klient', 'klient@ventis.pl', '123456789')")
        conn.commit()
    except Exception:
        pass

    print("Uruchamianie skryptu danych (database/data.sql)...")
    execute_sql_file_safely(conn, cursor, "database/data.sql")
    print("Wstrzykiwanie danych zakonczone.")

    cursor.close()
    conn.close()
    print("Inicjalizacja bazy zakonczona sukcesem!")

except Exception as e:
    print(f"Krytyczny blad skryptu: {e}")
    sys.exit(1)