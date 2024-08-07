using './deployment.bicep'

param location = 'westeurope'
param environment = 'Dev'
param platformName = 'orepay'
param subscriptionKey = 'b12c8ea1-c05c-4b10-b71d-83f1e0dd5691'
param vnetResourceGroup = 'rg-net-TollingPlatform-central-Dev'
param applicationSubnet = '/subscriptions/${subscriptionKey}/resourceGroups/${vnetResourceGroup}/providers/Microsoft.Network/virtualNetworks/vnet-TollingPlatform-Dev-we-1/subnets/applicationSubnet'
param functionAppSubnet = '/subscriptions/${subscriptionKey}/resourceGroups/${vnetResourceGroup}/providers/Microsoft.Network/virtualNetworks/vnet-TollingPlatform-Dev-we-1/subnets/functionAppSubnet1'
param objectId = ''
param owner = 'devops'
param privateIpsObe = [
  '172.20.215.33' // storage account blob
  '172.20.215.34' // keyvault
  '172.20.215.35' // cosmosdb global endpoint
  '172.20.215.36' // kmtoll
  '172.20.215.37' // obe
  '172.20.215.38' // kapsch
  '172.20.215.39' // logs
  '172.20.215.40'
  '172.20.215.41'
  '172.20.215.42'
  '172.20.215.43' // storage account queue
  '172.20.215.44' // storage account table
  '172.20.215.45' // cosmosdb local endpoint
]

param privateIpsApi = [
  '172.20.215.46' // storage account blob
  '172.20.215.47' // keyvault
  '172.20.215.48' // cosmosdb global endpoint
  '172.20.215.49' // kmtoll
  '172.20.215.63' // bbas
  '172.20.215.64' // platform
  '172.20.215.65' // kmtoll logs
  '172.20.215.66'
  '172.20.215.67'
  '172.20.215.68'
  '172.20.215.69' // storage account queue
  '172.20.215.70' // storage account table
  '172.20.215.71' // cosmosdb local endpoint
  '172.20.215.33' // storage account blob -- OBE Ip addresser START.
  '172.20.215.34' // keyvault
  '172.20.215.35' // cosmosdb global endpoint
  '172.20.215.36' // kmtoll
  '172.20.215.37' // obe
  '172.20.215.38' // kapsch
  '172.20.215.39' // logs
  '172.20.215.40'
  '172.20.215.41'
  '172.20.215.42'
  '172.20.215.43' // storage account queue
  '172.20.215.44' // storage account table
  '172.20.215.45' // cosmosdb local endpoint
]

