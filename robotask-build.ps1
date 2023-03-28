# Copy RoboTask folder to Desktop
Copy-Item -Path "C:\Program Files\RoboTask" -Destination "$env:USERPROFILE\Desktop\RoboTask" -Recurse -Force

# Copy icon.ico to RoboTask folder
Copy-Item -Path "C:\Users\dkendall\Desktop\apps\icon.ico" -Destination "$env:USERPROFILE\Desktop\RoboTask" -Force

# Zip up the folder
$zipFile = "$env:USERPROFILE\Desktop\RoboTask.zip"
Compress-Archive -Path "$env:USERPROFILE\Desktop\RoboTask" -DestinationPath $zipFile -Force

# Update hash and version in robotask-portable.json
$jsonFilePath = "$env:USERPROFILE\Desktop\scoop\robotask-portable.json"

$json = Get-Content $jsonFilePath | ConvertFrom-Json
$json.version = (Get-Command "C:\Program Files\RoboTask\Robotask.exe").FileVersionInfo.FileVersion
$json.hash = Get-FileHash -Path "$env:USERPROFILE\Desktop\RoboTask.zip" -Algorithm SHA256 | Select-Object -ExpandProperty Hash
$json | ConvertTo-Json -Depth 10 | Set-Content $jsonFilePath -Force

# Move zip archive to apps folder on Desktop
Move-Item $zipFile "$env:USERPROFILE\Desktop\apps" -Force

# Git push directories of scoop and apps on Desktop with the commit message of the version from robotask.exe
cd "$env:USERPROFILE\Desktop\scoop"
git add .
git commit -m "Update Robotask to version $($json.version)"
git push

cd "$env:USERPROFILE\Desktop\apps"
git add .
git commit -m "Update Robotask to version $($json.version)"
git push

Remove-Item -LiteralPath "$env:USERPROFILE\Desktop\RoboTask" -Force -Recurse -Confirm:$false

# Run scoop update and scoop update*
scoop update; scoop update*
