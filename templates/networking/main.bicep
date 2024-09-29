metadata name = 'ALZ Bicep'
metadata description = 'ALZ Bicep Module used to set up Azure Landing Zones'

import * as definitions from '../definitions/main.bicep'
//================================
// Parameters
//================================

@sys.description('The Azure Region to deploy the resources into.')
param parLocation string = resourceGroup().location

@sys.description('Prefix value which will be prepended to all resource names.')
param parCompanyPrefix string = 'alz'

@sys.description('''Global Resource Lock Configuration used for all resources deployed in this module.

- `kind` - The lock settings of the service which can be CanNotDelete, ReadOnly, or None.
- `notes` - Notes about this lock.

''')
param parGlobalResourceLock definitions.lockType = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

@sys.description('''Resource Lock Configuration for DDoS Plan.

- `kind` - The lock settings of the service which can be CanNotDelete, ReadOnly, or None.
- `notes` - Notes about this lock.

''')
param parDdosLock definitions.lockType = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

@sys.description('Tags you would like to be applied to all resources in this module.')
param parTags object = {}

@sys.description('Set Parameter to true to Opt-out of deployment telemetry.')
param parTelemetryOptOut bool = false

@description('Required. The networking option to select.')
param alzNetworking definitions.alzNetworkingType

@description('Optional. The hub virtual networks to create.')
param hubNetworks definitions.hubVirtualNetworkType?


//================================
// Variables
//================================


//================================
// Resources
//================================

module hubSpokeNetwork 'hub-and-spoke/main.bicep' = if(alzNetworking.networkType == 'hub-and-spoke' && !empty(hubNetworks)) {
  name: 'hubNetworks'
  params: {
    hubNetworks: [
      {
        location: 'eastus'
        addressPrefixes: ['10.0.0.0/16']
        enableAzureFirewall: false
        enableBastion: true
        enablePeering: false
        hubName: 'hub1'
        subnets: [
          {
            name: 'AzureBastionSubnet'
            addressPrefix: '20.0.15.0/24'
            networkSecurityGroupId: ''
            routeTable: ''
          }
          {
            name: 'GatewaySubnet'
            addressPrefix: '20.0.20.0/24'
            networkSecurityGroupId: ''
            routeTable: ''
          }
          {
            name: 'AzureFirewallSubnet'
            addressPrefix: '20.0.254.0/24'
            networkSecurityGroupId: ''
            routeTable: ''
          }
          {
            name: 'AzureFirewallManagementSubnet'
            addressPrefix: '20.0.253.0/24'
            networkSecurityGroupId: ''
            routeTable: ''
          }
        ]
      }
    ]
  }

}