# Dockerfile dla Ventis Motors
FROM python:3.11-slim

# Ustawienie zmiennych środowiskowych
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Instalacja sterowników i zależności systemowych
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    unixodbc-dev \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Kopiowanie i instalacja wymagań Pythona
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Ekspozycja portu zgodna z WEBSITES_PORT w main.tf
EXPOSE 5000

# Start aplikacji
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]