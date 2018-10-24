[CmdletBinding()]
param()
#$tfOutputFile = ""


# For more information on the Azure DevOps Task SDK:
# https://github.com/Microsoft/vsts-task-lib

Trace-VstsEnteringInvocation $MyInvocation
$keyvalues = @{}

function GetKeyValues($fileContent)
{
    Write-Host "Getting the key values from file contents"
    $lineStart = 0
    $result = ""

    for($i=0; $i -lt $fileContent.Length; $i++)
    {
        $keyvalue = ($fileContent[$i] -split '=',2).trim()
		Write-Host "Found Key: " $keyvalue[0]
		$keyvalues.Add($keyvalue[0],$keyvalue[1])
    }

}

function SetEnvironmentVariables()
{
	foreach ($k in $keyvalues.keys)
	{
		$allUpper = $k.ToUpper()
	    $tfKey = "TF_" + $allUpper
		$envValue = $keyvalues.$k
		
		#Set-Item -LiteralPath Env:$tfKey -Value $keyvalues.$k
		[Environment]::SetEnvironmentVariable($tfKey,$envValue)
		Write-Host "##vso[task.setvariable variable=$tfKey;]$envValue"
	}
}

try {
    # Set the working directory.
    $cwd = Get-VstsInput -Name cwd -Require
	#$cwd = pwd
	
    Assert-VstsPath -LiteralPath $cwd -PathType Container
    Write-Verbose "Setting working directory to '$cwd'."
    Set-Location $cwd
	
	if (-not (test-path "c:\terraform-download"))
	{
		Write-Host "Terraform not found in c:\terraform-download"
		terraform output > terraform-outputs.txt
	} else 
	{
		Write-Host "Terraform found in c:\terraform-download"
		iex "c:\terraform-download\terraform output > terraform-outputs.txt"
	}
	
	##$tfOutputFile = Get-VstsInput -Name File -Require
	$tfOutputFile = "./terraform-outputs.txt"
	$fileContent = Get-Content -Path $tfOutputFile

	GetKeyValues $fileContent
	SetEnvironmentVariables
		
    Write-Host "Result:  $value" -ForegroundColor Green
		
    # Output the message to the log.
    ##Write-Host (Get-VstsInput -Name msg)
} finally {
	Write-Host "Finishing"
    Trace-VstsLeavingInvocation $MyInvocation
}
