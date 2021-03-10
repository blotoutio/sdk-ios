//
//  eBayAPI.h
//  SalesDemoApp
//
//  Created by ankuradhikari on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface eBayAPI : NSObject

-(void)getSingleItemInfoWithQueryString:(long long )itemID Withsuccess:(void (^)(id responseObject))success failure:(void (^)(NSURLResponse * urlResponse, id dataOrLocation, NSError *error))failure;

-(void)getSubCategoriesInfoWithCategoryID:(long long)categoryID Withsuccess:(void (^)(id responseObject))success failure:(void (^)(NSURLResponse * urlResponse, id dataOrLocation, NSError *error))failure;

-(void)getCategoryInfoWithsuccess:(void (^)(id responseObject))success failure:(void (^)(NSURLResponse * urlResponse, id dataOrLocation, NSError *error))failure;

-(void)findItemsAdvancedInfoWithQueryString:(NSString*)querystring Withsuccess:(void (^)(id responseObject))success failure:(void (^)(NSURLResponse * urlResponse, id dataOrLocation, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
