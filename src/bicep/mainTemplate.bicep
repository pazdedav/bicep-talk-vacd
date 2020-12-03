param publicIpName string = 'mypublicip'

// All paths must use forward slash (Widows backslash is not supported)
module publicIp './public_ip.bicep' = {
  name: 'publicIp'
  params: {
    publicIpResourceName: publicIpName
    dynamicAllocation: true
    // Parameters with default values may be omitted.
  }
}

// To reference module outputs
output ipFqdn string = publicIp.outputs.ipFqdn