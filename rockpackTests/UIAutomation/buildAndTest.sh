xcodebuild \
ARCHS=i386 \
ONLY_ACTIVE_ARCH=NO \
-workspace "../../rockpack.xcworkspace" \
-scheme "rockpack" \
-sdk iphonesimulator6.1 \
-configuration Debug \
SYMROOT="$WORKSPACE/UIAutomationBuild/build" \
DSTROOT="$Workspace/UIAutomationBuild/build" \
TARGETED_DEVICE_FAMILY="2" \
install

osascript ./SimulatorReset.txt

instruments -t BasicTest "/Users/$USER/Documents/UIAutomationBuild/build/Applications/rockpack.app" -e UIASCRIPT "./BasicTest.js" -e UIARESULTSPATH "./result"