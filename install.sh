#!/bin/bash

# Véification des dépendances
if [[ ! -f $(which jq) ]];then
echo 'jq est nécessaire, installer le pour continuer'
exit
fi
if [[ ! -f $(which curl) ]];then
echo 'curl est nécessaire, installer le pour continuer'
exit
fi

# Construction du hash de l'authentification basic de l'API
echo "Afin d'éxecuter les appels API, vous devez fourir un compte disposant de la permission de gestion de la zone DNS"
echo -n "Utilisateur : "; read user
echo -n "Mot de passe : "; read -s pass
echo -e "\n"
basicauth=$(echo -n $user:$pass | base64)

curl -s https://raw.githubusercontent.com/ikoula/certbot-dns/master/ikoula-dns-auth.sh  | sed s/^AUTH=/AUTH=\"$basicauth\"/g \
        > /usr/local/bin/ikoula-dns-auth.sh
chmod +x /usr/local/bin/ikoula-dns-auth.sh
curl -s https://raw.githubusercontent.com/ikoula/certbot-dns/master/ikoula-dns-cleanup.sh  | sed s/^AUTH=/AUTH=\"$basicauth\"/g \
        > /usr/local/bin/ikoula-dns-cleanup.sh
chmod +x /usr/local/bin/ikoula-dns-cleanup.sh

echo -e "Les script sont utilisable\n Vous pouvez à présent utiliser l'authentification par DNS comme dans l'exemple ci-dessous :\n"
echo -e "certbot certonly --manual --preferred-challenges=dns --manual-auth-hook /usr/local/bin/ikoula-dns-auth.sh --manual-cleanup-hook /usr/local/bin/ikoula-dns-cleanup.sh -d domaine.tld"
