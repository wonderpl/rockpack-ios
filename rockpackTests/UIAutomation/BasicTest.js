
var target = UIATarget.localTarget();

UIATarget.onAlert = function onAlert(alert) {
    var title = alert.name();
    UIALogger.logMessage("Alert with title ’" + title + "’ encountered!");
    if (title == "Logout") {
        alert.buttons()["Logout"].tap();
        return true; // bypass default handler
    }
    return false; // use default handler
 }


target.frontMostApp().mainWindow().buttons()["Login Navigation"].tap();
target.frontMostApp().keyboard().typeString("automator");
target.frontMostApp().mainWindow().secureTextFields()["Password Field"].tap();
target.frontMostApp().keyboard().typeString("banana");
target.frontMostApp().mainWindow().buttons()["Login Action"].tap();
target.frontMostApp().mainWindow().buttons()["onboarding button ok"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()["MUSIC"].tapWithOptions({tapOffset:{x:0.79, y:0.50}});
target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()["POP"].tapWithOptions({tapOffset:{x:0.61, y:0.50}});
target.frontMostApp().mainWindow().scrollViews()[0].collectionViews()[1].cells()[0].tap();
target.frontMostApp().mainWindow().buttons()["onboarding button ok"].tap();
target.frontMostApp().mainWindow().buttons()["onboarding button ok"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonSubscribe"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonBackCD"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonNav"].tap();
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()["PROFILE"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].collectionViews()[3].cells()[0].tap();
target.frontMostApp().mainWindow().buttons()["ButtonSubscribe"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonBackCD"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonNav"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonSettings"].tap();
target.frontMostApp().mainWindow().popover().tableViews()["Empty list"].cells()["Logout"].tap();
// Alert detected. Expressions for handling alerts should be moved into the UIATarget.onAlert function definition.
target.frontMostApp().alert();

UIALogger.logPass("Login->Subscribe->Unsubscribe->Logout")

