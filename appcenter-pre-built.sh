
#SetiOS build version
#/usr/bin/find. -name *QRProcess/Info.plist -exec /usr/libexec/PlistBuddy -c Set :CFBundleVersion 1.2 {};

#/usr/libexec/PlistBuddy -c 'print ":$(CURRENT_PROJECT_VERSION)"' Info.plist

#buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFOPLIST_FILE}")

#/usr/libexec/PlistBuddy -c 'print ":CFBundleVersion"' QRProcess/Info.plist

plutil -replace CFBundleVersion -string "\($APP_VERSION)" QRProcess/Info.plist

# Auto increment script
#set buildVersion=/usr/libexec/PlistBuddy -c 'print ":CFBundleVersion"' QRProcess/Info.plist
#set buildV=buildVersion + 1
#/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildV" QRProcess/Info.plist

#echo "Hello World Shell $buildVersion"

#numone=1.0
#numtwo=1.2
#total=`echo $numone + $numtwo | bc`
#echo $total
