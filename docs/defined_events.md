# Defined Events

## mapID
The `mapID` method allows you to map external services to Blotout ID.

#### Input
```swift
-(void)mapID:(nonnull BOAMapIDDataModel*)mapIDData withInformation:(nullable NSDictionary*)eventInfo;
```

| Key Name |  Datatype     |  Required ?        |    Description                                                        |
| ------------ | -------- | -------- | ---------------------------------------------------------- |
| `mapIDData` | `Object` | Required | See data table. |
| `eventInfo` | `Object` | Optional | You can provide some additional data to this event. There is no limitation as this is just a key-value pair send to the server. |

#### Data

| Key Name |  Datatype     |  Required ?        |    Description                                                        |
| ------------ | -------- | -------- | ---------------------------------------------------------- |
| `externalID` | `String` | Required | External ID that you want to link to Blotout ID.           |
| `provider`   | `String` | Required | Provider that generated external ID, for example `hubspot` |


#### Example
```swift
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

## transaction

The `transaction` method allows you to record tranasctions in your system, like purchase in ecommerce.

#### Input
```swift
-(void)captureTransaction:(nonnull TransactionData*)transactionData withInformation:(nullable NSDictionary*)eventInfo;
```

| Key Name |  Datatype     |  Required ?        |    Description                                                        |
| ---------------- | -------- | -------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `transactionData`      | `TransactionData` | Required | See data table. |
| `additionalData` | `Dictionary` | Optional | You can provide some additional data to this event. There is no limitation as this is just a key-value pair send to the server. |

#### Data

| Key Name |  Datatype     |  Required ?        |    Description                                                        |
| ------------ | -------- | -------- | ---------------------------------------------------------- |
| `transaction_id` | `String` | Required | Transaction ID.           |
| `transaction_currency`   | `String` | Optional | Currency used for the transaction. Example: `EUR` |
| `transaction_total`   | `Double` | Optional | Total amount for the transaction. Example `10.50` |
| `transaction_discount`   | `Double` | Optional | Discount that was applied in the transaction. Example: `2.1` |
| `transaction_shipping`   | `Double` | Optional | Shipping that was charged in the transaction. Example: `5.0` |
| `transaction_tax`   | `Double` | Optional | How much tax was applied in the transaction. Example: `1.21` |

#### Example


```swift
    TransactionData *testTransaction = [[TransactionData alloc]init];
    
    testTransaction.transaction_id = @"456";
    testTransaction.transaction_tax = [NSNumber numberWithInt:3.5];
    testTransaction.transaction_total = [NSNumber numberWithInt:654];
    testTransaction.transaction_currency = @"USD";
    testTransaction.transaction_discount = [NSNumber numberWithInt:1];
    testTransaction.transaction_shipping = [NSNumber numberWithInt:34];

    BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];
    [boaObj captureTransaction:testTransaction withInformation:@{@"time":[NSDate date], @"VC Name":@"CategoryViewVC"}];

```
## item

The `item` method allows you to record item in your system, like add to cart in ecommerce.

#### Input
```swift
-(void)captureItem:(nonnull Item*)itemData withInformation:(nullable NSDictionary*)eventInfo;
```

| Key Name |  Datatype     |  Required ?        |    Description                                                        |
| ---------------- | -------- | -------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `data`      | `Item` | Required | See data table.|
| `additionalData` | `Dictionary` | Optional | You can provide some additional data to this event. There is no limitation as this is just a key-value pair send to the server. |

#### Data

| Key Name |  Datatype     |  Required ?        |    Description                                                        |
| ------------ | -------- | -------- | ---------------------------------------------------------- |
| `item_id` | `String` | Required | Item ID.           |
| `item_name`   | `String` | Optional | Example: `Phone 4` |
| `item_sku`   | `String` | Optional | Example: `SHOP-01` |
| `item_category`   | `Array` | Optional | Example `['mobile', 'free-time]` |
| `item_currency`   | `String` | Optional | Currency of item price. Example: `EUR` |
| `item_price`   | `Double` | Optional | Example: `2.1` |
| `item_quantity`   | `Double` | Optional | Example: `3` |

#### Example
```swift
    Item * testItem = [[Item alloc] init];
    
    testItem.item_id = @"123";
    testItem.item_sku = @"A123";
    testItem.item_name = @"Test Item";
    testItem.item_price = [NSNumber numberWithInt:239];
    testItem.item_category = @[@"TestCategory"];
    testItem.item_currency = @"USD";
    testItem.item_quantity = [NSNumber numberWithInt:1];
    
    BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];
    [boaObj captureItem:testItem withInformation:@{@"time":[NSDate date], @"VC Name":@"CategoryViewVC"}];
```

## persona

The `persona` method allows you to record persona in your system, like when user signs up or saves user profile.

#### Input
`-(void)capturePersona:(nonnull Persona*)personaData withInformation:(nullable NSDictionary*)eventInfo;`

| Key Name |  Datatype     |  Required ?        |    Description                                                        |
| ---------------- | -------- | -------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `data`      | `Object` | Required | See data table.|
| `additionalData` | `Dictionary` | Optional | You can provide some additional data to this event. There is no limitation as this is just a key-value pair send to the server. |

#### Data

| Key Name |  Datatype     |  Required ?        |    Description                                                        |
| ------------ | -------- | -------- | ---------------------------------------------------------- |
| `persona_id` | `String` | Required | Persona ID.           |
| `persona_firstname`   | `String` | Optional | Example: `Alice` |
| `persona_lastname`   | `String` | Optional | Example: `Wonderland` |
| `persona_middlename`   | `String` | Optional | Example `Magic` |
| `persona_username`   | `String` | Optional | Example: `Alice_in_Wonderland` |
| `persona_dob`   | `String` | Optional | Date of birth. Example: `26/11/1865` |
| `persona_email`   | `String` | Optional | Example: `Alice@wonderland.com` |
| `persona_number`   | `String` | Optional | Example: `+38631777444` |
| `persona_address`   | `String` | Optional | Example: `Down the rabbit hole` |
| `persona_city`   | `String` | Optional | Example: `Adventureland` |
| `persona_state`   | `String` | Optional | Example: `lookingGlass` |
| `persona_zip`   | `Double` | Optional | Example: `10000` |
| `persona_country`   | `String` | Optional | Example: `Middle Earth` |
| `persona_gender`   | `String` | Optional | Example: `Female` |
| `persona_age`   | `Double` | Optional | Example: `82` |

#### Example
```swift
Persona *testPerson = [[Persona alloc]init];

testPerson.persona_id = @"000001";
testPerson.persona_age = [NSNumber numberWithInt:82];
testPerson.persona_dob = @"26/11/1865";
testPerson.persona_zip = [NSNumber numberWithInt:10000];
testPerson.persona_city = @"Adventureland";
testPerson.persona_email = @"Alice@wonderland.com";
testPerson.persona_state = @"lookingGlass";
testPerson.persona_gender = @"Female";

testPerson.persona_number = @"+38631777444";
testPerson.persona_address = @"Down the rabbit hole";
testPerson.persona_country = @"Middle Earth";
testPerson.persona_firstname = @"Alice";
testPerson.persona_lastname = @"Wonderland";
testPerson.persona_username = @"Alice_in_Wonderland";
testPerson.persona_middlename = @"Magic";

BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];
[boaObj capturePersona:testPerson withInformation:@{@"time":[NSDate date], @"VC Name":@"CategoryViewVC"}];
```