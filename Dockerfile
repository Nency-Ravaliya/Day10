# Use the official Nginx image
FROM nginx:alpine

# Copy the HTML file from the current directory into the container at /usr/share/nginx/html
COPY index.html /usr/share/nginx/html

# Expose port 80 to allow outside access to our web application
EXPOSE 80

# Command to start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]
