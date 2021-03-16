//
//  ParallexViewController.m
//  SalesDemoApp
//
//  Created by ankuradhikari on 24/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "ParallexViewController.h"
#import <BlotoutAnalytics/BlotoutAnalytics.h>
#import "MXScrollViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@interface ParallexViewController () <MXParallaxHeaderDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *falcon;
@end

@implementation ParallexViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.parallaxHeader.delegate = self;
    [[BlotoutAnalytics sharedInstance] capture:@"Parallex View" withInformation:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(kBgQueue, ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imgUrl]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.falcon.image = [UIImage imageWithData:imgData];
        });
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <MXParallaxHeaderDelegate>

- (void)parallaxHeaderDidScroll:(MXParallaxHeader *)parallaxHeader {
    CGFloat angle = parallaxHeader.progress * M_PI * 2;
    self.falcon.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
}

@end
