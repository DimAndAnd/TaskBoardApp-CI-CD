terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.12.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "StorageRG"
    storage_account_name = "dianderstoragetb"
    container_name       = "storagetaskboard"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "3bc304c3-add9-4189-bce3-5aca949922e4"
  features {
  }
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "diander_rg" {
  name     = "${var.resource_group_name}-${random_integer.ri.result}"
  location = var.resource_group_location
}

resource "azurerm_service_plan" "diander_acp" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.diander_rg.name
  location            = azurerm_resource_group.diander_rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "diander_wa" {
  name                = "${var.app_service_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.diander_rg.name
  location            = azurerm_service_plan.diander_acp.location
  service_plan_id     = azurerm_service_plan.diander_acp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserver-diander.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.Taskboarddatabase.name};User ID=${azurerm_mssql_server.sqlserver-diander.administrator_login};Password=${azurerm_mssql_server.sqlserver-diander.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

resource "azurerm_mssql_server" "sqlserver-diander" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.diander_rg.name
  location                     = azurerm_resource_group.diander_rg.location
  version                      = "12.0"
  administrator_login          = var.sql_administrator_login_username
  administrator_login_password = var.sql_administratot_password
}

resource "azurerm_mssql_database" "Taskboarddatabase" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.sqlserver-diander.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  zone_redundant = false
  sku_name       = "S0"
}

resource "azurerm_mssql_firewall_rule" "dianderfirewall" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.sqlserver-diander.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_app_service_source_control" "deploy-app" {
  app_id                 = azurerm_linux_web_app.diander_wa.id
  repo_url               = var.github_repo_url
  branch                 = "main"
  use_manual_integration = true
}