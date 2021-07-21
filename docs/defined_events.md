# Defined Events

## mapID
The `mapID` method allows you to map external services to Blotout ID.

#### Input
`-(void)mapID:(nonnull BOAMapIDDataModel*)mapIDData withInformation:(nullable NSDictionary*)eventInfo;`

|||||
|---|---|---|---|
| `mapIDData` | `Object` | Required | See data table. |
| `eventInfo` | `Object` | Optional | You can provide some additional data to this event. There is no limitation as this is just a key-value pair send to the server. |

#### Data

|              |          |          |                                                            |
| ------------ | -------- | -------- | ---------------------------------------------------------- |
| `externalID` | `String` | Required | External ID that you want to link to Blotout ID.           |
| `provider`   | `String` | Required | Provider that generated external ID, for example `hubspot` |


#### Example
```js
NSMutableDictionary *eventInfo = [[NSMutableDictionary alloc] init];
[eventInfo setValue:@"developers@blotout.io" forKey:@"emailId"];
[eventInfo setValue:@"Male" forKey:@"gender"];

BOAMapIDDataModel *data = [BOAMapIDDataModel new];
data.externalID = @"92j2jr230r-232j9j2342j3-jiji";
data.provider = @"sass";

BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];

[boaObj mapID:data withInformation:NULL];
[boaObj mapID:data withInformation:eventInfo];
```
