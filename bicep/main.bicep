param location string = resourceGroup().location
param appNamePrefix string = uniqueString(resourceGroup().id)
param functionAppName string = '${appNamePrefix}-functionapp'
param functionStorageAccountName string = format('{0}fnsta', replace(appNamePrefix, '-', ''))
param acrName string = '${appNamePrefix}-acr'
param appServicePlanName string = '${appNamePrefix}-asp'
param storageSku string = 'Standard_LRS'
param appInsightsName string = '${appNamePrefix}-appinsights'
param sqlStorageAccountName string = format('{0}sqlsta', replace(appNamePrefix, '-', ''))
param sqlServerName string = '${appNamePrefix}-sqlserver'
param sqlDatabaseName string
param sqlServerUserName string 
@secure()
param sqlServerPassword string


resource azureContainerRegistery 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  location: location
  name: acrName
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
    dataEndpointEnabled: false
    encryption: {
      status: 'disabled'
    }
    networkRuleBypassOptions: 'AzureServices'
    policies: {
      exportPolicy: {
        status: 'enabled'
      }
      quarantinePolicy: {
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
      trustPolicy: {
        status: 'disabled'
        type: 'Notary'
      }
    }
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
  }
  sku: {
    name: 'Standard'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: {
    // circular dependency means we can't reference functionApp directly  /subscriptions/<subscriptionId>/resourceGroups/<rg-name>/providers/Microsoft.Web/sites/<appName>"
     'hidden-link:/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${functionAppName}': 'Resource'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  location: location
  name: sqlServerName
  properties: {
    administratorLogin: sqlServerUserName
    administratorLoginPassword: sqlServerPassword
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
    version: '12.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: sqlServer
  location: location
  name: sqlDatabaseName
  properties: {
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    isLedgerOn: false
    licenseType: 'LicenseIncluded'
    maintenanceConfigurationId: '/subscriptions/1220b1b9-4647-45e9-b9a7-afa4b55dd055/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default'
    maxSizeBytes: 34359738368
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
    zoneRedundant: false
  }
  sku: {
    capacity: 2
    family: 'Gen5'
    name: 'GP_Gen5'
    tier: 'GeneralPurpose'
  }
}

resource functionAppStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  kind: 'StorageV2'
  location: location
  name: functionStorageAccountName
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
  }
  sku: {
    name: storageSku
  }
}

resource sqlServerStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  kind: 'StorageV2'
  location: location
  name: sqlStorageAccountName
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
  }
  sku: {
    name: storageSku
  }
}

resource serverfarm 'Microsoft.Web/serverfarms@2021-03-01' = {
  kind: 'linux'
  location: location
  name: appServicePlanName
  properties: {
    elasticScaleEnabled: false
    hyperV: false
    isSpot: false
    isXenon: false
    maximumElasticWorkerCount: 1
    perSiteScaling: false
    reserved: true
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
  sku: {
    capacity: 1
    family: 'Pv2'
    name: 'P1v2'
    size: 'P1v2'
    tier: 'PremiumV2'
  }
}

resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2021-09-01' = {
  parent: functionAppStorageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

output fnAppStorageAcccount string = functionAppStorageAccount.name
output appServicePlanName string = serverfarm.name
output acrName string = azureContainerRegistery.name
