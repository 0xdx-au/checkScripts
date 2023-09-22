# List of server names or IP addresses to check (one per line in a text file)
$serversFile = "server_list.txt"

# Define the KB numbers for the required security patches
$requiredKBs = @("KB1234567", "KB9876543") # Replace with the actual KB numbers

# Function to check if a specific KB update is installed on a remote server
function IsKBInstalled($server, $kbNumber) {
    $session = New-PSSession -ComputerName $server
    $kbInstalled = Invoke-Command -Session $session -ScriptBlock {
        Get-HotFix | Where-Object { $_.HotFixId -eq $using:kbNumber }
    }
    Remove-PSSession -Session $session
    return [bool]$kbInstalled
}

# Read the list of servers from the file
$servers = Get-Content $serversFile

# Check each server for the DFSCoerce vulnerability
foreach ($server in $servers) {
    $allKBsInstalled = $true

    foreach ($kb in $requiredKBs) {
        if (-not (IsKBInstalled -server $server -kbNumber $kb)) {
            Write-Host "DFSCoerce vulnerability may exist on $server. KB $kb is missing."
            $allKBsInstalled = $false
        }
    }

    if ($allKBsInstalled) {
        Write-Host "No DFSCoerce vulnerability detected on $server. All required KB updates are installed."
    }
}
