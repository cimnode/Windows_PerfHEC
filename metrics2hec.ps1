# This block disable SSL verification, and allows self-signed certificates. 
# This can be removed if certs are properly configured. In version 6.0+ of Powershell, 
# use the -SkipCertificateCheck flag on Invoke-RestMethod and remove this section.
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

# Settings are passed as parameters on the command line invocation of script.
# 1. URL to send data to ( "https://<<<your server name>>>:8088/services/collector" )
# 2. HEC Token
# 3. target Splunk index which must be a datatype 'metric'

$SPLUNK_URL = $Args[0]
$HEC_TOKEN = $Args[1]
$SPLUNK_INDEX = $Args[2]


$countersObj = Get-Counter | Select-Object -expand Countersamples | Select-Object Path,CookedValue 

$metrics_string = ""
foreach( $counter in $countersObj )
{
	# Get rid of the computer name from the string
	$path = $counter.Path.split('\')[-2..-1] -join "." 
	# Make the string nice for a metric name.
	$path = (Get-Culture).TextInfo.ToTitleCase($path.replace("(_total)","")).replace(" ","").replace("/","Per").replace("%","Percent").replace(")","").replace("(",".")
	$metrics_string += '"metric_name:' + $path + '":"' + ([Math]::Round($counter.CookedValue,3)) + '",'
}

### Output section

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", 'Splunk ' + $HEC_TOKEN)

$body = '{"event":"metric","fields":{'+ $metrics_string + '}, "index":"'+$SPLUNK_INDEX+'","host":"' + $env:computername + '","sourcetype":"WindowsMetrics","source":"'+ $MyInvocation.MyCommand.Name + '"}'

$response = Invoke-RestMethod -Uri $SPLUNK_URL  -Method Post -Headers $headers -Body $body 
"Code:'" + $response.code + "' text:'"+ $response.text + "'"
