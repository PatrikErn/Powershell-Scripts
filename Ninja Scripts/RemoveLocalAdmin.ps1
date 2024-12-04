#	Written by Patrik Ernholdt
#	Date: 2024-12-03
# Remove local admins Script.
# Removes empty SID from Local administrators group
# Leaves Domain Administrators group intact
# Add exceptions in variable to add your own list of approved accounts.

# Define the exceptions based on name patterns
$exceptions = @(
    '*loc.*',
    '*MSP*',
    '*\Domain Admins*'
)

# Function to clean empty SIDs from the group - Either old accounts or unreachable domain users/groups
function EmptySID {
    try {
        $administrators = @(
            ([ADSI]"WinNT://./Administrators,group").psbase.Invoke('Members') |
            ForEach-Object { 
                $_.GetType().InvokeMember('AdsPath','GetProperty',$null,$($_),$null) 
            }
        ) -match '^WinNT'

        $administrators = $administrators -replace "WinNT://",""

        foreach ($administrator in $administrators) {
            $exclude = $false
            foreach ($exception in $exceptions) {
                if ($administrator -like $exception) {
                    $exclude = $true
                    break
                }
            }
            if ($exclude) {
                continue
            }

            if ($administrator -like "$env:COMPUTERNAME/*" -or $administrator -like "AzureAd/*") {
                continue
            } elseif ($administrator -match "S-1") { # Checking for empty/orphaned SIDs only
                Write-Host "Removing orphaned SID: $administrator"
                Remove-LocalGroupMember -SID 'S-1-5-32-544' -Member $administrator
            } else {
                Write-Host "$administrator check this user's permissions if set in endpoint manager"
            }
        }
    } catch {
        Write-Error "Failed to clean empty SIDs. Error: $_"
    }
}

#  Function to clean out local Administrators, respects exceptions
function Remove_Admins {
    try {
        Get-LocalGroupMember -SID 'S-1-5-32-544' | ForEach-Object {
            $exclude = $false
            foreach ($exception in $exceptions) {
                if ($_.Name -like $exception) {
                    $exclude = $true
                    break
                }
            }
            if (-not $exclude) {
                try {
                    Write-Host "Attempting to remove member: $($_.Name)"
                    Remove-LocalGroupMember -SID 'S-1-5-32-544' -Member $_.Name
                    Write-Host "Successfully removed member: $($_.Name)"
                } catch {
                    Write-Error "Failed to remove $($_.Name) from Administrators group. Error: $_"
                }
            } else {
                Write-Host "Skipping member: $($_.Name)"
            }
        }
    } catch {
        Write-Error "Failed to remove local group members. Error: $_"
    }
}

# Call the functions
EmptySID
Remove_Admins
