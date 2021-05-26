//
//  eBayAPI.m
//  SalesDemoApp
//
//  Created by ankuradhikari on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#define APP_ID                  @"Impetus06-f40e-4ba2-b112-1c3659ce305"   //@"ImpetusT-a79a-428c-a626-21b01e60abb6"
#define DEV_ID                    @"81b6fa40-2831-4ba5-b2a8-780146b0a599"
#define CERT_ID                 @"5e4661f8-88d7-4381-9694-f6cd57567b47"
#define HTTP_POST_METHOD        @"POST"

#import "eBayAPI.h"
#import "NetworkManager.h"
#import "DDXML.h"

@implementation eBayAPI

-(void)getSingleItemInfoWithQueryString:(long long )itemID Withsuccess:(void (^)(id responseObject))success failure:(void (^)(NSURLResponse * urlResponse, id dataOrLocation, NSError *error))failure
{
    
    NSString *path = [NSString stringWithFormat:@"shopping?"];
    NSMutableString *buffer = [[NSMutableString alloc] init];
    [buffer appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"];
    [buffer appendString:@"<GetSingleItemRequest xmlns=\"urn:ebay:apis:eBLBaseComponents\">"];
    [buffer appendString:[NSString stringWithFormat:@"<ItemID>%llu</ItemID>",itemID]];
    [buffer appendString:@"<IncludeSelector>Details,ItemSpecifics,ReturnPolicy</IncludeSelector>"];
    [buffer appendString:@"<DescriptionDetail>1</DescriptionDetail>"];
    [buffer appendString:@"</GetSingleItemRequest>​"];
    
    NSLog(@"Soap Req=%@",buffer);
    
    NSMutableURLRequest *theRequest = [self getRequestPath:path withBody:buffer withAPICallName:@"GetSingleItem"];
    
    
    [NetworkManager asyncRequest:theRequest success:^(id _Nonnull data, NSURLResponse * _Nonnull response) {
        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray  *dataArray=[self ParseFindItemsListwithString:responseString];
        success(dataArray);
    } failure:^(id _Nonnull data, NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
        
    }];
}
-(void)findItemsAdvancedInfoWithQueryString:(NSString*)querystring Withsuccess:(void (^)(id responseObject))success failure:(void (^)(NSURLResponse * urlResponse, id dataOrLocation, NSError *error))failure
{
    
    NSString *path = [NSString stringWithFormat:@"shopping?"];
    NSMutableString *buffer = [[NSMutableString alloc] init];
    [buffer appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"];
    [buffer appendString:@"<FindItemsAdvancedRequest xmlns=\"urn:ebay:apis:eBLBaseComponents\">"];
    [buffer appendString:[NSString stringWithFormat:@"<QueryKeywords>%@</QueryKeywords>",querystring]];
    [buffer appendString:@"<IncludeSelector>Details,SellerInfo,ItemSpecifics</IncludeSelector>"]; //,ItemSpecifics
    [buffer appendString:@"<MaxEntries>20</MaxEntries>"];
    [buffer appendString:@"<ItemSort>BestMatch</ItemSort>"];
    [buffer appendString:@"<SortOrder>Descending</SortOrder>"];
    [buffer appendString:@"<SearchFlag>LocalSearch</SearchFlag>"];
    [buffer appendString:@"<ItemType>AllItemTypes</ItemType>"];
    [buffer appendString:@"<DescriptionSearch>1</DescriptionSearch>"];
    [buffer appendString:@"<HideDuplicateItems>0</HideDuplicateItems>"];
    [buffer appendString:@"</FindItemsAdvancedRequest>​"];
    
    NSLog(@"Soap Req=%@",buffer);
    NSString* pNewBuff = [buffer stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    
    NSMutableURLRequest *theRequest = [self getRequestPath:path withBody:pNewBuff withAPICallName:@"FindItemsAdvanced"];
    
    [NetworkManager asyncRequest:theRequest success:^(id _Nonnull data, NSURLResponse * _Nonnull response) {
        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray  *dataArray=[self ParseFindItemsListwithString:responseString];
        success(dataArray);
        
    } failure:^(id _Nonnull data, NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
        
    }];
}

-(void)getSubCategoriesInfoWithCategoryID:(long long)categoryID Withsuccess:(void (^)(id responseObject))success failure:(void (^)(NSURLResponse * urlResponse, id dataOrLocation, NSError *error))failure{
    
    NSString *path = [NSString stringWithFormat:@"shopping?"];
    NSMutableString *buffer = [[NSMutableString alloc] init];
    [buffer appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"];
    [buffer appendString:@"<GetCategoryInfoRequest xmlns=\"urn:ebay:apis:eBLBaseComponents\">"];
    [buffer appendString:[NSString stringWithFormat:@"<CategoryID>%llu</CategoryID>",categoryID]];
    [buffer appendString:@"<IncludeSelector>ChildCategories</IncludeSelector>"];
    [buffer appendString:@"</GetCategoryInfoRequest>​"];
    
    NSLog(@"Soap Req=%@",buffer);
    
    NSMutableURLRequest *theRequest = [self getRequestPath:path withBody:buffer withAPICallName:@"GetCategoryInfo"];
    
    [NetworkManager asyncRequest:theRequest success:^(id _Nonnull data, NSURLResponse * _Nonnull response) {
        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray  *dataArray=[self ParseCategoryListWithString:responseString];
        success(dataArray);
        
    } failure:^(id _Nonnull data, NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
        failure(data,response,error);
    }];
}



-(void)getCategoryInfoWithsuccess:(void (^)(id responseObject))success failure:(void (^)(NSURLResponse * urlResponse, id dataOrLocation, NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"shopping?"];
    
    NSNumber *num=[NSNumber numberWithInt:-1];
    NSMutableString *buffer = [[NSMutableString alloc] init];
    [buffer appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"];
    [buffer appendString:@"<GetCategoryInfoRequest xmlns=\"urn:ebay:apis:eBLBaseComponents\">"];
    [buffer appendString:[NSString stringWithFormat:@"<CategoryID>%@</CategoryID>",num]];
    [buffer appendString:@"<IncludeSelector>ChildCategories</IncludeSelector>"];
    [buffer appendString:@"</GetCategoryInfoRequest>​"];
    
    NSLog(@"Soap Req=%@",buffer);
    
    NSMutableURLRequest *theRequest = [self getRequestPath:path withBody:buffer withAPICallName:@"GetCategoryInfo"];
    
    [NetworkManager asyncRequest:theRequest success:^(id _Nonnull data, NSURLResponse * _Nonnull response) {
        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray  *dataArray=[self ParseCategoryListWithString:responseString];
        success(dataArray);
        
    } failure:^(id _Nonnull data, NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
        failure(data,response,error);
    }];
    
}
#pragma mark
#pragma mark Request
#pragma mark

-(NSMutableURLRequest*)getRequestPath:(NSString*)path withBody:(NSString*)body withAPICallName:(NSString*)APICALLNAME  {
    
    NSString *fullPath = path;
    NSString *domain=@"open.api.ebay.com";
    NSString *connectionType = @"http";
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/%@",
                           connectionType,
                           domain, fullPath];
    
    NSURL *finalURL = [NSURL URLWithString:urlString];
    if (!finalURL) {
        return nil;
    }
    
    NSLog(@"EBEngine: finalURL = %@", finalURL);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:finalURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:10.0];
    [theRequest setHTTPMethod:HTTP_POST_METHOD];
    
    [theRequest setHTTPShouldHandleCookies:NO];
    
    //APICALLNAME=@"GetCategoryInfo";
    //  APICALLNAME=@"FindItemsAdvanced";
    //    APICALLNAME=@"GetSingleItem";
    
    [theRequest addValue:@"685" forHTTPHeaderField:@"X-EBAY-API-VERSION"];
    [theRequest addValue:APP_ID forHTTPHeaderField:@"X-EBAY-API-APP-ID"];
    [theRequest addValue:@"XML" forHTTPHeaderField:@"X-EBAY-API-REQUEST-ENCODING"];
    [theRequest addValue:APICALLNAME forHTTPHeaderField:@"X-EBAY-API-CALL-NAME"];
    //TODO: Need to change the site code as per the selection of country
    [theRequest addValue:@"0" forHTTPHeaderField:@"X-EBAY-API-SITEID"]; //203 FOR INDIA
    [theRequest addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    
    
    NSString *finalBody = @"";
    finalBody = [finalBody stringByAppendingString:body];
    if (finalBody) {
        [theRequest setHTTPBody:[finalBody dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return theRequest;
}

#pragma mark
#pragma mark Parsing Methods
#pragma mark
-(NSArray*)ParseFindItemsListwithString:(NSString*)xmlstring{
    
    NSMutableArray *dataArray=[[NSMutableArray alloc]init];
    DDXMLDocument *ddDoc = [[DDXMLDocument alloc] initWithXMLString:xmlstring options:0 error:nil];
    
    NSLog(@"PARSE DATA %@",ddDoc);
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"urn:ebay:apis:eBLBaseComponents",
                          @"ebay",
                          nil];
    
    NSArray *nodes = [ddDoc nodesForXPath:@"//ebay:Item"
                        namespaceMappings:dict error:nil];
    NSLog(@"Total Nodes=%lu",(unsigned long)[nodes count]);
    //for(int index=0;index<[nodes count]; index++)
    //    NSLog(@"parse data %@",[nodes objectAtIndex:index]);
    
    NSMutableDictionary *dictionary=nil;
    for(id node in nodes)
    {
        if(dictionary==nil)
            dictionary=[[NSMutableDictionary alloc]init];
        
        NSUInteger child=[node childCount];
        for (int index=0;index<child;index ++) {
            
            DDXMLNode *childNode=[node childAtIndex:index];
            NSUInteger childnode=[childNode childCount];
            if (childnode>1) {
                
                NSMutableDictionary *childDict=[[NSMutableDictionary alloc]init];
                for (int index=0;index<childnode;index ++) {
                    
                    DDXMLNode *childs=[childNode childAtIndex:index];
                    NSString* childname = [childs name];
                    [childDict setObject:[childs stringValue] forKey:childname];
                    //NSLog(@"Dictionary Data  %@ ",childDict);
                }
                NSString* name = [childNode name];
                [dictionary setObject:childDict forKey:name];
                childDict =nil;
            }
            else {
                
                NSString* name = [childNode name];
                [dictionary setObject:[childNode stringValue] forKey:name];
            }
            
            
        }
        [dataArray addObject:dictionary];
        dictionary=nil;
        //[dictionary release];
        
    }
    
    return dataArray;
}

-(NSArray*)ParseCategoryListWithString:(NSString*)xmlstring{
    
    NSMutableArray *dataArray=[NSMutableArray array];
    DDXMLDocument *ddDoc = [[DDXMLDocument alloc] initWithXMLString:xmlstring options:0 error:nil];
    
    NSLog(@"PARSE DATA %@",ddDoc);
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"urn:ebay:apis:eBLBaseComponents",
                          @"ebay",
                          nil];
    
    NSArray *nodes = [ddDoc nodesForXPath:@"//ebay:Category"
                        namespaceMappings:dict error:nil];
    NSLog(@"Total Nodes=%lu",(unsigned long)[nodes count]);
    //for(int index=0;index<[nodes count]; index++)
    //    NSLog(@"parse data %@",[nodes objectAtIndex:index]);
    
    NSMutableDictionary *dictionary=nil;
    
    for(id node in nodes)
    {
        if(dictionary==nil)
            dictionary=[[NSMutableDictionary alloc]init];
        NSUInteger child=[node childCount];
        for(int index=0;index<child;index++)
        {
            DDXMLNode *childNode=[node childAtIndex:index];
            NSString* name = [childNode name];
            [dictionary setObject:[childNode stringValue] forKey:name];
            
        }
        
        [dataArray addObject:dictionary];
        //[dictionary release];
        dictionary=nil;
    }
    
    NSLog(@"Dictionary Data  %@ ",dataArray);
    
    if(ddDoc)
    {
        ddDoc = nil;
    }
    
    return dataArray;
    
}


@end
