# splunk_agentless
Powershell script that will send Windows Performance Counters to a Splunk metrics index via HEC.

*This requires a HEC token configured allowing access to a metric index.*

It may be necessary to modify security to allow the script to run.
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

Unblock-File -path .\metrics2hec.ps1
```

Example invocation.
```
.\metrics2hec.ps1 "https://yourserver.com:8088/services/collector" abcef001-1234-5678-90ab-cdef01234567 metric_index
```
A scheduled task can be created to send this every 1 minute, or at some other desired interval.
