FROM nginx:alpine

COPY app /usr/share/nginx/html

RUN mkdir /efs-app2048

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
