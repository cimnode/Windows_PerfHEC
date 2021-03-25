add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy


# Read from paramenters
# 1. URL to send data to ( "https://<<<your server name>>>:8088/services/collector" )
# 2. HEC Token
# 3. target Splunk index which must be a datatype 'metric'

$SPLUNK_URL = $Args[0]
$HEC_TOKEN = $Args[1]
$SPLUNK_INDEX = $Args[2]

# Each counter takes about 1 second to return the value.
# Each counter block can be commented out to not collect the data.

# CPU Use
$output = Get-Counter '\Processor(_Total)\% Processor Time' 
$metrics_string = '"metric_name:CPULoadPercent":"'+ $output.CounterSamples[0].CookedValue +'",'

# Network Use:
$output = Get-Counter '\Network Interface(*)\Bytes Received/sec'
$i = 0
foreach( $nic in $output.CounterSamples )
{
  $metrics_string += '"metric_name:NetworkInterfaceBytesReceived.' + $i + '":"' + $nic.CookedValue + '",'
  $i++
}

$output = Get-Counter '\Network Interface(*)\Bytes Sent/sec'
$i = 0
foreach( $nic in $output.CounterSamples )
{
  $metrics_string += '"metric_name:NetworkInterfaceBytesSent.' + $i + '":"' + $nic.CookedValue + '",'
  $i++
}

# Disk Use:
# https://docs.microsoft.com/en-us/archive/blogs/askcore/windows-performance-monitor-disk-counters-explained
$output = Get-Counter '\PhysicalDisk(*)\Current Disk Queue Length'
$i = 0
foreach( $disk in $output.CounterSamples )
{
  $metrics_string +=  '"metric_name:CurrentDiskQueueLength.' + $i + '":"' + $disk.CookedValue + '",'
  $i++
}

$output = Get-Counter '\PhysicalDisk(*)\Avg. Disk Queue Length'
$i = 0
foreach( $disk in $output.CounterSamples )
{
  $metrics_string +=  '"metric_name:AvgDiskQueueLength.' + $i + '":"' + $disk.CookedValue + '",'
  $i++
}

# GPU
$GpuMemTotal = (((Get-Counter "\GPU Process Memory(*)\Local Usage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum
$metrics_string += '"metric_name:GPUMemoryUsageMB":"' + $([math]::Round($GpuMemTotal/1MB,2)) + '",'
$GpuUseTotal = (((Get-Counter "\GPU Engine(*engtype_3D)\Utilization Percentage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum
$metrics_string += '"metric_name:GPUUtilization":"' + $([math]::Round($GpuUseTotal,2)) + '",'


#Memory
$output = Get-Counter '\Memory\Page Faults/sec'
$metrics_string += '"metric_name:PageFaultsPerSecond":"' + $output.CounterSamples[0].CookedValue + '",'
$output = Get-Counter '\Memory\Available Bytes'
$metrics_string += '"metric_name:MemoryAvailable":"' + $output.CounterSamples[0].CookedValue + '",'
$output = Get-Counter '\Memory\Committed Bytes'
$MemoryCommitted = $output.CounterSamples[0].CookedValue
$metrics_string += '"metric_name:MemoryCommitted":"' + $output.CounterSamples[0].CookedValue + '",'

# Paging File
$output = Get-Counter '\Paging File(*)\% Usage' 
$metrics_string += '"metric_name:PagingFileUsage":"' + $output.CounterSamples[0].CookedValue + '",'

### Output section

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", 'Splunk ' + $HEC_TOKEN)

$body = '{"event":"metric","fields":{'+ $metrics_string + '}, "index":"'+$SPLUNK_INDEX+'","host":"' + $env:computername + '","sourcetype":"WindowsMetrics","source":"'+ $MyInvocation.MyCommand.Name + '"}'
Write-Output $body

$response = Invoke-RestMethod -Uri $SPLUNK_URL  -Method Post -Headers $headers -Body $body 
"Code:'" + $response.code + "' text:'"+ $response.text + "'"
