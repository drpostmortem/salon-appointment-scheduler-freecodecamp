#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~Welcome to the Salon~~~~\n"


DISPLAY_SERVICES(){
  if [[ $1 ]]
  then
    echo -e "\n"$1
  fi

  SERVICES=$($PSQL "select * from services;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    if [[ $SERVICE_ID =~ ^[0-9]+ ]]
    then
      echo "$SERVICE_ID) $SERVICE_NAME"
    fi
  done
  
  echo "Please select a service: "
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    DISPLAY_SERVICES "Please enter a valid service id"
  else
    SERVICE_ID=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED ;")
    if [[ -z $SERVICE_ID ]]
    then
      DISPLAY_SERVICES "Cannot find that service."
    else
      echo "Please enter your phone number: "
      read CUSTOMER_PHONE
      EXISTING_CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
      if [[ -z $EXISTING_CUSTOMER_NAME ]]
      then
        echo "You're new. Please enter your name: "
        read CUSTOMER_NAME
        ADD_CUSTOMER_RESULT=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME') ;")
      fi

      echo "Please enter your preferred time: "
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      SERVICE_NAME=$(echo $($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED") | sed 's/^ +| +$//g')
      C_NAME=$(echo $($PSQL "select name from customers where customer_id=$CUSTOMER_ID") | sed 's/^ +| +$//g')
      
      ADD_APPOINTMENT_RESULT=$($PSQL "insert into appointments (time, customer_id, service_id) values('$SERVICE_TIME',$CUSTOMER_ID,$SERVICE_ID) ;")
      
      echo "I have put you down for a "$SERVICE_NAME" at "$SERVICE_TIME", "$C_NAME"."

      
    fi
  fi
}






DISPLAY_SERVICES
