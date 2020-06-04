# Let's encrypt DNS challenge 

# Usage
```shell
bash <(curl -s https://raw.githubusercontent.com/ikoula/certbot-dns/master/install.sh)

certbot certonly \
  --manual \
  --preferred-challenges=dns \
  --manual-auth-hook /usr/local/bin/ikoula-dns-auth.sh 
  --manual-cleanup-hook /usr/local/bin/ikoula-dns-cleanup.sh \
  -d domaine.tld

```

