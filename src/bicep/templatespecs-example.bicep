// Example with templateSpecs
param storageAccountConfig object
param storageAccountType string

var templateLibraryRG = 'contoso-template-library'
var storageSpecName = 'contosoStorage'
var storageSpecVersion = '1.0'
var storageTemplateLinkId = resourceId(templateLibraryRG, 'Microsoft.Resources/templateSpecs/versions', storageSpecName, storageSpecVersion) 

resource storage 'Microsoft.Resources/deployments@2020-06-01' = {
  name: 'storage-tempSpec'
  location: 'westeurope'
  properties:{
    mode:'Incremental'
    templateLink:{
      id: storageTemplateLinkId
    }
    parameters: {
      storageAccountConfig: storageAccountConfig
      storageAccountType: storageAccountType
    }
  }

}