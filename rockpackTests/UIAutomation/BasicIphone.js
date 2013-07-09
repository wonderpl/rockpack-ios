
var target = UIATarget.localTarget();
var window = target.frontMostApp().mainWindow();

UIATarget.onAlert = function onAlert(alert) {
    var title = alert.name();
    UIALogger.logMessage("Alert with title ’" + title + "’ encountered!");
    if (title == "Logout") {
        alert.buttons()["Logout"].tap();
        return true; // bypass default handler
    }
    return false; // use default handler
 }

target.pushTimeout(10);
target.frontMostApp().mainWindow().buttons()["Login Navigation"].tap();
target.frontMostApp().keyboard().typeString("automator");
target.frontMostApp().mainWindow().secureTextFields()["Password Field"].tap();
target.frontMostApp().keyboard().typeString("banana\n");
window.staticTexts()["Page Title"].value() == "CHANNELS";
window.staticTexts()["Page Title"].withValueForKey(1, "isVisible");
target.frontMostApp().mainWindow().buttons()["onboarding button ok"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()["ALL CATEGORIES"].tapWithOptions({tapOffset:{x:0.36, y:0.08}});
window.scrollViews()[0].tableViews()["Genre Table"].withValueForKey(1,"isVisible");
window.scrollViews()[0].tableViews()["Genre Table"].groups()["MUSIC"].withValueForKey(1,"isVisible");
target.frontMostApp().mainWindow().scrollViews()[0].tableViews()["Genre Table"].groups()["MUSIC"].buttons()[0].tap();
target.frontMostApp().mainWindow().scrollViews()[0].tableViews()["Genre Table"].cells()["POP"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].collectionViews()[1].cells()[0].tap();
target.frontMostApp().mainWindow().buttons()["onboarding button ok"].tap();
target.frontMostApp().mainWindow().buttons()["onboarding button ok"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonSubscribe"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonNavCD"].tap();
target.frontMostApp().mainWindow().tableViews()["Navigation Table"].cells()["PROFILE"].tap();
window.staticTexts()["Page Title"].value() == "PROFILE";
target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()["MY SUBSCRIPTIONS (1)"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].collectionViews()[2].cells()[0].tap();
target.frontMostApp().mainWindow().buttons()["ButtonSubscribe"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonBackCD"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonNav"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonSettings"].tap();
target.frontMostApp().mainWindow().tableViews()["Settings Table"].scrollDown();
target.frontMostApp().mainWindow().tableViews()["Settings Table"].scrollDown();
target.frontMostApp().mainWindow().tableViews()["Settings Table"].scrollDown();
target.frontMostApp().mainWindow().tableViews()["Settings Table"].cells()["Logout"].tap();

target.frontMostApp().alert();
target.popTimeout();

UIALogger.logPass("Login->Subscribe->Unsubscribe->Logout");