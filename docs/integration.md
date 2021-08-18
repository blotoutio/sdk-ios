# Integration

## Add Blotout Analytics SDK into your project
Blotout Analytics SDK is available through CocoaPods. To install it, simply follow below steps:

### CocoaPods

Use [CocoaPods](http://www.cocoapods.org). Cocoapods is a dependency manager for Cocoa projects. For usage visit their website.

1. To install CocoaPods, run `sudo gem install cocoapods` in your console.
2. Change the directory on the terminal to the Xcode project file (.xcodeproj)'s location. `cd ~/BlotoutDemo`
3. Run `touch Podfile` on the terminal to create the Podfile in that directory.
4. Now open the pod file created in previous step and add `use_frameworks!` `pod 'Blotout-Analytics'`  to your *Podfile*.
5. Install the pod(s) by running `pod install`.
6. Moving forward open the project using workspace file (.xcworkspace)
7. Add `import BlotoutAnalyticsSDK ` in the .swift files where you want to use it.

## Initialization

### Option 1 Objective-C:

```ios

@import BlotoutAnalyticsSDK;
    
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];
    
    BlotoutAnalyticsConfiguration *config = [BlotoutAnalyticsConfiguration configurationWithToken:@"token" withUrl:@"endPointUrl"];
    config.launchOptions = launchOptions;
    [boaObj init:config andCompletionHandler:^(BOOL isSuccess, NSError * _Nonnull error) {
             NSLog(@"BlotoutAnalytics Init %d:or Error: %@", isSuccess, error);
    }];
    return YES;
}
```

### Option 2 Swift:
```ios

@import BlotoutAnalyticsSDK;

func boSDKInit() throws -> Void {
    let boaSDK : BlotoutAnalytics
    boaSDK =  BlotoutAnalytics.sharedInstance()!
    let config = BlotoutAnalyticsConfiguration.init(token: "token", withUrl: "endPointUrl")
    config.launchOptions = launchOptions;
    boaSDK.`init`(config) { (isSuccess : Bool, errorObj:Error?) in
        if isSuccess{
            print("Integration Successful.")
            boaSDK.capture("AppLaunchedWithBOSDK", withInformation: nil)
        }else{
            print("Unexpected error:.")
        }
        boaSDK.capture("AppLaunchedWithBOSDK", withInformation: nil)
    }
}

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    do {
        try boSDKInit()
    } catch {
        print("Unexpected error: \(error).")
    }
    return true
}
```
