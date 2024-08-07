/*
-- LA 2023-06-14 Template Created
-- This template will orchestrat the deployment of the full solution Addimotion.ExcelImport
-- To deploy individual parts. Navigate to scripts under ../MainBicepTemplates/
*/

targetScope = 'subscription'

/* ---- This section represents general parameters ---- */
@description('The Azure region into which the resources should be deployed.')
param location string

// Object containing a mapping for location / region code
var regionCodes = {
  westeurope: 'we'
  northeurope: 'neu'
  //... fill up with more regions
}

// remove space and make sure all lower case
var satinatizedLocation = toLower(replace(location, ' ', ''))

// get the region code
var regionCode = regionCodes[satinatizedLocation]

@description('the project the azure artefacts belong to. to=TrustOcean')
@allowed(['exp'])
param project string

@description('Definition of application deployment is subjected to.')
@allowed([
  'api'
  'site'
  'vm'
  'db'
])
param service string

@description('Definition of environment for the deployment.')
@allowed([
  'Dev'
  'Sta'
  'Prd'
])
param environment string

param owner string

/*---- This Section represents storage Account specific parameters ---- */
@allowed([
  'None'
  'AzureServices'
])
param networkAclsBypass string

@allowed([
  'Deny'
  'Allow'
])
param networkAclsDefaultAction string
@allowed([
  'Standard_LRS'
  'Standard_RAGRS'
])
param saskuName string

@allowed([
  'Hot'
  'Cool'
])
param saAccessTier string

//Arrays of blob containers and queues to create in the storage account
param functioncontainersnaming array

/* ---- this section contains Keyvault specific parameters ---- */
@description('Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'standard'
  'premium'
])
param kvSkuName string

param objectId string

param tablenaming string

/*AppServicePlan specific parameters*/
@allowed([
  'S1'
  'S2'
  'S3'
  'B2'
  'F1'
  'Y1'
])
param appservsku string

@allowed([
  'Basic'
  'Shared'
  'Standard'
  'Dynamic'
])
param appservtier string

@minValue(1)
@maxValue(3)
param capacity int

param webbAppNames array

/*Parametervalues for webb app*/



/* ---- This section represents the resource creation section ----*/

/*

NOTICE : When creating from Azure Devops Release Pipelines the Resource group will be autmatically created.
If so then this section will render error since it tries to create a resouce group that has already been created (thus is not unique)
*/

/*General descriptions and variables*/
@description('Specifies the name of the resource group.')
var resourceGroupName = toLower('rg-${regionCode}-${project}-${service}-${environment}')

/*
resource resourceGroupFound 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}
//Deploy resourcegroups to selected environment if it does not exist
*/

var rgdeploynaming = toLower('rgdeploy-${project}-${service}-${environment}')
module rg '../Modules/rg.bicep' = {
  name: rgdeploynaming
  scope: subscription()
  params: {
    environment: environment
    location: location
    owner: owner
    resourceGroupName: resourceGroupName
    service: service
    resourceDoesntExist: true
  }
}

/*Deploy storageaccounts to selected environment*/
@description('Specifies the name of the storage account.')
var storageAccountName = toLower('st${regionCode}${project}${service}${environment}') 
var stdeploynaming = toLower('storage-deployment-${environment}')
module storageAccount '../Modules/st.bicep' = {
  name: stdeploynaming
  scope: resourceGroup(resourceGroupName)
  dependsOn: [ rg ]
  params: {
    storageAccountName: storageAccountName
    accessTier: saAccessTier
    environment: environment
    location: location
    networkAclsBypass: networkAclsBypass
    networkAclsDefaultAction: networkAclsDefaultAction
    owner: owner
    service: service
    skuName: saskuName
    containerstocreate: functioncontainersnaming
   // queuestocreate: functionqueuenaming
   tableName : tablenaming
  }
}

//Output variable from storage account creation
var secretNames = ['StorageAccountConnectionString:${storageAccount.outputs.blobStorageConnectionString}', 'StorageAccountAccessKey:${storageAccount.outputs.accountkey}']
/*Deploy keyvaults to selected environment*/

// Internal variables to be used when creating keyvault
var kvdeploynaming = toLower('kv-deployment-${environment}')

@description('Specifies the name of the key vault. 24 Chars hypens allowed')
var keyVaultName = toLower('kv${regionCode}${project}${service}${environment}')
module keyVault '../Modules/kv.bicep' = {
  name: kvdeploynaming
  scope: resourceGroup(resourceGroupName)
  dependsOn: [rg]
  params: {
    objectId: objectId
    environment: environment
    keyVaultName: keyVaultName
    location: location
    owner: owner
    secretstocreate: secretNames
    service: service
    kvSkuName: kvSkuName
  }
}

/*Deploy appservices to selected environment*/
// Internal variables to be used when creating appservice
var appservdeploynaming = toLower('app-config-deployment-${environment}')

@description('Specifies the name of the app service plan.')
var appServicePlanName = toLower('asp-${regionCode}-${project}-${service}-${environment}')

module appServicePlan '../Modules/appService.bicep' = {
  name: appservdeploynaming
  scope: resourceGroup(resourceGroupName)
  dependsOn: [ rg ]
  params: {
    appServicePlanName: appServicePlanName
    WebbAppNames: webbAppNames
    capacity: capacity
    environment: environment
    location: location
    owner: owner
    service: service
    sku: appservsku
    tier: appservtier
    saconnectionstring: storageAccount.outputs.blobStorageConnectionString

    

  }
}

