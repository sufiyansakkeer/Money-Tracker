# Find the flutter_local_notifications plugin directory
$pluginFiles = Get-ChildItem -Path "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev" -Recurse -Filter "FlutterLocalNotificationsPlugin.java" | Where-Object { $_.FullName -like "*flutter_local_notifications-16.3.3*" }

if ($pluginFiles.Count -eq 0) {
    Write-Host "Flutter Local Notifications plugin file not found."
    exit 1
}

$pluginFile = $pluginFiles[0].FullName
Write-Host "Found plugin file at: $pluginFile"

# Create a backup of the original file
Copy-Item -Path $pluginFile -Destination "$pluginFile.bak"
Write-Host "Created backup at: $pluginFile.bak"

# Read the file content
$content = Get-Content -Path $pluginFile -Raw

# Apply the fix
$fixedContent = $content -replace 'bigPictureStyle\.bigLargeIcon\(null\);', 'bigPictureStyle.bigLargeIcon((Bitmap) null);'

# Write the fixed content back to the file
Set-Content -Path $pluginFile -Value $fixedContent

Write-Host "Fix applied successfully."
Write-Host "Please rebuild your app."
