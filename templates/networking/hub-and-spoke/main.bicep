metadata name = 'ALZ Bicep'
metadata description = 'ALZ Bicep Module used to set up Azure Landing Zones'
import * as definitions from '../../definitions/main.bicep'

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

@description('Optional. The hub virtual networks to create.')
param hubNetworks definitions.hubVirtualNetworkType?

//================================
// Variables
//================================


//================================
// Resources
//================================


//=====================
// Foundational
//=====================

module resBastionNsg '../foundational/network-security-group/main.bicep' = [
  for (hub, i) in hubNetworks!: if (hub.enableBastion) {
    name: '${hub.hubName}-bastionNsg-${uniqueString(resourceGroup().id,hub.location)}'
    params: {
      name: 'nsg-AzureBastionSubnet-${hub.hubName}-${hub.location}'
      location: hub.location
      securityRules: [
        // Inbound Rules
        {
          name: 'AllowHttpsInbound'
          properties: {
            access: 'Allow'
            direction: 'Inbound'
            priority: 120
            sourceAddressPrefix: 'Internet'
            destinationAddressPrefix: '*'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
          }
        }
        {
          name: 'AllowGatewayManagerInbound'
          properties: {
            access: 'Allow'
            direction: 'Inbound'
            priority: 130
            sourceAddressPrefix: 'GatewayManager'
            destinationAddressPrefix: '*'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
          }
        }
        {
          name: 'AllowAzureLoadBalancerInbound'
          properties: {
            access: 'Allow'
            direction: 'Inbound'
            priority: 140
            sourceAddressPrefix: 'AzureLoadBalancer'
            destinationAddressPrefix: '*'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
          }
        }
        {
          name: 'AllowBastionHostCommunication'
          properties: {
            access: 'Allow'
            direction: 'Inbound'
            priority: 150
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRanges: [
              '8080'
              '5701'
            ]
          }
        }
        {
          name: 'DenyAllInbound'
          properties: {
            access: 'Deny'
            direction: 'Inbound'
            priority: 4096
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
          }
        }
        // Outbound Rules
        {
          name: 'AllowSshRdpOutbound'
          properties: {
            access: 'Allow'
            direction: 'Outbound'
            priority: 100
            sourceAddressPrefix: '*'
            destinationAddressPrefix: 'VirtualNetwork'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRanges: hub.?bastionHost.?outboundSshRdpPorts ?? [
              '22'
              '3389'
            ]
          }
        }
        {
          name: 'AllowAzureCloudOutbound'
          properties: {
            access: 'Allow'
            direction: 'Outbound'
            priority: 110
            sourceAddressPrefix: '*'
            destinationAddressPrefix: 'AzureCloud'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
          }
        }
        {
          name: 'AllowBastionCommunication'
          properties: {
            access: 'Allow'
            direction: 'Outbound'
            priority: 120
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRanges: [
              '8080'
              '5701'
            ]
          }
        }
        {
          name: 'AllowGetSessionInformation'
          properties: {
            access: 'Allow'
            direction: 'Outbound'
            priority: 130
            sourceAddressPrefix: '*'
            destinationAddressPrefix: 'Internet'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '80'
          }
        }
        {
          name: 'DenyAllOutbound'
          properties: {
            access: 'Deny'
            direction: 'Outbound'
            priority: 4096
            sourceAddressPrefix: '*'
            destinationAddressPrefix: '*'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
          }
        }
      ]
    }
  }
]

//=====================
// Hub network
//=====================

