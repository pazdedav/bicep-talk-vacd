// Module for Network Interface Card

param location string {
  default: resourceGroup().location
  metadata: {
    description: 'Location for all resources.'
  }
}

var nicName = 'myVMNic'
var publicIPAddressName = 'myPublicIP'
var virtualNetworkName = 'MyVNET'
var subnetName = 'Subnet'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations:[
      {
        name: 'ipconfig1'
        properties:{
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', publicIPAddressName)
          }
          subnet:{
            id: subnetRef
          }
        }
      }
    ]
  }
}