# splunk_agentless
Powershell script that will send Windows Performance Counters to a Splunk metrics index via HEC.

To allow the script to run:
`set-executionpolicy -ExecutionPolicy remotesigned -scope localmachine

`Unblock-File -path .\metrics2hec.ps1
