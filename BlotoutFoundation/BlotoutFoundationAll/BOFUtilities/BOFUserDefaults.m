//
//  BOFUserDefaults.m
//  BlotoutFoundation
//
//  Created by Blotout on 28/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOFUserDefaults.h"
#import "BOFLogs.h"
#include "BOFConstants.h"
#import "BlotoutFoundation.h"

@interface BOFUserDefaults()
@property(nonatomic,strong)NSString *productKey;
@property(atomic,strong)NSMutableDictionary *productContainer;
@end


static NSMutableDictionary *sBOFDefaultMap = nil;
static dispatch_queue_t sBOFDefaultsSerialQueue = nil;

@implementation BOFUserDefaults

+(void)initialize{
    @try {
        sBOFDefaultMap = [NSMutableDictionary dictionary];
        sBOFDefaultsSerialQueue = dispatch_queue_create(BO_SDK_DEFAULT_QUEUE, DISPATCH_QUEUE_SERIAL);
        
    } @catch (NSException *exception) {
         BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

-(instancetype)initWithProduct:(NSString *)key{
    @try {
        self = [super init];
        if ( self ) {
            self.productKey = key;
        }
        return self;
    } @catch (NSException *exception) {
         BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

+(_Nonnull instancetype)userDefaultsForProduct:( NSString * _Nonnull )product{
    @try {
        __block BOFUserDefaults *defaultsInstance = nil;
        dispatch_sync(sBOFDefaultsSerialQueue, ^{
            defaultsInstance = (BOFUserDefaults *)[sBOFDefaultMap objectForKey:product];
            if ( defaultsInstance == nil ) {
                defaultsInstance = [[BOFUserDefaults alloc] initWithProduct:product];
                [sBOFDefaultMap setObject:defaultsInstance forKey:product];
            }
        });
        return defaultsInstance;
    } @catch (NSException *exception) {
         BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

+(void)root:(void( ^ _Nonnull )(NSMutableDictionary * _Nonnull root ))updateBlock
{
    @try {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        NSDictionary *rootImmutable = [ud dictionaryForKey:BO_SDK_ROOT_USER_DEFAULTS_KEY];
        
        if ( rootImmutable == nil  ) {
            rootImmutable = @{};
        }
        
        NSMutableDictionary *rootMutable = [rootImmutable mutableCopy];
        
        updateBlock(rootMutable);
        
        [ud setObject:rootMutable forKey:BO_SDK_ROOT_USER_DEFAULTS_KEY];
        
        [ud synchronize];
    } @catch (NSException *exception) {
         BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}


-(void)updateDefaultForProduct:( BOOL (^ _Nonnull )(NSMutableDictionary * _Nonnull produtContainer) )updateBlock{
    @try {
        __weak BOFUserDefaults *weakSelf = self;
        [BOFUserDefaults root:^(NSMutableDictionary * _Nonnull root) {
            
            //Get the product level defaults
            //Eg:
            // com.blotout.root.sdk
            //      -- Product1
            //          --Product1 defaults
            //      -- Product2
            //          --Product2 defaults
            NSMutableDictionary *productContainer = [[root objectForKey:weakSelf.productKey] mutableCopy];
            if ( productContainer == nil ) {
                productContainer = [@{} mutableCopy];
            }
            
            //have the defaults write to product container
            BOOL hasChanged = updateBlock(productContainer);
            if (hasChanged ) {
                [root setObject:productContainer forKey:weakSelf.productKey];
            }
            
        }];
    } @catch (NSException *exception) {
         BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}


-(void)setObject:(nullable id)obj forKey:(nonnull id<NSCopying>)aKey{
    @try {
        if ( obj == nil ) {
            return;
        }
        
        //We have batch updates in progress
        if ( self.productContainer != nil ) {
            [self.productContainer setObject:obj forKey:aKey];
        }
        else{
            [self updateDefaultForProduct:^BOOL(NSMutableDictionary * _Nonnull produtContainer) {
                [produtContainer setObject:obj forKey:aKey];
                return TRUE;
            }];
        }
    } @catch (NSException *exception) {
         BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

-(void)removeObjectForKey:(nonnull id<NSCopying>)aKey{
    @try {
        if ( self.productContainer != nil ) {
            [self.productContainer removeObjectForKey:aKey];
        }
        else{
            [self updateDefaultForProduct:^BOOL(NSMutableDictionary * _Nonnull produtContainer) {
                [produtContainer removeObjectForKey:aKey];
                return TRUE;
            }];
        }
    } @catch (NSException *exception) {
         BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }

}

-(nullable id)objectForKey:(nonnull id<NSCopying>)key{
    @try {
        __block id object = nil;
        
        if (self.productContainer != nil ) {
            object = [self.productContainer objectForKey:key];
        }
        else{
            [self updateDefaultForProduct:^BOOL(NSMutableDictionary * _Nonnull produtContainer) {
                object = [produtContainer objectForKey:key];
                return NO;
            }];
        }
        
        return object;
    } @catch (NSException *exception) {
         BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

-(void)batchUpdates:( void(^ _Nonnull )(BOFUserDefaults *  _Nonnull defaults))updateBlock{
    @try {
        [self updateDefaultForProduct:^BOOL(NSMutableDictionary * _Nonnull produtContainer) {
            self.productContainer = produtContainer;
            updateBlock(self);
            self.productContainer = nil;
            return TRUE;
        }];
    } @catch (NSException *exception) {
         BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

@end
