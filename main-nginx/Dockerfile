FROM nginx:latest
# remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf
# setup ssl certs
COPY ./nginx-selfsigned.crt /etc/ssl/certs/nginx-selfsigned.crt
COPY ./nginx-selfsigned.key /etc/ssl/private/nginx-selfsigned.key
# move over config files
COPY ./nginx.conf /etc/nginx/
COPY main.conf.template /etc/nginx/templates/
EXPOSE 80 443
LABEL org.opencontainers.image.source=https://github.com/jack60612/easyID-server
LABEL org.opencontainers.image.description="Image for the easyID Nginx server"
