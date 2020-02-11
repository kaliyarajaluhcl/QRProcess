
#SetiOS build version
#/usr/bin/find. -name *QRProcess/Info.plist -exec /usr/libexec/PlistBuddy -c Set :CFBundleVersion 1.2 {};

#/usr/libexec/PlistBuddy -c 'print ":$(CURRENT_PROJECT_VERSION)"' Info.plist

#buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFOPLIST_FILE}")

/usr/libexec/PlistBuddy -c 'print ":CFBundleVersion"' QRProcess/Info.plist
