//==================================
// Parameters
//==================================

@sys.description('The Azure Region to deploy the resources into.')
param parLocation string = resourceGroup().location

@sys.description('Prefix value which will be prepended to all resource names.')
param parCompanyPrefix string = 'alz'

@sys.description('Name for Hub Network.')
param parHubNetworkName string = '${parCompanyPrefix}-hub-${parLocation}'

@sys.description('The IP address range for Hub Network.')
param parHubNetworkAddressPrefix string = '10.10.0.0/16'

@sys.description('The name, IP address range, network security group, route table and delegation serviceName for each subnet in the virtual networks.')
param parSubnets subnetOptionsType = [
  {
    name: 'AzureBastionSubnet'
    ipAddressRange: '10.10.15.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'GatewaySubnet'
    ipAddressRange: '10.10.252.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureFirewallSubnet'
    ipAddressRange: '10.10.254.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureFirewallManagementSubnet'
    ipAddressRange: '10.10.253.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
]

@sys.description('Array of DNS Server IP addresses for VNet.')
param parDnsServerIps array = []

@sys.description('''Resource Lock Configuration for Virtual Network.

- `kind` - The lock settings of the service which can be CanNotDelete, ReadOnly, or None.
- `notes` - Notes about this lock.

''')
param parVirtualNetworkLock lockType = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

@sys.description('Public IP Address SKU.')
@allowed([
  'Basic'
  'Standard'
])
param parPublicIpSku string = 'Standard'

@sys.description('Optional Prefix for Public IPs. Include a succedent dash if required. Example: prefix-')
param parPublicIpPrefix string = ''

@sys.description('Optional Suffix for Public IPs. Include a preceding dash if required. Example: -suffix')
param parPublicIpSuffix string = '-PublicIP'

@sys.description('Switch to enable/disable Azure Bastion deployment.')
param parAzBastionEnabled bool = true

@sys.description('Azure Bastion SKU.')
@allowed([
  'Basic'
  'Standard'
])
param parAzBastionSku string = 'Standard'

param parDdosPlanResourceId string?

//==================================
// Variables
//==================================


//==================================
// Resources
//==================================
module parHubVnet 'br/public:avm/ptn/network/hub-networking:0.1.0' = {
  name: 'hubVnet-${uniqueString(resourceGroup().id)}'
  params: {
    hubVirtualNetworks: {
      '${parHubNetworkName}':{
        addressPrefixes: [
          parHubNetworkAddressPrefix
        ]
        location: parLocation
        subnets: [
          ''
        ]
        ddosProtectionPlanResourceId: '**ddosPlanId**'
        enableBastion: parAzBastionEnabled
        bastionHost: {
        }
        azureFirewallSettings: {
          zones: [
            1
            2
          ]
          managementIPAddressObject: {
            name: 'mgmtIpConfig'
            properties: {
              publicIPAddress: {
                id: ''
              }
              subnet: {
                id: ''
              }
            }
          }
          azureSkuTier: 'Standard'
          firewallPolicyId: ''
          threatIntelMode: 'Alert'
        }
        dnsServers: [
          parDnsServerIps
        ]
      }
    }
  }
}

//==================================
// Definitions
//==================================

type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. The lock settings of the service.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')

  @description('Optional. Notes about this lock.')
  notes: string?
}

type subnetOptionsType = ({
  @description('Name of subnet.')
  name: string

  @description('IP-address range for subnet.')
  ipAddressRange: string

  @description('Id of Network Security Group to associate with subnet.')
  networkSecurityGroupId: string?

  @description('Id of Route Table to associate with subnet.')
  routeTableId: string?

  @description('Name of the delegation to create for the subnet.')
  delegation: string?
})[]