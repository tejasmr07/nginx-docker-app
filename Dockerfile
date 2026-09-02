FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

# Copy our static site into nginx's web root
COPY index.html /usr/share/nginx/html/index.html

# Nginx listens on port 80 by default
EXPOSE 80

# Default nginx CMD already runs "nginx -g daemon off;"
CMD ["nginx", "-g", "daemon off;"]
