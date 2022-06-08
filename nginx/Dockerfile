FROM nginx


RUN rm /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf /usr/share/nginx/html/*
COPY src /usr/share/nginx/html
COPY nginx.conf /etc/nginx
