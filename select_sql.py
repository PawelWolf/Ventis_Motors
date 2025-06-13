import sqlite3

# Połącz z bazą
conn = sqlite3.connect("cars.db")
cursor = conn.cursor()

# Pobierz wszystkie rekordy
cursor.execute("SELECT * FROM cars")
rows = cursor.fetchall()

# Wyświetl każdy rekord
for row in rows:
    print(row)

# Zamknij połączenie
conn.close()