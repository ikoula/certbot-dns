#!/bin/bash


#Auth Basic, il faut rémplacer le hash base64 par le votre que nous pouvons générer avec la commande : echo -n user:password | base64
AUTH=

# Vérification de la connexion
CHECKLOG=$(curl -s --location --request GET 'https://commande.ikoula.com/api/dns' --header 'Authorization: Basic '$AUTH | jq -r '.error[]' 2>/dev/null)
if [[  $CHECKLOG ]]; then
        echo -e 'Erreur de connexion :'
        echo $CHECKLOG
        exit 1
fi



# Récupération de domaiene root de la zone :
DOMAIN_ROOT=$(for domain in $(curl -s --location --request GET 'https://commande.ikoula.com/api/dns' \
        --header 'Authorization: Basic '$AUTH | jq -r '.zones[].name')
do
        if [[ $(echo $CERTBOT_DOMAIN | grep -c $domain) = 1 ]];then
                echo $domain
        fi
done)

# Vérification du domaine


if [[ -z  $DOMAIN_ROOT ]]; then
                echo -e "La zone DNS du domaine "$CERTBOT_DOMAIN" ne peut pas être modifié"
                                exit 1
fi


#ServiceID
SERVICE_ID=$(curl -s --location --request GET 'https://commande.ikoula.com/api/dns' \
--header 'Authorization: Basic '$AUTH | \
jq -r '.zones[] | select(.name=='\"$DOMAIN_ROOT\"')| .service_id')


#ZoneID
ZONE_ID=$(curl -s --location --request GET 'https://commande.ikoula.com/api/dns' \
--header 'Authorization: Basic '$AUTH | \
jq -r '.zones[] | select(.name=='\"$DOMAIN_ROOT\"')| .domain_id')


#Création de l'enregistrement DNS
curl -s --location --request POST 'https://commande.ikoula.com/api/service/'$SERVICE_ID'/dns/'$ZONE_ID'/records' \
--header 'Authorization: Basic '$AUTH \
--header 'Content-Type: application/json' \
--data-raw '        {
                "id": "",
            "name": "_acme-challenge.'$CERTBOT_DOMAIN'",
            "type": "TXT",
            "content": "'$CERTBOT_VALIDATION'",
            "ttl": "120"
        }' > /dev/null
echo 'En attente de vérification'

#Record_ID
REC_ID=$(curl -s --location --request GET 'https://commande.ikoula.com/api/service/'$SERVICE_ID'/dns/'$ZONE_ID'' \
--header 'Authorization: Basic '$AUTH | \
jq -r '.records[] | select((.type=="TXT") and (.content=='\"$CERTBOT_VALIDATION\"') and (.name=="_acme-challenge.'$CERTBOT_DOMAIN'")) | .id')

#Inscription des vériables pour pouvoir réalier le cleanup
echo  '{"service": "'$SERVICE_ID'", "zone": "'$ZONE_ID'", "record": "'$REC_ID'" }'  >  /tmp/$CERTBOT_DOMAIN
sleep 120
