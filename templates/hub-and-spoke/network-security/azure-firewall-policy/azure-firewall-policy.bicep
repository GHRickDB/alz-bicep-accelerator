//==================================
// Parameters
//==================================

@sys.description('The Azure Region to deploy the resources into.')
param parLocation string = resourceGroup().location

@sys.description('Tags you would like to be applied to all resources in this module.')
param parTags object = {}

@sys.description('Prefix value which will be prepended to all resource names.')
param parCompanyPrefix string = 'alz'

@sys.description('Azure Firewall Policies Name.')
param parAzFirewallPoliciesName string = '${parCompanyPrefix}-azfwpolicy-${parLocation}'

@description('The operation mode for automatically learning private ranges to not be SNAT.')
param parAzFirewallPoliciesAutoLearn string = 'Disabled'
@allowed([
  'Disabled'
  'Enabled'
])

@description('Private IP addresses/IP ranges to which traffic will not be SNAT.')
param parAzFirewallPoliciesPrivateRanges array = []

@sys.description('Azure Firewall Tier associated with the Firewall to deploy.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param parAzFirewallTier string = 'Standard'

@sys.description('The Azure Firewall Threat Intelligence Mode. If not set, the default value is Alert.')
@allowed([
  'Alert'
  'Deny'
  'Off'
])
param parAzFirewallIntelMode string = 'Alert'

@sys.description('Switch to enable/disable Azure Firewall DNS Proxy.')
param parAzFirewallDnsProxyEnabled bool = true

@sys.description('Array of custom DNS servers used by Azure Firewall')
param parAzFirewallDnsServers array = []

//==================================
// Resources
//==================================

module resFirewallPolicies 'br/public:avm/res/network/firewall-policy:0.1.3' = {
  name: 'AzFirewallPolicy-${uniqueString(resourceGroup().id,parAzFirewallPoliciesName,parLocation)}'
  params: {
    name: parAzFirewallPoliciesName
    tags: parTags
    location: parLocation
    tier: parAzFirewallTier
    threatIntelMode: (parAzFirewallTier == 'Basic') ? 'Alert' : parAzFirewallIntelMode
    autoLearnPrivateRanges: (parAzFirewallTier == 'Basic') ? parAzFirewallPoliciesAutoLearn : null
    privateRanges: (parAzFirewallTier == 'Basic') ? parAzFirewallPoliciesPrivateRanges : null
    enableProxy: (parAzFirewallTier == 'Basic') ? null : parAzFirewallDnsProxyEnabled
    servers: (parAzFirewallTier == 'Basic') ? null : parAzFirewallDnsServers
  }
}
