# Integration

## SDK Download Link

```html
SDK Download Link: ​https://download.blotout.io/v1.0/sdks/BOiOSSDK.zip
```

## Add Blotout Analytics SDK into your project

To add the SDK to the Xcode project, simply drag the “SDK Library“ folder into your Xcode project and follow the on screen instructions. Please refer to the image below for recommended settings, click finish.

![Screenshot](assets/images/sdkintegration.png)

## Initialization

### Option 1 Objective-C:

```html
#import "BlotoutAnalytics.h";

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];
    
    [boaObj initializeAnalyticsEngineUsingKey:@"blotoutSDKKey" url:@"endPointUrl" andCompletionHandler:^(BOOL isSuccess, NSError * _Nonnull error) {
        NSLog(@"BlotoutAnalytics SDK version%@ and Init %d:or Error: %@", [boaObj sdkVersion], isSuccess, error);
        [boaObj logEvent:@"AppLaunched" withInformation:launchOptions];
    }];
    return YES;
}
```

### Option 2 Swift:
```html

func boSDKInit(isProductionMode : Bool) throws -> Void {
        let boaSDK : BlotoutAnalytics
        boaSDK =  BlotoutAnalytics.sharedInstance()!
        boaSDK.initializeAnalyticsEngine(usingKey: "blotoutSDKKey", url: "endPointUrl") { (isSuccess : Bool, errorObj:Error?) in
            if isSuccess{
                print("Integration Successful.")
                boaSDK.logEvent("AppLaunchedWithBOSDK", withInformation: nil)
            }else{
                print("Unexpected error:.")
            }
        }
    }

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try boSDKInit(isProductionMode: false)
        } catch {
            print("Unexpected error: \(error).")
        }
        return true
    }


```