# splunk_agentless
Powershell script that will send Windows Performance Counters to a Splunk metrics index via HEC. metrics2hec.ps1 runs in 1-2 seconds and uses the default output of get-counters. moremetrics2hec.ps1 sends more data, but has a longer runtime.

*These scripts require a HEC token configured allowing access to a metric index.*

Install Script
1. Download this repository into a location where the ps1 script will reside permanently.
2. Run the install_metrics.bat script. This will allow you to enter the server, token and index and create the scheduled task.

Manual Steps
It may be necessary to modify security to allow the script to run. Windows 10 runs in the most restricted mode normally. This step may not be need to Windows Server.
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

Unblock-File -path .\metrics2hec.ps1
```

Example invocation.
```
.\metrics2hec.ps1 "https://yourserver.com:8088/services/collector" abcdef01-1234-5678-90ab-cdef01234567 metric_index
```
A scheduled task can be created to send this every 1 minute, or at some other desired interval.
