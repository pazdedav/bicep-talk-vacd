// Template for provisioning a VM with diagnostic settings and related components

// Ref: https://github.com/Azure/azure-quickstart-templates/blob/master/201-vm-monitoring-diagnostics-extension/azuredeploy.json

param location string = 'westeurope'

param adminPassword string {
  secure: true
}

param adminUserName string {
  default: 'azureadmin'
}

param existingdiagnosticsStorageAccountName string {
  metadata:{
    description: 'The name of an existing storage account to which diagnostics data will be transferred.'
  }
}

param existingdiagnosticsStorageResourceGroup string {
  metadata:{
    description: 'The resource group for the storage account specified in existingdiagnosticsStorageAccountName'
  }
}

param windowsOSVersion string {
  default: '2019-Datacenter'
  allowed: [
    '2008-R2-SP1'
    '2012-Datacenter'
    '2012-R2-Datacenter'
    '2016-Datacenter'
    '2019-Datacenter'
  ]
}

param vmSize string {
  default: 'Standard_A2_v2'
  metadata:{
    description: 'Size of the virtual machine.'
  }
}

var publicIPAddressName = 'myPublicIP'
var publicIPAddressType = 'Dynamic'
var networkSecurityGroupName = 'default-NSG'
var virtualNetworkName = 'MyVNET'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var nicName = 'myVMNic'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var vmName = 'MyVM'
var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var storageAccountType = 'Standard_LRS'
var accountid = resourceId(existingdiagnosticsStorageResourceGroup, 'Microsoft.Storage/storageAccounts', existingdiagnosticsStorageAccountName)
var wadlogs = '<WadCfg> <DiagnosticMonitorConfiguration overallQuotaInMB=\\"4096\\" xmlns=\\"http://schemas.microsoft.com/ServiceHosting/2010/10/DiagnosticsConfiguration\\"> <DiagnosticInfrastructureLogs scheduledTransferLogLevelFilter=\\"Error\\"/> <WindowsEventLog scheduledTransferPeriod=\\"PT1M\\" > <DataSource name=\\"Application!*[System[(Level = 1 or Level = 2)]]\\" /> <DataSource name=\\"Security!*[System[(Level = 1 or Level = 2)]]\\" /> <DataSource name=\\"System!*[System[(Level = 1 or Level = 2)]]\\" /></WindowsEventLog>'
var wadperfcounters1 = '<PerformanceCounters scheduledTransferPeriod=\\"PT1M\\"><PerformanceCounterConfiguration counterSpecifier=\\"\\\\Processor(_Total)\\\\% Processor Time\\" sampleRate=\\"PT15S\\" unit=\\"Percent\\"><annotation displayName=\\"CPU utilization\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\Processor(_Total)\\\\% Privileged Time\\" sampleRate=\\"PT15S\\" unit=\\"Percent\\"><annotation displayName=\\"CPU privileged time\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\Processor(_Total)\\\\% User Time\\" sampleRate=\\"PT15S\\" unit=\\"Percent\\"><annotation displayName=\\"CPU user time\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\Processor Information(_Total)\\\\Processor Frequency\\" sampleRate=\\"PT15S\\" unit=\\"Count\\"><annotation displayName=\\"CPU frequency\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\System\\\\Processes\\" sampleRate=\\"PT15S\\" unit=\\"Count\\"><annotation displayName=\\"Processes\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\Process(_Total)\\\\Thread Count\\" sampleRate=\\"PT15S\\" unit=\\"Count\\"><annotation displayName=\\"Threads\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\Process(_Total)\\\\Handle Count\\" sampleRate=\\"PT15S\\" unit=\\"Count\\"><annotation displayName=\\"Handles\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\Memory\\\\% Committed Bytes In Use\\" sampleRate=\\"PT15S\\" unit=\\"Percent\\"><annotation displayName=\\"Memory usage\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\Memory\\\\Available Bytes\\" sampleRate=\\"PT15S\\" unit=\\"Bytes\\"><annotation displayName=\\"Memory available\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\Memory\\\\Committed Bytes\\" sampleRate=\\"PT15S\\" unit=\\"Bytes\\"><annotation displayName=\\"Memory committed\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\Memory\\\\Commit Limit\\" sampleRate=\\"PT15S\\" unit=\\"Bytes\\"><annotation displayName=\\"Memory commit limit\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\PhysicalDisk(_Total)\\\\% Disk Time\\" sampleRate=\\"PT15S\\" unit=\\"Percent\\"><annotation displayName=\\"Disk active time\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration>'
var wadperfcounters2 = '<PerformanceCounterConfiguration counterSpecifier=\\"\\\\PhysicalDisk(_Total)\\\\% Disk Read Time\\" sampleRate=\\"PT15S\\" unit=\\"Percent\\"><annotation displayName=\\"Disk active read time\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\PhysicalDisk(_Total)\\\\% Disk Write Time\\" sampleRate=\\"PT15S\\" unit=\\"Percent\\"><annotation displayName=\\"Disk active write time\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\PhysicalDisk(_Total)\\\\Disk Transfers/sec\\" sampleRate=\\"PT15S\\" unit=\\"CountPerSecond\\"><annotation displayName=\\"Disk operations\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\PhysicalDisk(_Total)\\\\Disk Reads/sec\\" sampleRate=\\"PT15S\\" unit=\\"CountPerSecond\\"><annotation displayName=\\"Disk read operations\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\PhysicalDisk(_Total)\\\\Disk Writes/sec\\" sampleRate=\\"PT15S\\" unit=\\"CountPerSecond\\"><annotation displayName=\\"Disk write operations\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\PhysicalDisk(_Total)\\\\Disk Bytes/sec\\" sampleRate=\\"PT15S\\" unit=\\"BytesPerSecond\\"><annotation displayName=\\"Disk speed\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\PhysicalDisk(_Total)\\\\Disk Read Bytes/sec\\" sampleRate=\\"PT15S\\" unit=\\"BytesPerSecond\\"><annotation displayName=\\"Disk read speed\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\PhysicalDisk(_Total)\\\\Disk Write Bytes/sec\\" sampleRate=\\"PT15S\\" unit=\\"BytesPerSecond\\"><annotation displayName=\\"Disk write speed\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier=\\"\\\\LogicalDisk(_Total)\\\\% Free Space\\" sampleRate=\\"PT15S\\" unit=\\"Percent\\"><annotation displayName=\\"Disk free space (percentage)\\" locale=\\"en-us\\"/></PerformanceCounterConfiguration></PerformanceCounters>'
var wadcfgxstart = concat(wadlogs, wadperfcounters1, wadperfcounters2, '<Metrics resourceId=\\"')
var wadmetricsresourceid = resourceId('Microsoft.Compute/virtualMachines', vmName)
var wadcfgxend = '\\"><MetricAggregation scheduledTransferPeriod=\\"PT1H\\"/><MetricAggregation scheduledTransferPeriod=\\"PT1M\\"/></Metrics></DiagnosticMonitorConfiguration></WadCfg>'


resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  dependsOn:[
    nsg
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

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  dependsOn:[
    nic
  ]
  location: location
  properties: {
    hardwareProfile:{
      vmSize: vmSize
    }
    osProfile:{
      computerName: vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile:{
      imageReference:{
        publisher: imagePublisher
        offer: imageOffer
        sku: windowsOSVersion
        version: 'latest'
      }
      osDisk:{
        name: concat(vmName, '_OSDisk')
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk:{
          storageAccountType: storageAccountType
        }
      }
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: resourceId('Microsoft.Network/networkInterfaces', nicName)
        }
      ]
    }
    diagnosticsProfile:{
      bootDiagnostics:{
        enabled: true
        storageUri: concat('http://', existingdiagnosticsStorageAccountName, '.blob.', environment().suffixes.storage)
      }
    }
  }
}

resource vmDiagExtension 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  name: 'Microsoft.Insights/VMDiagnosticsSettings'
  location: location
  dependsOn:[
    vm
  ]
  properties: {
    publisher: 'Microsoft.Azure.Diagnostics'
    type: 'IaaSDiagnostics'
    typeHandlerVersion: '1.5'
    autoUpgradeMinorVersion: true
    settings: {
      xmlCfg: base64(concat(wadcfgxstart, wadmetricsresourceid, wadcfgxend))
      storageAccount: existingdiagnosticsStorageAccountName
    }
    protectedSettings: {
      storageAccountName: existingdiagnosticsStorageAccountName
      storageAccountKey: listkeys(accountid, '2019-06-01').keys[0].value
      storageAccountEndPoint: concat('https://', environment().suffixes.storage)
    }
  }
}