<#
.SYNOPSIS
Calls a shell (cmd) command with retries
.DESCRIPTION
The Invoke-CommandWithRetries function calls shell (cmd) commands using the provided parameters, with optional retries in configurable intervals upon failures.
.PARAMETER Command
The command to call.
.PARAMETER Arguments
Arguments to pass when invoking the comand.
.PARAMETER TrustExitCode
Trust the command's exit code for the purpose of determining whether it was successful or not.
If this parameter is $False, a non-empty stderr will also be considered a failure.
.PARAMETER RetrySleepSeconds
Time in seconds to sleep between retry attempts in case of command failure.
.PARAMETER MaxAttempts
Maximum number of retry attempts in case of command failure.
.PARAMETER PrintCommand
Determines whether or not to print the full command to the host before execution.
.PARAMETER AllowedReturnValues
An array of acceptable return codes (in addition to 0). If omitted only a return code of 0 is used to indicate success.
.PARAMETER ErrorMessage
A message to add include when the command has failed to be run.
.INPUTS
None. You cannot pipe objects to Call-CommandWithRetries.
.OUTPUTS
The output of the last command execution.
.EXAMPLE
Use cURL for Windows to download the latest NuGet command-line client
C:\PS> Call-CommandWithRetries "curl.exe" @("--fail", "-O", "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe")
#>
function Invoke-CommandWithRetries
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string]$Command,
        [Array]$Arguments,
        [bool]$TrustExitCode = $True,
        [int]$RetrySleepSeconds = 10,
        [int]$MaxAttempts = 10,
        [bool]$PrintCommand = $True,
        [bool]$PrintOutput = $False,
        [int[]]$AllowedReturnValues = @(),
        [string]$ErrorMessage
    )

    Process
    {
        $attempt = 0
        while ($true)
        {
            Write-Host $(if ($PrintCommand) { "Executing: $Command $Arguments" }
            else { "Executing command..." })

            try
            {
                $output = & $Command $Arguments 2>&1
                if ($PrintOutput) { Write-Host $output }

                $stderr = $output | where { $_ -is [System.Management.Automation.ErrorRecord] }
                if (($LASTEXITCODE -eq 0 -or $AllowedReturnValues -contains $LASTEXITCODE) -and ($TrustExitCode -or !($stderr)))
                {
                    Write-Host "Command executed successfully"
                    return $output
                }

                Write-Host "Command failed with exit code ($LASTEXITCODE) and stderr: $stderr" -ForegroundColor Yellow
            }
            catch
            {
                Write-Host "Command failed with exit code ($LASTEXITCODE), exception ($_) and stderr: $stderr" -ForegroundColor Yellow
            }

            if ($attempt -eq $MaxAttempts)
            {
                $ex = new-object System.Management.Automation.CmdletInvocationException "All retry attempts exhausted $ErrorMessage"
                $category = [System.Management.Automation.ErrorCategory]::LimitsExceeded
                $errRecord = new-object System.Management.Automation.ErrorRecord $ex, "CommandFailed", $category, $Command
                $psCmdlet.WriteError($errRecord)
                return $output
            }

            $attempt++;
            Write-Host "Retrying test execution [#$attempt/$MaxAttempts] in $RetrySleepSeconds seconds..."
            Start-Sleep -s $RetrySleepSeconds
        }
    }
}