openssl req -x509 -days 365 -new -key nginx-selfsigned.key -out nginx-selfsigned.crt -subj "/CN=easyid-server.local/C=US/ST=FL/O=Myriad Networks" -addext "subjectAltName=DNS:easyid-server.local,DNS:localhost,IP:127.0.0.1"