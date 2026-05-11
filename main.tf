terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.91.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "ventis" {
  name     = "ventis-rg"
  location = "westeurope"
}

resource "azurerm_service_plan" "ventis_plan" {
  name                = "ventis-serviceplan"
  location            = azurerm_resource_group.ventis.location
  resource_group_name = azurerm_resource_group.ventis.name

  os_type    = "Linux"
  sku_name   = "F1"
}
resource "azurerm_mssql_server" "ventis_sql_server" {
  name                         = "ventis-sql-server-${random_integer.ri.result}" # Unikalna nazwa dzieki funkcji random_integer
  resource_group_name          = azurerm_resource_group.ventis.name
  location                     = azurerm_resource_group.ventis.location
  version                      = "12.0"
  administrator_login          = "wilqu"             # TWOJA NAZWA UŻYTKOWNIKA
  administrator_login_password = "pawel2137"       # TWOJE HASŁO (zmień to!)

  tags = {
    environment = "student"
  }
}

# 2. Baza danych (Plan BASIC - najtańszy)
resource "azurerm_mssql_database" "ventis_db" {
  name         = "ventis-db"
  server_id    = azurerm_mssql_server.ventis_sql_server.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "BasePrice"
  sku_name     = "Basic" # koszt około 5 USD miesięcznie UWAGAAAA: Ten koszt jest naliczany nawet jeśli baza danych jest pusta, więc pamiętaj o usunięciu zasobów po zakończeniu ćwiczenia!

  tags = {
    environment = "student"
  }
}

# 3. Firewall: Pozwól usługom Azure (Twojej aplikacji) na dostęp do bazy
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.ventis_sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# 4. Firewall: Pozwól Twojemu komputerowi na dostęp (do wgrania schematu)
# SPRAWDZENIE IP 'whatismyip.com' LUB 'ipinfo.io/ip'
resource "azurerm_mssql_firewall_rule" "allow_my_ip" {
  name             = "AllowMyIP"
  server_id        = azurerm_mssql_server.ventis_sql_server.id
  start_ip_address = "83.168.79.102" # Tutaj wpisz swoje IP 
  end_ip_address   = "83.168.79.102"  # Tutaj wpisz swoje IP (może być takie samo jak start_ip_address)
}

# Dodatek: Generator losowej liczby dla unikalnej nazwy serwera
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}
resource "azurerm_linux_web_app" "ventis_app" {
  name                = "ventis-motors-app"
  location            = azurerm_resource_group.ventis.location
  resource_group_name = azurerm_resource_group.ventis.name
  service_plan_id     = azurerm_service_plan.ventis_plan.id

    site_config {
    always_on = false
    application_stack {
        docker_image_name = "pawelwolf/ventis"
    }
}
  app_settings = {
    WEBSITES_PORT = "5000"
  }
}
