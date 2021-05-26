//
//  LoginViewController.h
//  SalesDemoApp
//
//  Created by ankuradhikari on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *MemInfoTagLbl;
@property (weak, nonatomic) IBOutlet UILabel *memInfoValLbl;
@property (weak, nonatomic) IBOutlet UITextField *testToken;
@property (weak, nonatomic) IBOutlet UITextField *productionToken;
@property (weak, nonatomic) IBOutlet UIButton *modeButton;

- (IBAction)testTokenEdited:(id)sender;
- (IBAction)prodcutionTokenEdited:(id)sender;
- (IBAction)modeChangeClicked:(id)sender;

@end

NS_ASSUME_NONNULL_END
