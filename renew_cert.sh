#!/bin/bash

openssl req -new -days 365 -x509 -nodes -out /etc/pki/tls/certs/localhost.crt -keyout /etc/pki/tls/private/localhost.key -subj "/C=BR/ST=RJ/L=RioDeJaneiro/O=RNP/CN=www.rnp.br"

exec "$@"
