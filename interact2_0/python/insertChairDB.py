import sqlite3

#user variables
dbname = "Chairs.db"
insertUser1 = 'INSERT INTO users(Id, firstName, lastName, uid, twitterAcct, twitterPass, OAuthK, OAuthS, accessToken, accessTokenS)VALUES(NULL, "Don", " Gately", "2641545507", "gately_don", "jj88jj88", "toITKfmJ2EjTyy7omuKssA", "kCrxHVr9HLbzK73mwRBMwYnUNJjnkOE3YyJnXS9Z0", "1372928143-2AIKNscTfcoXWVsRPA5v7mCil4ZJtwiCUi7FGlq", "JGdyjx4Y9synmTr9XmIOvdbyW9BwRmCsddXt0HM1zQ")'
insertUser2 = 'INSERT INTO users(Id, firstName, lastName, uid, twitterAcct, twitterPass, OAuthK, OAuthS, accessToken, accessTokenS)VALUES(NULL, "Joelle", "Van Dyne", "1028901411", "dyne_joelle", "jj88jj88", "5PfwPx6M2SqtveyH0DeGA", "IutdAchVQYDTYeDqwTHmUEn9KIo9YaNbFoMbJak0", "1372972266-RX3VsYZIK7uYVQsRU3vjPEI65CHbFkNHzopwCqX", "iYZUL3SIrMo1BeZWRARX76pUWtQ2tZQPN7FWxrydAg0")'
insertUser3 = 'INSERT INTO users(Id, firstName, lastName, uid, twitterAcct, twitterPass, OAuthK, OAuthS, accessToken, accessTokenS)VALUES(NULL, "Kate", "Gompert ", "174540006", "kategompert1", "jj88jj88", "MG47XcABiYiJ7vcPCMHkVw", "W3sy6BdLdpRu15EZubznTwRlt0J77Duv4AprjMxHs", "1373107124-poLm5cnLlxUJ2fuZ2I1pyHlwKKdlA6UPfLDKzTB", "TiOxDSeYEr6nftIjFult85owNs2cvajnSi14Tbw8")'
insertUser4 = 'INSERT INTO users(Id, firstName, lastName, uid, twitterAcct, twitterPass, OAuthK, OAuthS, accessToken, accessTokenS)VALUES(NULL, "Hester", "Thrale", "4210319334", "ThraleHester", "jj88jj88", "L9zStIh1sViRptahLzkbeg", "dRRaPaHul53Jjmyvaneuik4Ubtlv9Wo0mSdePOSzRZ4", "1373122896-r0YZLmlCLSMSy4PhKsVSYNyTWCZF1P7jx3Y92Db", "q1e6an9qzsS53yq3prp7acYdJPZKvUq1epM1aRnH7o")'

insertChair1 = 'INSERT INTO chairs(Id, markerId, ip_str, twitterAcct, twitterPass, OAuthK, OAuthS, accessToken, accessTokenS)VALUES(NULL, 0, "172.16.2.5", "one_chair", "jj88jj88", "3XVQk7ecXuP1HNQG2AGw", "NLohogowAhb72H7gA0LKn65mqknjE8soCl7PiYHvUs8", "1606946755-b10YpJxnEab14IlrpPKxdGB5bcqimmJcsv4w0lm", "i9KDs6EAXak1DLPk7UN3TCO0XvxX7T1AurLbY6T8eQ")'
insertChair2 = 'INSERT INTO chairs(Id, markerId, ip_str, twitterAcct, twitterPass, OAuthK, OAuthS, accessToken, accessTokenS)VALUES(NULL, 1, "172.16.2.6", "chair_two", "jj88jj88", "mbYMuSbASzBcOOfqSkd5w", "QJ5nwhEXVy3jDyzhTZsB6ydtUOXei8xUeYOwIkfUWk", "1606858116-LOFP9OTOQzYQqlk4WIzQMyLYfCU7f1arLwhyn80", "6KgN9ELXDBC9xRewmGgTipowDlr6jaR5sz28WaOtCQ")'
insertChair3 = 'INSERT INTO chairs(Id, markerId, ip_str, twitterAcct, twitterPass, OAuthK, OAuthS, accessToken, accessTokenS)VALUES(NULL, 2, "172.16.2.7", "chair_three", "jj88jj88", "VNOy6PNq4MTSpnUe2kg6Hw", "DF87yODeWxWyFAC0lXOgpwUf6OgbVujeZea6fVxXc", "1606839600-X1UNZYOk4A5QtXqHKovdIU4uX8H45L3k6THqAPo", "GqxoKXjdn4T9NZRcHVulHYpiEjCSELawPPPa85L2T5A")'
#insertChair4 = 'INSERT INTO users(Id, markerId, ip_str, twitterAcct, twitterPass, OAuthK, OAuthS, accessToken, accessTokenS)VALUES(NULL, 3, "172.16.2.6", "ThraleHester", "jj88jj88", "L9zStIh1sViRptahLzkbeg", "dRRaPaHul53Jjmyvaneuik4Ubtlv9Wo0mSdePOSzRZ4", "1373122896-r0YZLmlCLSMSy4PhKsVSYNyTWCZF1P7jx3Y92Db", "q1e6an9qzsS53yq3prp7acYdJPZKvUq1epM1aRnH7o")'


con = sqlite3.connect(dbname)
cur = con.cursor()
cur.execute(insertUser1)
con.commit()
cur.execute(insertUser2)
con.commit()
cur.execute(insertUser3)
con.commit()
cur.execute(insertUser4)
con.commit()
cur.execute(insertChair1)
con.commit()
cur.execute(insertChair2)
con.commit()
cur.execute(insertChair3)
con.commit()
print("users inserted")