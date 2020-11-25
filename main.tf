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

# passing array parameter to AzureRM policyset resource 

variable "policyset_definitions" {
  type        = list
  description = "array of built-in policy definitions"
  default = [
    "Allowed locations for resource groups"
  ]
}

data "azurerm_policy_definition" "policyset_definitions" {
  count        = length(var.policyset_definitions)
  display_name = var.policyset_definitions[count.index]
}

resource "azurerm_policy_set_definition" "custompolicyset" {
  name         = "CustomPolicySet"
  policy_type  = "Custom"
  display_name = "CustomPolicySet"

  parameters = <<PARAMETERS
    {
        "allowedLocations": {
            "type": "Array",
            "metadata": {
                "description": "The list of locations that resource groups can be created in.",
                "displayName": "Allowed locations",
                "strongType": "location"
            },
            "defaultValue": [
                "australiaeast",
                "australiasoutheast"
                ]
        }
    }
PARAMETERS

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.policyset_definitions.*.id[0]
    parameter_values     = <<VALUE
    {
      "listOfAllowedLocations": {"value": "[parameters('allowedLocations')]"}
    }
    VALUE
  }
}
