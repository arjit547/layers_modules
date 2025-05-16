# FROM httpd:2.4

# # Copy index.html to Apache's web root
# COPY index.html /usr/local/apache2/htdocs/

# # Expose port 80
# EXPOSE 80
FROM python:3.10-alpine

WORKDIR /app

COPY index.html /app/

EXPOSE 80

CMD ["python", "-m", "http.server", "80"]
