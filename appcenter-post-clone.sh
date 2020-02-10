
#SetiOS build version
#/usr/bin/find. -name *Info.plist -exec /usr/libexec/PlistBuddy -c Set :CFBundleVersion {};
/usr/libexec/PlistBuddy -c 'print ":CFBundleVersion"' Info.plist
