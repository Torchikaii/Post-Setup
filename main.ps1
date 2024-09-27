# Function to check and run with admin privileges if not already elevated
function Ensure-AdminRights {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        # Restart the script with elevated privileges
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
}

# Function to run non-admin scripts
function Run-NonAdminScript {
    param ($scriptPath)
    Write-Host "Running non-admin script: $scriptPath"
    # Run the script in a new process without elevation
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Wait
}

# Function to run admin scripts
function Run-AdminScript {
    param ($scriptPath)
    Write-Host "Running admin script: $scriptPath"
    # Run the script in the current (elevated) context
    & $scriptPath
}

# Ensure admin rights for the main script
Ensure-AdminRights

# ---- MAIN SECTION ----
# Use $PSScriptRoot to refer to the directory of the current script
$scriptDir = $PSScriptRoot

# List of non-admin scripts to run
$nonAdminScripts = @(
    "$scriptDir\test2.ps1"
)

# List of admin-required scripts to run
$adminScripts = @(
    "$scriptDir\test1.ps1"
)

# Run admin-required scripts (elevated context)
foreach ($script in $adminScripts) {
    Run-AdminScript $script
}

# Run non-admin-required scripts (non-elevated context)
foreach ($script in $nonAdminScripts) {
    Run-NonAdminScript $script
}

# Pause to keep the window open
pause
