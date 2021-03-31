@ECHO OFF
SET SPLUNK_SERVER=
SET SPLUNK_HEC_TOKEN=
SET SPLUNK_INDEX=
ECHO.  
ECHO Before proceeding, the metric type index and HEC token must be created.
set /p DUMMY=Hit ENTER to continue...
SET /p SPLUNK_SERVER="Enter Splunk Server with HEC inputs:"
IF [%SPLUNK_SERVER%] == [] (
    ECHO SPLUNK_SERVER NOT SET
    GOTO:EOF
) 
SET /p SPLUNK_HEC_TOKEN="Enter HEC token:"
IF [%SPLUNK_HEC_TOKEN%] == [] (
    ECHO SPLUNK_HEC_TOKEN NOT SET
    GOTO:EOF
) 
SET /p SPLUNK_INDEX="Enter name of metrics index:"
IF [%SPLUNK_INDEX%] == [] (
    ECHO SPLUNK_INDEX NOT SET
    GOTO:EOF
) 

REM check that metrics2hec.ps1 is in this directory
IF NOT EXIST "%cd%\metrics2hec.ps1" (
    ECHO %cd%\metrics2hec.ps1 not found. This script must be run from directory containing this file. Exiting.
    GOTO:EOF
) 

REM Allow the powershell to execute.
ECHO Setting powershell execution policy.
powershell -Command Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
powershell -Command Unblock-File -Path '%cd%\metrics2hec.ps1'

ECHO Creating scheduled task.
SCHTASKS /CREATE /RU SYSTEM /SC minute /MO 1 /TN "Splunk Metrics2HEC" /TR "powershell -File '%cd%\metrics2hec.ps1' https://%SPLUNK_SERVER%:8088/services/collector %SPLUNK_HEC_TOKEN% %SPLUNK_INDEX%"
