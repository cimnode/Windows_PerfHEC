# splunk_agentless
Powershell script that will send Windows Performance Counters to a Splunk metrics index via HEC. metrics2hec.ps1 runs in 1-2 seconds and used the default output of get-counters. moremetrics2hec.ps1 sends more data, but has a longer runtime.

*This requires a HEC token configured allowing access to a metric index.*

It may be necessary to modify security to allow the script to run.
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

Unblock-File -path .\metrics2hec.ps1
```

Example invocation.
```
.\metrics2hec.ps1 "https://yourserver.com:8088/services/collector" abcdef01-1234-5678-90ab-cdef01234567 metric_index
```
A scheduled task can be created to send this every 1 minute, or at some other desired interval.
