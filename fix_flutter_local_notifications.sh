#!/bin/bash

# Find the flutter_local_notifications plugin directory
PLUGIN_FILE=$(find ~/.pub-cache/hosted/pub.dev -name "FlutterLocalNotificationsPlugin.java" | grep "flutter_local_notifications-16.3.3")

if [ -z "$PLUGIN_FILE" ]; then
    echo "Flutter Local Notifications plugin file not found."
    exit 1
fi

echo "Found plugin file at: $PLUGIN_FILE"

# Create a backup of the original file
cp "$PLUGIN_FILE" "$PLUGIN_FILE.bak"
echo "Created backup at: $PLUGIN_FILE.bak"

# Apply the fix
sed -i 's/bigPictureStyle\.bigLargeIcon(null);/bigPictureStyle.bigLargeIcon((Bitmap) null);/g' "$PLUGIN_FILE"

echo "Fix applied successfully."
echo "Please rebuild your app."
