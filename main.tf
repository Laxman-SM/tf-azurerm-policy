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

/**
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
    "category": "var.policyset_definition_category"
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

output "auditRoleAssignmentType_user_policy_id" {
  value       = azurerm_policy_definition.auditRoleAssignmentType_user.id
  description = "The policy definition id for auditRoleAssignmentType_user"
}

**/

########################################################################################

resource "azurerm_role_definition" "roleDefinitions__policymanager" {
  name               = "Gap Policy Manager"
  role_definition_id = ""
  description        = "Lets you manage policies."
  scope              = ""

  permissions {
    data_actions = []

    not_data_actions = []

    actions = [
      "Microsoft.Authorization/PolicyDefinitions/*",
      "Microsoft.Authorization/policySetDefinitions/*",
      "Microsoft.Authorization/policyAssignments/*",
    ]

    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/48083211-8473-4e32-bc11-f0058b227fd5",
    "/subscriptions/8534e7bb-0c6b-4358-9861-7e972e81a5ea",
  ]
}

