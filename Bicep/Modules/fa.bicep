targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

param tags array = [
  
]

@description('Name of the storage account to connect against.')
param storageAccountName string

@description('accountKey of the storage account to connect against.')
@secure()
param storageAccountKey string

@description('The name of the function app that you wish to create.')
param appName string

param runtime string = 'dotnet-isolated'

var functionAppName = appName
var hostingPlanName = appName

param appInsightsInstrumentationKey string
param appInsightsConnectionString string

param appSettings array = []

param keyVaultUri string

param cosmosDbEndpoint string
param cosmosDbKey string

param serverFarmId string

/*
resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  //kind: 'linux'
  sku: {
    name: 'EP1'
    //tier: 'Dynamic'
    //capacity: 1
  }
  properties: {
      reserved: true
  }
}*/
// 
param applicationSubnet string
param functionAppSubnet string
param privateIpAdress string

resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp' // ,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    virtualNetworkSubnetId: functionAppSubnet
    vnetContentShareEnabled: true
    vnetRouteAllEnabled: true
    publicNetworkAccess: 'Disabled'
    serverFarmId: serverFarmId
    siteConfig: {
      linuxFxVersion:'DOTNET-ISOLATED|8.0'
      appSettings: union(appSettings, [ // union input appsettings with default appsettings
        { 
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccountKey}'
        }  
        {
          name: 'KeyVaultUri'
          value: keyVaultUri
        }        
        {
          name: 'CosmosEndpointUri'
          value: cosmosDbEndpoint
        }
        {
          name: 'CosmosPrimaryKey'
          value: cosmosDbKey
        }
       
        {
          name: 'CosmosConnectionString'
          value: cosmosDbEndpoint
        }        
        /*{
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccountKey}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }*/
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtime
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
      ])
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

output name string = functionApp.name
output principalId string = functionApp.identity.principalId

/*
var managedIdentityName = '${functionAppName}ManagedIdentity'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

@description('This is the built-in Key Vault Administrator role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-administrator')
resource keyVaultAdministratorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(functionApp.id, managedIdentity.id, keyVaultAdministratorRoleDefinition.id)
  properties: {
    roleDefinitionId: keyVaultAdministratorRoleDefinition.id
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
*/
