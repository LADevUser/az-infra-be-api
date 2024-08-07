targetScope = 'resourceGroup'
param location string
param service string
param environment string
param skuName string
param accessTier string
param networkAclsBypass string
param networkAclsDefaultAction string
param owner string
@minLength(3)
@maxLength(24)
param storageAccountName string
param containerstocreate array
//param queuestocreate array
param tableName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
  properties: {
    accessTier: accessTier
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Enabled'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    allowCrossTenantReplication: true
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkAclsDefaultAction
      ipRules: []
    }
    dnsEndpointType: 'Standard'
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          keyType: 'Account'
          enabled: true
        }
        /*queue: {
          keyType: 'Account'
          enabled: true
        }*/
      }
    }
  }
  tags: {
    DisplayName: 'Storage Account'
    Service: service
    Environment: environment
    Owner: owner
  }
}


resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  name: 'default'
  parent: storageAccount
}

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = [for (name, i) in containerstocreate: {
  name: '${name}'
  parent: blobService
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}]

/*
resource storagequeueservice 'Microsoft.Storage/storageAccounts/queueServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource storagequeue 'Microsoft.Storage/storageAccounts/queueServices/queues@2022-09-01' = [for (name, i) in queuestocreate: {
  name: '${name}'
  parent: storagequeueservice
  properties: {
    metadata: {}
  }
}]
*/

resource tableservice 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    cors: {
      
    }
  }
}

resource symbolicname 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  name: tableName
  parent: tableservice
  properties: {
    
  }
}


output blobStorageConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[1].value}'
output accountkey string = '${listKeys(storageAccount.id, storageAccount.apiVersion).keys[1].value}'
