@echo off
setlocal enabledelayedexpansion

REM Find the flutter_local_notifications plugin directory
for /f "tokens=*" %%a in ('dir /s /b "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\flutter_local_notifications-16.3.3\android\src\main\java\com\dexterous\flutterlocalnotifications\FlutterLocalNotificationsPlugin.java" 2^>nul') do (
    set "plugin_file=%%a"
)

if not defined plugin_file (
    echo Flutter Local Notifications plugin file not found.
    exit /b 1
)

echo Found plugin file at: !plugin_file!

REM Create a backup of the original file
copy "!plugin_file!" "!plugin_file!.bak"
echo Created backup at: !plugin_file!.bak

REM Apply the fix
powershell -Command "(Get-Content '!plugin_file!') -replace 'bigPictureStyle\.bigLargeIcon\(null\);', 'bigPictureStyle.bigLargeIcon((Bitmap) null);' | Set-Content '!plugin_file!'"

echo Fix applied successfully.
echo Please rebuild your app.

endlocal
