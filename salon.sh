#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Salon appointments manager ~~\n"

BOOK_APPOINTMENT(){
	
	echo -e "\nWelcome to My Salon. Please, chose a service number to book an appointement :"
	read SERVICE_ID_SELECTED 
	GET_SERVICE_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
	if [[ -z $GET_SERVICE_RESULT ]]
	then
		echo -e "\nThe service you give is not in the list of services available. Please chose a service in the list below."
		SERVICE_MENU
	else
		echo -e "\nWhat's your phone number ?"
		read CUSTOMER_PHONE
		GET_PHONE_RESULT=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
		if [[ -z $GET_PHONE_RESULT ]]
		then 
			echo -e "\nI don't have a record for that phone number. Customer not found in base.\nPlease give customer name:"
			read CUSTOMER_NAME
			INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
		fi
		GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
		echo -e "\nTime of the appointment, $CUSTOMER_NAME?"
		read  SERVICE_TIME
	
		INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($GET_SERVICE_RESULT, $GET_CUSTOMER_ID, '$SERVICE_TIME')")

		if [[ ! -z $INSERT_APPOINTMENT_RESULT ]]
		then
			GET_APPOINTMENT_RESULT=$($PSQL "SELECT services.name, time, customers.name FROM appointments INNER JOIN customers USING(customer_id) INNER JOIN services USING(service_id) WHERE time='$SERVICE_TIME'")
			GET_APPOINTMENT_FORMATED=$(echo $GET_APPOINTMENT_RESULT | sed 's/|/at/')
			GET_APPOINTMENT_FORMATED=$(echo $GET_APPOINTMENT_FORMATED | sed 's/ |/,/')
			echo -e "I have put you down for a $GET_APPOINTMENT_FORMATED."
		fi
	fi

}

# display services
SERVICE_MENU(){

	if [[ $1 ]]
	then
		echo -e "\n$1"
	fi

	echo "Services available:"
	AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")

	#if no service available
	if [[ -z $AVAILABLE_SERVICES ]]
	then
		echo -e "\nSorry there is no available service. Try again when at least one service will be available again."
	else
		echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
		do
			echo -e	"$SERVICE_ID) $SERVICE_NAME"
		done
		BOOK_APPOINTMENT
	fi
}

SERVICE_MENU
