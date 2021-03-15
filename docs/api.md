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
[eventInfo setValue:@"developers@blotout.io" forKey:@"emailId"];
[eventInfo setValue:@"Male" forKey:@"gender"];

BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];
[boaObj capture:@"LoginView" withInformation:eventInfo];
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
| `eventInfo` | `Object` | Optional | You can provide some additional data to this event. There is no limitation as this is just a key-value pair send to the server. |
| `phiEvent` | `Boolean` | Optional | You can specify specific event type to an event|


#### Example
```js
NSMutableDictionary *eventInfo = [[NSMutableDictionary alloc] init];
[eventInfo setValue:@"developers@blotout.io" forKey:@"emailId"];
[eventInfo setValue:@"Male" forKey:@"gender"];

BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];

[boaObj capturePersonal:@"PII Event" withInformation:eventInfo isPHI:NO];
[boaObj capturePersonal:@"PHI Event" withInformation:eventInfo isPHI:YES];
```


## mapID
The `mapID` method allows you to map external services to Blotout ID.

#### Input
`-(void)mapID:(nonnull NSString*)externalId forProvider:(nonnull NSString*)provider withInformation:(nullable NSDictionary*)eventInfo;`

|||||
|---|---|---|---|
| `externalId` | `String` |  | External ID that you want to link to Blotout ID |
| `provider` | `String` |  | Provider that generated external ID, for example `hubspot` |
| `eventInfo` | `Object` | Optional | You can provide some additional data to this event. There is no limitation as this is just a key-value pair send to the server. |

#### Example
```js
NSMutableDictionary *eventInfo = [[NSMutableDictionary alloc] init];
[eventInfo setValue:@"developers@blotout.io" forKey:@"emailId"];
[eventInfo setValue:@"Male" forKey:@"gender"];

BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];

[boaObj mapID:@"92j2jr230r-232j9j2342j3-jiji" forProvider:@"hubspot" withInformation:NULL];
[boaObj mapID:@"92j2jr230r-232j9j2342j3-jiji" forProvider:@"hubspot" withInformation:eventInfo];

```

## getUserId
The `getUserId` method allows you to go get Blotout user id that is linked to all data that is sent to the server.

#### Output
Returns user ID as `string`.

#### Example
```js
NSString *userId = [[BlotoutAnalytics sharedInstance] getUserId];
```
