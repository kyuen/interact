import sqlite3

#user variables
dbname = "Chairs.db"
query = 'SELECT COUNT(*) FROM users'
query1 = 'SELECT * FROM users'
query2 = 'SELECT COUNT(*) FROM chairs'
query3 = 'SELECT * FROM chairs'

con = sqlite3.connect(dbname)
cur = con.cursor()
cur.execute(query)
print(cur.fetchone()[0])
con.commit()
cur.execute(query1)
print(cur.fetchall())
con.commit()
