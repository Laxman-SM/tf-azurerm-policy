terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.37.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "vystmo-inc"

    workspaces {
      name = "gh-actions-demo"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

variable "policy_definition_category" {
  type        = string
  description = "The category to use for all Policy Definitions"
  default     = "Custom"
}

resource "azurerm_policy_definition" "auditRoleAssignmentType_user" {
  name         = "auditRoleAssignmentType_user"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Audit user role assignments"
  description  = "This policy checks for any Role Assignments of Type [User] - useful to catch individual IAM assignments to resources/RGs which are out of compliance with the RBAC standards e.g. using Groups for RBAC."

  metadata = <<METADATA
    {
    "category": var.policy_definition_category,
    "version" : "1.0.0"
    }
METADATA


  policy_rule = <<POLICY_RULE
    {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Authorization/roleAssignments"
        },
        {
          "field": "Microsoft.Authorization/roleAssignments/principalType",
          "equals": "[parameters('principalType')]"
        }
      ]
    },
    "then": {
      "effect": "audit"
    }
  }
POLICY_RULE


  parameters = <<PARAMETERS
    {
    "principalType": {
      "type": "String",
      "metadata": {
        "displayName": "principalType",
        "description": "Which principalType to audit against e.g. 'User'"
      },
      "allowedValues": [
        "User",
        "Group",
        "ServicePrincipal"
      ],
      "defaultValue": "User"
    }
  }
PARAMETERS

}

/**

output "auditRoleAssignmentType_user_policy_id" {
  value       = azurerm_policy_definition.auditRoleAssignmentType_user.id
  description = "The policy definition id for auditRoleAssignmentType_user"
}

**/