module resHubNetwork 'hub-networking/main.bicep' = [for (hub, i) in hubNetworks!: if (!empty(hubNetworks)) {
  name: 'hubNetwork-${hub.hubName}-${uniqueString(resourceGroup().id,hub.location)}'
  dependsOn: [
    resBastionNsg[i]
  ]
  params: {
    hubVirtualNetworks: {
      '${hub.hubName}': {
        addressPrefixes: hub.addressPrefixes
        dnsServers: hub.?dnsServers ?? null
        enablePeering: hub.?enablePeering ?? false
        peeringSettings: (hub.?enablePeering ?? false) ? hub.?peeringSettings : null
        ddosProtectionPlanResourceId: hub.?ddosProtectionPlanResourceId ?? null
        enableBastion: hub.enableBastion
        vnetEncryption: hub.?vnetEncryption ?? false
        location: hub.location
        tags: parTags
        routes: hub.?routes ?? null
        bastionHost: hub.enableBastion
          ? {
              skuName: hub.?bastionHost.?skuName ?? 'Standard'
            }
          : null
        vnetEncryptionEnforcement: hub.?vnetEncryptionEnforcement ?? 'AllowUnencrypted'
        enableAzureFirewall: hub.enableAzureFirewall
        azureFirewallSettings: hub.enableAzureFirewall
          ? {
              azureSkuTier: hub.?azureFirewallSettings.?azureSkuTier ?? 'Standard'
              location: hub.?azureFirewallSettings.?location ?? parLocation
              firewallPolicyId: hub.?azureFirewallSettings.?firewallPolicyId ?? resAzFirewallPolicy[i].outputs.resourceId
              threatIntelMode: (hub.?azureFirewallSettings.?azureSkuTier == 'Basic')
                ? 'Alert'
                : hub.?azureFirewallSettings.?threatIntelMode ?? 'Alert'
              zones: hub.?azureFirewallSettings.?zones ?? null
              publicIPAddressObject: {
                name: '${hub.hubName}-azfirewall-pip-${hub.location}'
              }
            }
          : null
        subnets: [
          for subnet in hub.subnets: !empty(subnet)
            ? {
                name: subnet.name
                addressPrefix: subnet.addressPrefix
                delegations: empty(subnet.?delegation ?? null)
                  ? null
                  : [
                      {
                        name: subnet.?delegation ?? null
                        properties: {
                          serviceName: subnet.?delegation ?? null
                        }
                      }
                    ]
                networkSecurityGroupResourceId: (subnet.?name == 'AzureBastionSubnet' && hub.enableBastion)
                  ? resBastionNsg[i].outputs.resourceId
                  : subnet.?networkSecurityGroupId ?? null
                routeTable: subnet.?routeTable ??null
              }
            : null
        ]
      }
    }
  }
}
]

//=====================
// Network security
//=====================

module resDdosProtectionPlan '../network-security/ddos-protection-plan/main.bicep' = [
  for (hub, i) in hubNetworks!: if (!empty(hub.?ddosProtectionPlanResourceId) && (parDdosLock.kind != 'None' || parGlobalResourceLock.kind != 'None')) {
    name: 'ddosPlan-${uniqueString(resourceGroup().id,hub.?ddosProtectionPlanResourceId ?? '',hub.location)}'
    params: {
      name: '${parCompanyPrefix}-ddos-plan-${hub.location}'
      location: hub.location
      enableTelemetry: parTelemetryOptOut
      tags: parTags
    }
  }
]

module resAzFirewallPolicy '../network-security/firewall-policy/main.bicep' = [
  for (hub, i) in hubNetworks!: if ((hub.enableAzureFirewall) && empty(hub.?azureFirewallSettings.?firewallPolicyId)) {
    name: 'azFirewallPolicy-${uniqueString(resourceGroup().id,hub.hubName,hub.location)}'
    params: {
      name: '${parCompanyPrefix}-azfwpolicy-${hub.hubName}-${hub.location}'
      tier: hub.?azureFirewallSettings.?azureSkuTier ?? 'Standard'
      enableProxy: hub.?azureFirewallSettings.?azureSkuTier == 'Basic'
        ? false
        : hub.?azureFirewallSettings.?dnsProxyEnabled
      servers: hub.?azureFirewallSettings.?azureSkuTier == 'Basic'
        ? null
        : hub.?azureFirewallSettings.?firewallDnsServers
    }
  }
]
