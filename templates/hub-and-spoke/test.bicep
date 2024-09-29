module resHubNetwork 'br/public:avm/ptn/network/hub-networking:0.1.0' = {
  name: 'hub-network'
  params: {
    hubVirtualNetworks: {
      hub1:{
        addressPrefixes: [
          '10.0.0.0/16'
        ]
        enableAzureFirewall: false
        enableBastion: true
        enablePeering: false
        vnetEncryptionEnforcement: 'AllowUnencrypted'
      }
    }
  }
}