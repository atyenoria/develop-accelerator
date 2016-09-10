sed -i -e "/APP_DOMAIN/c\      APP_DOMAIN: \"$APP_DOMAIN\"" main/docker-compose.yml
sed -i -e "/DB_DOMAIN/c\      DB_DOMAIN: \"$DB_DOMAIN\"" main/docker-compose.yml
sed -i -e "/LOCAL_DEV/c\      LOCAL_DEV: \"false\"" main/docker-compose.yml