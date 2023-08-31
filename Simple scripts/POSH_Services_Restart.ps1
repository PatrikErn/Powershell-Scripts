######################################################
#	Written by Patrik Ernholdt
# Version 2.0
# Service restart script where one service has dependent services that are not listed as dependencies
# and need to be restarted after $parent_service.
# Replace $services with those that need to be restarted after $parent_service
# Script is written to take advantage of ConnectWise Automates service monitors.

$parent_service = 'audiosrv'

$services = @(
"bits",
"spooler",
"smsrouter"
)

Get-Service $parent_service | Stop-Service -Verbose
Start-Sleep -Seconds 10
Get-Service $parent_service | Start-Service -Verbose
# Wait for running $parent_service
(Get-Service $parent_service).WaitForStatus('Running','00:10:00')

Get-Service $services | Stop-Service -Verbose
# IF services has Connectwise Automate service monitors attached skip this line and let Automate start them instead
#Start-Sleep -Seconds 5
#Get-Service $services | Start-Service -Verbos
