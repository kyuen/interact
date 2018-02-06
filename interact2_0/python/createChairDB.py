import sqlite3

#user variables
dbname = "Chairs.db"
createChairTable = 'CREATE TABLE IF NOT EXISTS chairs(Id INTEGER PRIMARY KEY, markerId INTEGER, ip_str VARCHAR(13), twitterAcct VARCHAR(20), twitterPass VARCHAR(20), OAuthK VARCHAR(30), OAuthS VARCHAR(30), accessToken VARCHAR(30), accessTokenS VARCHAR(30) )'
createPeopleTable = 'CREATE TABLE IF NOT EXISTS users(Id INTEGER PRIMARY KEY, firstName VARCHAR(50), lastName VARCHAR(50), uid VARCHAR(20), twitterAcct VARCHAR(20), twitterPass VARCHAR(20), OAuthK VARCHAR(30), OAuthS VARCHAR(30), accessToken VARCHAR(30), accessTokenS VARCHAR(30) )'

con = sqlite3.connect(dbname)
cur = con.cursor()
cur.execute('DROP TABLE IF EXISTS chairs')
con.commit()
cur.execute('DROP TABLE IF EXISTS users')
con.commit()
cur.execute(createPeopleTable)
con.commit()
cur.execute(createChairTable)
con.commit()
print("db created")