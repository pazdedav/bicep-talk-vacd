$results = Get-AzResourceGroupDeploymentWhatIfResult `
  -ResourceGroupName contoso-serviceOne-rg `
  -TemplateFile .\vm.json

#See a summary of each change
foreach ($change in $results.Changes)
{
  $change.Delta
}