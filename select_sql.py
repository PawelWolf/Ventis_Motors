import sqlite3

conn = sqlite3.connect("cars.db")
cursor = conn.cursor()

cursor.execute("SELECT * FROM cars")
rows = cursor.fetchall()

for row in rows:
    print(row)

conn.close()