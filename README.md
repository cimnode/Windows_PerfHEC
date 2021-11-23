# Windows Performance to Splunk HEC
Powershell script that will send Windows performance counters to a Splunk metrics index via HEC.  
- metrics2hec.ps1 runs in 1-2 seconds and uses the default output of get-counters.  
- moremetrics2hec.ps1 sends more data, but has a longer runtime.

*These scripts require a HEC token configured allowing access to a metric index.*

**Install Script**  
Automatically configure a scheduled task to run the script every 1 minute and send the data to HEC endpoint.
1. Download and unzip this repository into a location where the ps1 script will reside permanently.
2. Run the install_metrics.bat script from an elevated cmd prompt. This will prompt for server, token and index to automatically create the scheduled task. It will also set the execution policy.

**Manual Setup**  
From an admin Powershell prompt, Set-ExecutionPolicy to allow the Powershell script to run. Windows 10 runs in the most restricted mode normally. This step should have no affect on Windows Servers as RemoteSigned is the default posture. 
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

Unblock-File -path .\metrics2hec.ps1
```

Example invocation.
```
.\metrics2hec.ps1 "https://yourserver.com:8088/services/collector" abcdef01-1234-5678-90ab-cdef01234567 metric_index
```
A scheduled task can be created to send this every 1 minute, or at some other desired interval.

Example HEC data:
```
{"metric_name:Memory.CacheFaultsPerSec":0,"metric_name:Memory.PercentCommittedBytesInUse":38.938,"metric_name:NetworkInterface.Intel[R]DualBandWireless-Ac8265.BytesTotalPerSec":576.089,"metric_name:Physicaldisk.CurrentDiskQueueLength":0,"metric_name:Physicaldisk.PercentDiskTime":0,"metric_name:Processor.PercentProcessorTime":0}
```
Data Preview:
```
| msearch index=<<your metrics index>> |search source="metrics2hec.ps1"
```
Exampe Splunk Query
```
| mstats avg("Processor.PercentProcessorTime") prestats=true WHERE "index"="<<your_metrics_index>>" by host span=10m
| timechart avg("Processor.PercentProcessorTime") AS Avg span=10s by host
| fields - _span*
```
