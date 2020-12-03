[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $templateFile
)

$results = Get-AzResourceGroupDeploymentWhatIfResult `
  -ResourceGroupName contoso-serviceOne-rg `
  -TemplateFile $templateFile

#See a summary of each change
foreach ($change in $results.Changes)
{
  $change.Delta
}