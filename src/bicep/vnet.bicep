// Module for Virtual Network

param location string {
  default: resourceGroup().location
  metadata: {
    description: 'Location for all resources.'
  }
}

var virtualNetworkName = 'MyVNET'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var networkSecurityGroupName = 'default-NSG'

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  dependsOn:[
    //resourceId('Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
  ]
  properties: {
    addressSpace:{
      addressPrefixes:[
        addressPrefix
      ]
    }
    subnets:[
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: resourceId('Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
          }
        }
      }
    ]
  }
}