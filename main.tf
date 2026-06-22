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
  name     = "ventis-rg-2-db"
  location = "polandcentral"
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
  administrator_login          = var.db_admin_user
  administrator_login_password = var.db_admin_password

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
  storage_account_type = "Local"
  
  tags = {
    environment = "student"
  }
}

resource "azurerm_mssql_firewall_rule" "allow_all_ips" {
  name             = "AllowAllIPs"
  server_id        = azurerm_mssql_server.ventis_sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

# Dodatek: Generator losowej liczby dla unikalnej nazwy serwera
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}
resource "azurerm_linux_web_app" "ventis_app" {
  name                = "ventis-motors-app-2-db"
  location            = azurerm_resource_group.ventis.location
  resource_group_name = azurerm_resource_group.ventis.name
  service_plan_id     = azurerm_service_plan.ventis_plan.id

    site_config {
    always_on = false
    application_stack {
        docker_image_name = "pawelwolf/ventis2db:latest"
    }
}
  app_settings = {
    WEBSITES_PORT = "5000"
  }
}
variable "db_admin_user" {
  type        = string
  description = "Nazwa administratora bazy danych"
  sensitive   = true
}

variable "db_admin_password" {
  type        = string
  description = "Haslo administratora bazy danych"
  sensitive   = true
}
