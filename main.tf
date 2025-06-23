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
