xcodebuild \
ARCHS=i386 \
ONLY_ACTIVE_ARCH=NO \
-workspace "../../rockpack.xcworkspace" \
-scheme "rockpack" \
-sdk iphonesimulator6.1 \
-configuration Debug \
SYMROOT="/Users/$USER/Documents/TestExample/build" \
DSTROOT="/Users/$USER/Documents/TestExample/build" \
TARGETED_DEVICE_FAMILY="2" \
install

osascript ./SimulatorReset.txt

instruments -t BasicTest "/Users/$USER/Documents/TestExample/build/Applications/rockpack.app" -e UIASCRIPT "./BasicTest.js" -e UIARESULTSPATH "./result"