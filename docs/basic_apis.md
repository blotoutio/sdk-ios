# API

## init
The `init` method is used for initializing SDK. This sets all required configurations and also sends system event `sdk_start` which allows it to record user.

#### Input
`-(void)init:(BlotoutAnalyticsConfiguration*_Nullable)configuration andCompletionHandler:(void (^_Nullable)(BOOL isSuccess, NSError * _Nullable error))completionHandler;`

|||||
|---|---|---|---|
| `configuration` | `BlotoutAnalyticsConfiguration` | | This Model contains information related to SDK initialization |
| `completionHandler` | `callback` |  | Return callback for sdk success and failure |

#### Example
```js
BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];
BlotoutAnalyticsConfiguration *config = [BlotoutAnalyticsConfiguration configurationWithToken:@"token" withUrl:@"endPointUrl"];
config.launchOptions = launchOptions;
[boaObj init:config andCompletionHandler:^(BOOL isSuccess, NSError * _Nonnull error) {
    NSLog(@"BlotoutAnalytics Init %d:or Error: %@", isSuccess, error);
    [boaObj capture:@"AppLaunched" withInformation:launchOptions]; 
}];
```

## capture
The `capture` method is used to record developer events. This allows you to send custom events to the server when a user is interacting with the app. For example, one custom event would be when a user adds an item to a cart.

#### Input
`-(void)capture:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo;`

|||||
|---|---|---|---|
| `eventName` | `String` |  | Name of the event that you are sending |
| `eventInfo` | `Object` | Optional | You can provide some additional data to this event. There is no limitation as this is just a key-value pair send to the server. |

#### Example
```js
NSMutableDictionary *eventInfo = [[NSMutableDictionary alloc] init];
[eventInfo setValue:@"SKU" forKey:@"123123"];
[eventInfo setValue:@"itemName" forKey:@"phone"];

BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];
[boaObj capture:@"add-to-cart" withInformation:eventInfo];
```

## capturePersonal
PII (Personal Identifiable Information) events are like developer codified events that carry sensitive information related to the user.
PHI ( Protected Health Information) events are like PII, but carry user’s private health information.
In Blotout managed or deployed Infrastructure, PII and PHI events data is encrypted using asymmetric encryption algorithms and provides access to authenticated users only.

#### Input
`-(void)capturePersonal:(nonnull NSString*)eventName withInformation:(nullable NSDictionary*)eventInfo isPHI:(BOOL)phiEvent;`

|||||
|---|---|---|---|
| `eventName` | `String` |  | Name of the event that you are sending |
| `eventInfo` | `Object` | | You can provide some additional data to this event. There is no limitation as this is just a key-value pair send to the server. |
| `phiEvent` | `Boolean` | Optional | You can specify specific event type to an event|


#### Example
```js
BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];

NSMutableDictionary *PIIInfo = [[NSMutableDictionary alloc] init];
[eventInfo setValue:@"developers@blotout.io" forKey:@"emailId"];
[boaObj capturePersonal:@"PII Event" withInformation:PIIInfo isPHI:NO];

NSMutableDictionary *PHIInfo = [[NSMutableDictionary alloc] init];
[eventInfo setValue:@"bloodType" forKey:@"A+"];
[boaObj capturePersonal:@"PHI Event" withInformation:PHIInfo isPHI:YES];
```

## getUserId
The `getUserId` method allows you to go get Blotout user id that is linked to all data that is sent to the server.

#### Output
Returns user ID as `string`.

#### Example
```js
NSString *userId = [[BlotoutAnalytics sharedInstance] getUserId];
```

## enableSDKLog
The `enableSDKLog` method allows you to print all SDK logs on console.

#### Example
```js
[BlotoutAnalytics sharedInstance].enableSDKLog = YES;
```

## enable
The `enable` method allows you to enable/disable the sending of analytics data. Enabled by default.

#### Example
```js
[BlotoutAnalytics sharedInstance].enable = NO;
```

## Application level methods handling

## Remote Notification
This method is used for tracking remote notification

#### Input
- (void)receivedRemoteNotification:(NSDictionary *_Nullable)userInfo;

#### Example
```js
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [BlotoutAnalytics sharedInstance] receivedRemoteNotification:notification.userInfo];
}
```

## Remote Notification
This method is used to notify when app failed to register for remote notification

#### Input
- (void)failedToRegisterForRemoteNotificationsWithError:(NSError *_Nullable)error;

#### Example
```js
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error  {
    [BlotoutAnalytics sharedInstance] failedToRegisterForRemoteNotificationsWithError:error];
}
```

## Remote Notification
This method is used to notify when app register for remote notification

#### Input
- (void)registeredForRemoteNotificationsWithDeviceToken:(NSData *_Nullable)deviceToken;

#### Example
```js
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [BlotoutAnalytics sharedInstance] registeredForRemoteNotificationsWithDeviceToken:deviceToken];
}
```

## User Activity
This method is used to track deep linking

#### Input
- (void)continueUserActivity:(NSUserActivity *_Nonnull)activity;

#### Example
```js
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    [BlotoutAnalytics sharedInstance] continueUserActivity:userActivity];
}
```

## User Activity
This method is used to track deep linking

#### Input
- (void)openURL:(NSURL *_Nullable)url options:(NSDictionary *_Nonnull)options;

#### Example
```js
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [BlotoutAnalytics sharedInstance] openURL:url options:options];
}
```

## Appendix

**BlotoutAnalyticsConfiguration**

|||||
|---|---|---|---|
| `token` | `String` |  | Application token that you can get in your dashboard. |
| `endpointUrl` | `String` |  | Url where you will be sending data. |
