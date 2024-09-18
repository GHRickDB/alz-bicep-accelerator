using './main.bicep'

param parLocation = 'eastus'
param parCompanyPrefix = 'alz'
param parHubNetworkName = '${parCompanyPrefix}-hub-${parLocation}'
param parGlobalResourceLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}
param parHubNetworkAddressPrefix = '10.10.0.0/16'
/*param parSubnets = [
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
]*/
param parSubnets = []
param parDnsServerIps = []
param parVirtualNetworkLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}
param parPublicIpSku = 'Standard'
param parPublicIpPrefix = ''
param parPublicIpSuffix = '-PublicIP'
param parAzBastionEnabled = true
param parAzBastionName = '${parCompanyPrefix}-bastion'
param parAzBastionSku = 'Standard'
param parAzBastionTunneling = false
param parAzBastionNsgName = 'nsg-AzureBastionSubnet'
param parBastionLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}
param parDdosEnabled = true
param parDdosPlanName = '${parCompanyPrefix}-ddos-plan'
param parDdosLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}
param parAzFirewallEnabled = true
param parAzFirewallName = '${parCompanyPrefix}-azfw-${parLocation}'
param parAzFirewallPoliciesEnabled = true
param parAzFirewallPoliciesName = '${parCompanyPrefix}-azfwpolicy-${parLocation}'
param parAzFirewallPoliciesAutoLearn = 'Disabled'
param parAzFirewallPoliciesPrivateRanges = []
param parAzFirewallTier = 'Standard'
param parAzFirewallIntelMode = 'Alert'
param parAzFirewallCustomPublicIps = []
param parAzFirewallAvailabilityZones = []
param parAzErGatewayAvailabilityZones = []
param parAzVpnGatewayAvailabilityZones = []
param parAzFirewallDnsProxyEnabled = true
param parAzFirewallDnsServers = []
param parAzureFirewallLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}
param parHubRouteTableName = '${parCompanyPrefix}-hub-routetable'
param parDisableBgpRoutePropagation = false
param parHubRouteTableLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}
param parPrivateDnsZonesEnabled = true
param parPrivateDnsZonesResourceGroup = resourceGroup().name
param parPrivateDnsZones = [
  'privatelink.${toLower(parLocation)}.azmk8s.io'
  'privatelink.${toLower(parLocation)}.batch.azure.com'
  'privatelink.${toLower(parLocation)}.kusto.windows.net'
  'privatelink.adf.azure.com'
  'privatelink.afs.azure.net'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink.analysis.windows.net'
  'privatelink.api.azureml.ms'
  'privatelink.azconfig.io'
  'privatelink.azure-api.net'
  'privatelink.azure-automation.net'
  'privatelink.azurecr.io'
  'privatelink.azure-devices.net'
  'privatelink.azure-devices-provisioning.net'
  'privatelink.azuredatabricks.net'
  'privatelink.azurehdinsight.net'
  'privatelink.azurehealthcareapis.com'
  'privatelink.azurestaticapps.net'
  'privatelink.azuresynapse.net'
  'privatelink.azurewebsites.net'
  'privatelink.batch.azure.com'
  'privatelink.blob.core.windows.net'
  'privatelink.cassandra.cosmos.azure.com'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.database.windows.net'
  'privatelink.datafactory.azure.net'
  'privatelink.dev.azuresynapse.net'
  'privatelink.dfs.core.windows.net'
  'privatelink.dicom.azurehealthcareapis.com'
  'privatelink.digitaltwins.azure.net'
  'privatelink.directline.botframework.com'
  'privatelink.documents.azure.com'
  'privatelink.eventgrid.azure.net'
  'privatelink.file.core.windows.net'
  'privatelink.gremlin.cosmos.azure.com'
  'privatelink.guestconfiguration.azure.com'
  'privatelink.his.arc.azure.com'
  'privatelink.dp.kubernetesconfiguration.azure.com'
  'privatelink.managedhsm.azure.net'
  'privatelink.mariadb.database.azure.com'
  'privatelink.media.azure.net'
  'privatelink.mongo.cosmos.azure.com'
  'privatelink.monitor.azure.com'
  'privatelink.mysql.database.azure.com'
  'privatelink.notebooks.azure.net'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.pbidedicated.windows.net'
  'privatelink.postgres.database.azure.com'
  'privatelink.prod.migration.windowsazure.com'
  'privatelink.purview.azure.com'
  'privatelink.purviewstudio.azure.com'
  'privatelink.queue.core.windows.net'
  'privatelink.redis.cache.windows.net'
  'privatelink.redisenterprise.cache.azure.net'
  'privatelink.search.windows.net'
  'privatelink.service.signalr.net'
  'privatelink.servicebus.windows.net'
  'privatelink.siterecovery.windowsazure.com'
  'privatelink.sql.azuresynapse.net'
  'privatelink.table.core.windows.net'
  'privatelink.table.cosmos.azure.com'
  'privatelink.tip1.powerquery.microsoft.com'
  'privatelink.token.botframework.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.web.core.windows.net'
  'privatelink.webpubsub.azure.com'
]
param parPrivateDnsZoneAutoMergeAzureBackupZone = true
param parVirtualNetworkIdToLinkFailover = ''
param parPrivateDNSZonesLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}
param parVpnGatewayEnabled = true
param parVpnGatewayConfig = {
  name: '${parCompanyPrefix}-Vpn-Gateway'
  gatewayType: 'Vpn'
  sku: 'VpnGw1'
  vpnType: 'RouteBased'
  generation: 'Generation1'
  enableBgp: false
  activeActive: false
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: 65515
    bgpPeeringAddress: ''
    peerWeight: 5
  }
  vpnClientConfiguration: {}
}
param parExpressRouteGatewayEnabled = true
param parExpressRouteGatewayConfig = {
  name: '${parCompanyPrefix}-ExpressRoute-Gateway'
  gatewayType: 'ExpressRoute'
  sku: 'ErGw1AZ'
  vpnType: 'RouteBased'
  vpnGatewayGeneration: 'None'
  enableBgp: false
  activeActive: false
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: '65515'
    bgpPeeringAddress: ''
    peerWeight: '5'
  }
}
param parVirtualNetworkGatewayLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}
param parTags = {}
param parTelemetryOptOut = false
param parBastionOutboundSshRdpPorts = [
  '22'
  '3389'
]


param hubNetworks = [
  {
    hub1:{
      location: 'uksouth'
      addressPrefixes: [
        '10.0.0.0/16'
      ]
      enableAzureFirewall: true
      azureFirewallSettings: {
        azureSkuTier: 'Standard'
        location: 'uksouth'
      }
      enableBastion: true
      bastionHost: {
        skuName: 'Standard'
        disableCopyPaste: false
      }
      dnsServers: parDnsServerIps
      routes: [

      ]
      subnets: [

      ]
    }
    hub2:{
      location: 'uksouth'
      addressPrefixes: [
        '10.10.0.0/16'
      ]
      enableAzureFirewall: true
      azureFirewallSettings: {
        azureSkuTier: 'Standard'
        location: 'uksouth'
      }
      enableBastion: true
      bastionHost: {
        skuName: 'Standard'
        disableCopyPaste: false
      }
      dnsServers: parDnsServerIps
      routes: [

      ]
      subnets: [

      ]
    }
  }
]

