// Parameters declaration
param myString string
param myInt int
param myBool bool
param myObject object
param myArray array
param myPassword string { 
  secure: true
}

// Variables declaration
var myString2 = 'my string value'
var location = resourceGroup().location
var lengthOfMyArray = length(myArray)
var myObject = {
  first: 1
  second: 2
}

// Resource declaration with keyword, identifier, type+api and body
resource dnsZone 'Microsoft.Network/dnszones@2018-05-01' = {
  name: 'myZone'
  location: 'global'
}

// Implicit dependency example
resource otherResource 'Microsoft.Example/examples@2020-06-01' = {
  name: 'exampleResource'
  properties: {
    // get read-only DNS zone property
    nameServers: dnsZone.properties.nameServers
  }
}

// Outputs declaration
output myEndpoint string = dnsZone.properties.endpoint