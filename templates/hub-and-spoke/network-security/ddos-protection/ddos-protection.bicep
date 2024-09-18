//==================================
// Parameters
//==================================

@sys.description('The Azure Region to deploy the resources into.')
param parLocation string = resourceGroup().location

@sys.description('Tags you would like to be applied to all resources in this module.')
param parTags object = {}

@sys.description('DDoS Plan Name.')
param parDdosPlanName string = 'ddos-plan'

@sys.description('Set Parameter to true to Opt-out of deployment telemetry.')
param parTelemetryOptOut bool = false

//==================================
// Resources
//==================================

module parDdosPlan 'br/public:avm/res/network/ddos-protection-plan:0.3.0' = {
  name: 'ddosPlan-${uniqueString(resourceGroup().id,parDdosPlanName,parLocation)}'
  params: {
    name: parDdosPlanName
    location: parLocation
    enableTelemetry: parTelemetryOptOut
    tags: parTags
  }
}

output outDdosPlanResourceId string = parDdosPlan.outputs.resourceId