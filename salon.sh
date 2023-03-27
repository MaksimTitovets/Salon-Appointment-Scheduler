#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

CHOOSE_SERVICE() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
}

CHOOSE_SERVICE
SERVICE_ID_SELECTED_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
# if service doesn't available
if [[ -z $SERVICE_ID_SELECTED_AVAILABLE ]]
then
  CHOOSE_SERVICE "I could not find that service. What would you like today?"
fi

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# if customer doesn't exist
if [[ -z $CUSTOMER_NAME ]]
then
  # get new customer name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')

echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
read SERVICE_TIME

INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
