#!/bin/bash


AUTH=
SERVICE=$(jq -r .service < /tmp/$CERTBOT_DOMAIN)
ZONE=$(jq -r .zone < /tmp/$CERTBOT_DOMAIN)
RECORD=$(jq -r .record < /tmp/$CERTBOT_DOMAIN)


curl -s --location --request DELETE 'https://commande.ikoula.com/api/service/'$SERVICE'/dns/'$ZONE'/records/'$RECORD \
        --header 'Authorization: Basic '$AUTH > /dev/null
