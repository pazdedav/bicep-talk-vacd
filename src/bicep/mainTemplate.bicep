// Public IP Address Module

param location string {
  default: resourceGroup().location
  metadata: {
    description: 'Location for all resources.'
  }
}

var publicIPAddressName = 'myPublicIP'
var publicIPAddressType = 'Dynamic'

resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
  }
}