$Query = "RecoveryServicesResources
| where type =~ 'microsoft.recoveryservices/vaults/backupfabrics/protectioncontainers/protecteditems'
| where properties.backupManagementType =~ 'AzureIaasVM'
| project id, SubscriptionId = subscriptionId, VMName = tostring(properties.friendlyName), 
    LastRecoveryPoint = tostring(properties.lastRecoveryPoint), 
    PolicyName = tostring(properties.policyName), 
    ProtectionStatus = tostring(properties.protectionStatus), 
    CurrentProtectionState = tostring(properties.currentProtectionState),
    BackupId = tostring(properties.id),
    IsBackedUp = isnotempty(id),
    recoveryServiceVault = split(id, '/')[8]"
$PageSize = 1000
$Iteration = 0
$SearchParams = @{
    Query = $($Query)
    First = $PageSize
}
[System.Collections.ArrayList]$RecoveryServicesResources = @()
do {
    $Iteration += 1
    $PageResults = Search-AzGraph @SearchParams -Verbose
    $SearchParams.Skip += $PageResults.Count
    $RecoveryServicesResources.AddRange($PageResults)
} while ($PageResults.Count -eq $PageSize)
$RecoveryServicesResources