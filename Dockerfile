FROM python:3.10-alpine

WORKDIR /app

COPY index.html /app/

EXPOSE 80

CMD ["python", "-m", "http.server", "80"]