param appsettings = {
  apikmtoll:[
    {
      name: 'BillingDetailsQueueName'
      value: 'inbound-billing-details'
    }
    {
      name: 'InboundPaymentClaimQueueName'
      value: 'inbound-payment-claims'
    }
    {
      name: 'ACK_URI'
      value: 'ack-tc/v1/'
    }
    {
      name: 'CONTRACT_ISSUER_LIST_URI'
      value: 'contract-issuer-list/v1/'
    }
    {
      name: 'KMTOLLCLIENTID'
      value: 'fe188df6-220e-46a2-a5c8-3cd2850e3c6f'
    }
    {
      name: 'PAYMENT_ANNOUNCEMENT_URI'
      value: 'payment-announcement/v1/'
    }
    {
      name: 'TC_URL'
      value: 'https://api-edu.vejafgifter.dk/'
    }
    {
      name: 'KMTOLLTENANTID'
      value: '765954f6-b463-4be4-9f43-cc5921af6e8b'
    }
    {
      name: 'KMTOLLSCOPES'
      value: 'a7eb1a2d-4857-4f47-8caf-f53e0d6035af/.default'
    }
    {
      name: 'FULL_BLACKLIST_URI'
      value: '/full-black-list/v1/'
    }  
    {
      name: 'FULL_WHITELIST_URI'
      value: '/full-white-list/v1/'
    }
    
    {
      name: 'INCR_BLACKLIST_URI'
      value: '/incremental-black-list/v1/'
    }
    
    {
      name: 'INCR_WHITELIST_URI'
      value: '/incremental-white-list/v1/'
    }
  ]
  apiplatform:[
    {
      name: 'APIM_URL'
      value: 'https://osbpublic-web-backend-it-test-apim-0.azure-api.net/bcRestApi/api/osb/web/v1.0/v2/'
    }
    {
      name: 'BC_PAYMENT_IMPORTS_URI'
      value: 'paymentImports'
    }
    {
      name: 'BCSCOPES'
      value: 'api://9db70bc0-ae93-4faa-9d3e-bed4b167e6af'
    }
  ]
  apibbas:[]
  obekmtoll:[
    {
      name: 'AduUrl'
      value: 'https://func-osb-tollpay-platform-dev-we.azurewebsites.net/api/GetAduIdentifier?code=Bw0JPH3evAxu7zZ-MzjEB4m3cBH4cCk9TOnz0bH3g4yoAzFuUiTS_Q==&clientId=blobs_extension'
    }
    {
      name: 'FullBlackListQueueName'
      value: 'full-blacklst'
    }    
    {
      name: 'FullWhiteListQueueName'
      value: 'full-whitelst'
    }        
    {
      name: 'IncrementalBlackListQueueName'
      value: 'incr-blacklst'
    }        
    {
      name: 'IncrementalWhiteListQueueName'
      value: 'incr-whitelst'
    }        
    {
      name: 'KmTollBaseURL'
      value: 'https://func-osb-tollpay-kmtoll-dev-we.azurewebsites.net/api/v1/ExceptionList?code=YxCU-FaSJndNmps2RscsdcJd7f4uMkdRNCfpF-EvpkbwAzFuLIAVnw==&clientId=blobs_extension'
    }
    {
      name: 'ModifyObeQueueName'
      value: 'modify-obe'
    }    
    {
      name: 'UnBlockObeQueueName'
      value: 'unblock-obe'
    }
  ]
  obekapsch:[
    {
      name: 'BlockObeQueueName'
      value: 'block-obe'
    }    
    {
      name: 'IncrementalBlacklistQueueName'
      value: 'incr-blacklst'
    }
    {
      name: 'KapschAuthUri'
      value: 'http://10.188.61.200:9876/api/auth/oauth_password'
    }
    {
      name: 'KapschBaseURL'
      value: 'http://10.188.61.200:9876/api/amt/v1/'
    }
    {
      name: 'KapschCompletedQueueName'
      value: 'kapsch-completed'
    }
    {
      name: 'KapschRequestsQueueName'
      value: 'kapsch-requests'
    }
    {
      name: 'ModifyObeQueueName'
      value: 'modify-obe'
    }
    {
      name: 'SendBlockDispMsgQueueName'
      value: 'sndblk-msg'
    }
    {
      name: 'sendExtendendMsgDto'
      value: 'Your OBE will be blocked'
    }
    {
      name: 'SendIncrBlackListQueueName'
      value: 'sndinc-blacklst'
    }
    {
      name: 'SendMessageObeQueueName'
      value: 'sndmsg-obe'
    }
    {
      name: 'UnBlockObeQueueName'
      value: 'unblock-obe'
    }
    {
      name: 'VerifyObeQueueName'
      value: 'verify-obe'
    }
  ]
  obemanagement:[{
    name: 'BCBaseURL'
    value: 'https://osbpublic-web-backend-it-test-apim-0.azure-api.net/bcRestApiTolling/api/osb/tolling/v1.0/companies(12e51733-e2ef-45db-b9b9-56129447b9b4)/'
  }
  {
    name: 'BCSCOPES'
    value: 'api://9db70bc0-ae93-4faa-9d3e-bed4b167e6af'
  }
  {
    name: 'BlockObeQueueName'
    value: 'block-obe'
  }  
  {
    name: 'ContractLineStatusFilter'
    value: '?$filter=contractLineType eq \'BIZZ\' and startswith(serialNo, \'60488230\')-obe'
  }
  {
    name: 'ErpQueues'
    value: 'SendIncrBlackListQueueName,VerifyObeQueueName,SendBlockDispMsgQueueName'
  }
  {
    name: 'IncrementalWhiteListQueueName'
    value: 'incr-whitelst'
  }
  {
    name: 'RegisterObeQueueName'
    value: 'register-obe'
  }  
  {
    name: 'SendIncrBlackListQueueName'
    value: 'incr-blacklst'
  }  
  {
    name: 'UnBlockObeQueueName'
    value: 'unblock-obe'
  }  
  {
    name: 'VerifyObeQueueName'
    value: 'verify-obe'
  }
  ]
}

param secretsToCreate = {
  apisecrets:{
    secrets: [
      {
        name: 'KMTOLLCLIENTSECRET'
        value: 'placeholder secret'
      }
      {
        name: 'OCPAPIMSUBSCRIPTIONKEY0'
        value: 'placeholder secret'
      }
      {
        name: 'OCPAPIMSUBSCRIPTIONKEY1'
        value: 'placeholder secret'
      }
    ]
  }
  obesecrets:{
    secrets: [
        {
          name: 'BCOCPAPIMSUBSCRIPTIONKEY0'
          value: 'placeholder'
        }
        {
          name: 'BCOCPAPIMSUBSCRIPTIONKEY1'
          value: 'placeholder'
        }
        {
          name: 'KAPSCHAUTHPASS'
          value: 'placeholder'
        }
        {
          name: 'KAPSCHAUTHUSER'
          value: 'placeholder'
        }
      ]
  }
}

param tags = []
