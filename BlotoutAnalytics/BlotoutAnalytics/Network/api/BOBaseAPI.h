//
//  BOBaseAPI.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOANetworkConstants.h"
#import <BlotoutFoundation/BlotoutFoundation.h>
#import "BONetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

#define EPAPostAPI @"POST"
#define EPAGetAPI @"GET"
#define EPAContentApplicationJson @"application/json"

typedef NS_ENUM(NSUInteger, BOUrlEndPoint) {
  BOUrlEndPointEventPublish = 0,
  BOUrlEndPointManifestPull
};

@interface BOBaseAPI : NSObject

/* These method performs NSData to NSDictionary conversion */
-(NSDictionary*)getJsonData:(NSData*)data;

/* These method used to prepare end point*/
-(NSString*)resolveAPIEndPoint:(BOUrlEndPoint)endPoint;

/* These method used to prepare common request headers to send along with every request */
-(NSDictionary*)prepareRequestHeaders;

/* This Method check for null value in response data and replace it with empty string */
-(NSData*)checkForNullValue:(NSData*)data;

/*This methods return baseServerUrl */
-(NSString*)getBaseServerUrl;

@end

NS_ASSUME_NONNULL_END
