targetScope = 'resourceGroup'
param sku string
param tier string
param capacity int
param location string
param service string
param environment string
param owner string
param appServicePlanName string
param WebbAppNames array
param saconnectionstring string


resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
    name: appServicePlanName
    location: location
	properties: {
    reserved: true
	}
    sku: {
        name: sku
        tier: tier
        capacity: capacity
    }
    kind: 'linux'
    tags: {
        DisplayName: 'App Service Plan'
        Service: service
        Environment: environment
        Owner: owner
    }
}

output serverfarmid string = appServicePlan.id

 // resource appService 'Microsoft.Web/sites@2020-06-01' = [for (WebbAppName,i) in WebbAppNames: {
 //   name: WebbAppName
 //   location: location
 //   kind: 'webbapp'
 //   properties: {
 //     httpsOnly: true
 //     serverFarmId: appServicePlan.id
 //     clientAffinityEnabled: true
 //     siteConfig: {
 //       appSettings: [                 
 //         {
 //           name: 'SAaccessKey'
 //           value: saconnectionstring
 //         }          
 //       ]
 //     }
 //   }   
 // }]
