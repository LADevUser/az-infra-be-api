targetScope = 'resourceGroup'
param location string
param service string
param environment string
param owner string
@minLength(3)
@maxLength(24)
param keyVaultName string
param kvSkuName string
param secretstocreate array

@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param objectId string

@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = false

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = false

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = false

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
          keys: [
            'all'
          ]
        }
      }
    ]
    sku: {
      name: kvSkuName
      family: 'A'
    }
  }
  tags: {
    DisplayName: 'Key Vault'
    Service: service
    Environment: environment
    Owner: owner
  }
}



resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = [for (name, i) in secretstocreate:{
  name: string(split(name,':')[0])
  parent: kv
  properties: {
    value: string(split(name,':')[1])
  }
}]
