variable "resource_group_name" {
  type        = string
  description = "Resource group name in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "Resource group location in Azure"
}

variable "app_service_plan_name" {
  type        = string
  description = "Name of the app service plan"
}

variable "app_service_name" {
  type        = string
  description = "Name of the app service name"
}

variable "sql_server_name" {
  type        = string
  description = "Name of the sql server"
}

variable "sql_database_name" {
  type        = string
  description = "Name of the sql database"
}

variable "sql_administrator_login_username" {
  type        = string
  description = "sql admin user"
}

variable "sql_administratot_password" {
  type        = string
  description = "sql admin pass"
}

variable "firewall_rule_name" {
  type        = string
  description = "Name of the firewall rule"
}

variable "github_repo_url" {
  type        = string
  description = "URL of the GitHub repo"
}