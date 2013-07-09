osascript ./SimulatorReset.txt

xcodebuild \
ARCHS=i386 \
ONLY_ACTIVE_ARCH=NO \
-workspace "../../rockpack.xcworkspace" \
-scheme "rockpack" \
-sdk iphonesimulator6.1 \
-configuration Debug \
SYMROOT="/Users/$USER/Documents/UIAutomationBuild/build" \
DSTROOT="/Users/$USER/Documents/UIAutomationBuild/build" \
TARGETED_DEVICE_FAMILY="1" \
clean \
build \
install

./choose_sim_device "iPhone"

instruments -t BasicTest "/Users/$USER/Documents/UIAutomationBuild/build/Applications/rockpack.app" -e UIASCRIPT "./BasicIphone.js" -e UIARESULTSPATH "./result"