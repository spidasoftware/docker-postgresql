#!/bin/bash
########################################
#                                      #
#           Reset Passwords            #
#   Resets postgres and Min admin      #
#   passwords to the passwords in the  #
#   environment variables.             #
#                                      #
########################################

#generate 512 random bytes and create digest with sha512
SALT=$(head -c 512 /dev/urandom | sha512sum -b | cut -d ' ' -f 1)

#concat user password and salt and create digest with sha512
HASHED_PASSWORD=$(echo -n ${ADMIN_USER_PASSWORD}${SALT} | sha512sum | cut -d ' ' -f 1)

psql $POSTGRES_DATABASE -U $POSTGRES_USER -c "alter role $POSTGRES_USER with password '$POSTGRES_PASSWORD';"
psql $POSTGRES_DATABASE -U $POSTGRES_USER -c "update um_user_details set api_token='$ADMIN_API_TOKEN', password='$HASHED_PASSWORD', salt='$SALT' where email='admin@spidasoftware.com';"
