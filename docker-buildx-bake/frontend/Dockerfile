# Use a lightweight web server for static files
FROM nginx:alpine

# Copy static files to the default Nginx web root
COPY . /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
