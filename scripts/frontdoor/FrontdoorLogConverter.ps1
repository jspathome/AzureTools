param(
    [Parameter(Mandatory)][string]$SourceFolder,
    [Parameter(Mandatory)][string]$OutputCsvFile
)

Write-Host "- Loading all frontdoor json logfiles" -ForegroundColor Green
$tempfile = New-TemporaryFile
Get-ChildItem -Path $SourceFolder -Filter PT1H.json -Recurse -ErrorAction SilentlyContinue -Force | Get-Content | Add-Content -Path $tempfile

Write-Host "- Converting the logflle" -ForegroundColor Green
$json = Get-Content $tempfile
$json = "[" + $json + "]"
$json = $json.Replace('} {', '},{')
Write-Host "- Creating a powershell object (This can take some time...)" -ForegroundColor Green
$fdObject = ( $json| ConvertFrom-Json )

if(Test-Path -Path $OutputCsvFile -PathType Leaf)
{
  Remove-Item -Path $OutputCsvFile 
}

Write-Host "- Creating CSV file" -ForegroundColor Green

$tt = "Time,Host,ClientIp,ClientPort,RequestUrl,Rulename,Action,MatchVariableName,MatchVariableValue,Message,Data`r`n"

foreach ($f in $fdobject )
{  
  $textLine = "{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}`r`n" -f $f.time, $f.properties.host, $f.properties.clientip,$f.properties.clientPort, $f.properties.requestUri , $f.properties.ruleName, $f.properties.action, $f.properties.details.matches.matchVariableName ,$f.properties.details.matches.matchVariableValue ,$f.properties.details.msg, $f.properties.details.data
  $tt = $tt + $textLine
}

Set-Content -Path $OutputCsvFile -Value $tt
Get-Content -Path $OutputCsvFile
Remove-Item -Path $tempfile 