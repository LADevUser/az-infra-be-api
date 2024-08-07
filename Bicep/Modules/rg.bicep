targetScope = 'subscription'
param location string
param service string
param environment string
param owner string
param resourceGroupName string
param resourceDoesntExist bool
//= if(resourceDoesntExist)

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = if(resourceDoesntExist) {
  name: resourceGroupName
  location: location
  properties: {}
  tags: {
    DisplayName: 'Resource Group'
    Service: service
    Environment: environment
    Owner: owner
  }
}
