sed -i -e "/DOMAIN/c\DOMAIN=http://$APP_DOMAIN" E2Etest/.env
cd E2Etest && npm test
