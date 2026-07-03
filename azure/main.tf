terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" 
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a Resource Group
resource "azurerm_resource_group" "main" {
  name     = "multi-cloud-security-lab"
  location = "East US"
}

# Create a Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "security-lab-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Project = "threat-detection"
  }
}

# Create a Subnet
resource "azurerm_subnet" "main" {
  name                 = "security-lab-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.1.1.0/24"]
}
# Enable Microsoft Defender for Cloud
resource "azurerm_security_center_subscription_pricing" "defender" {
  tier          = "Free"
  resource_type = "VirtualMachines"
}
# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "security-lab-workspace"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Project = "threat-detection"
  }
}
# Connect Defender for Cloud to Log Analytics Workspace
resource "azurerm_security_center_workspace" "main" {
  scope        = "/subscriptions/${var.subscription_id}"
  workspace_id = azurerm_log_analytics_workspace.main.id
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}
# Create Event Hub Namespace
resource "azurerm_eventhub_namespace" "main" {
  name                = "security-lab-eventhub"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    Project = "threat-detection"
  }
}

# Create Event Hub
resource "azurerm_eventhub" "activity_logs" {
  name                = "insights-operational-logs"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = azurerm_resource_group.main.name
  partition_count     = 2
  message_retention   = 1
}

# Create Event Hub Authorization Rule
resource "azurerm_eventhub_namespace_authorization_rule" "elastic" {
  name                = "elastic-agent-rule"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = azurerm_resource_group.main.name
  listen              = true
  send                = true
  manage              = false
}

# Output connection string
output "eventhub_connection_string" {
  value     = azurerm_eventhub_namespace_authorization_rule.elastic.primary_connection_string
  sensitive = true
}
# Send Azure Activity Logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "activity_logs" {
  name               = "security-lab-diagnostic"
  target_resource_id = "/subscriptions/${var.subscription_id}"

  eventhub_name                  = azurerm_eventhub.activity_logs.name
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.elastic.id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "Alert"
  }

  enabled_log {
    category = "Policy"
  }
}
# Create Storage Account for Event Hub checkpoints
resource "azurerm_storage_account" "elastic" {
  name                     = "seclabelastic${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Project = "threat-detection"
  }
}

resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

output "storage_account_name" {
  value = azurerm_storage_account.elastic.name
}

output "storage_account_key" {
  value     = azurerm_storage_account.elastic.primary_access_key
  sensitive = true
}
