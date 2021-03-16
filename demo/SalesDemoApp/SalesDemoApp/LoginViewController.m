//
//  LoginViewController.m
//  SalesDemoApp
//
//  Created by ankuradhikari on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "LoginViewController.h"
#import "CategoryViewController.h"
#import <BlotoutAnalytics/BlotoutAnalytics.h>
#import <mach/mach.h>
#import <BlotoutAnalytics/BlotoutAnalytics.h>

static NSString *memInfoStr = @"";
static NSString *memFreeInfoStr = @"";

@interface LoginViewController ()
{
    BlotoutAnalytics *boaObj;
}

@end

@implementation LoginViewController

- (IBAction)loginAction:(id)sender {
    CategoryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

void print_free_memory ()
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
    }
    
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    
    natural_t mem_free = vm_stat.free_count * pagesize;
    
    natural_t mem_total = mem_used + mem_free;
    //memFreeInfoStr = [NSString stringWithFormat:@"used: %u free: %u total: %u", mem_used, mem_free, mem_total];
    //memFreeInfoStr = [NSString stringWithFormat:@"used: %u free: %u total: %u", mem_used/1048576, mem_free/1048576, mem_total/1048576];
    
    memFreeInfoStr = [NSString stringWithFormat:@"total: %u", mem_total/1048576];
    NSLog(@"used: %u free: %u total: %u", mem_used, mem_free, mem_total);
}

void report_memory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %lu", info.resident_size);
        NSLog(@"Memory in use (in MiB): %f", ((CGFloat)info.resident_size / 1048576));
        memInfoStr = [NSString stringWithFormat:@"Memory use(MiB): %f", ((CGFloat)info.resident_size / 1048576)];
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    report_memory();
    print_free_memory();
    self.MemInfoTagLbl.text = memFreeInfoStr;
    self.memInfoValLbl.text = memInfoStr;
    
    //[[BlotoutAnalytics sharedInstance] logEvent:@"LoginView" withInformation:@{@"vc":@"LVC"}];
    [[BlotoutAnalytics sharedInstance] capture:@"LoginView" withInformation:nil];
    //self.testToken.text = @"UHE44839MMUNM26";
    //self.productionToken.text = @"7J9MXNPYCEDTAYH";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    boaObj = [BlotoutAnalytics sharedInstance];
    
    UIImageView *pImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"windows-shopper.png"]];
    self.navigationItem.titleView = pImageView;
    // Do any additional setup after loading the view.
    //[[BlotoutAnalytics sharedInstance] logEvent:@"LoginView" withInformation:@{@"vc":@"LVC"}];
    report_memory();
    print_free_memory();
    self.MemInfoTagLbl.text = memFreeInfoStr;
    self.memInfoValLbl.text = memInfoStr;
    
    self.testToken.text = @"UHE44839MMUNM26";
    self.productionToken.text = @"7J9MXNPYCEDTAYH";
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)testTokenEdited:(id)sender {
    //    UITextField *currentTxtFld = (UITextField*)sender;
    //    NSString *newToken = currentTxtFld.text;
    
    //[boaObj updateAnalyticsEngineTest:newToken andProduction:self.productionToken.text];
    //    boaObj.isProductionMode = NO;
    //    [boaObj initializeAnalyticsEngineUsingTest:@"UHE44839MMUNM26" andProduction:@"7J9MXNPYCEDTAYH" withCompletionHandler:^(BOOL isSuccess, NSError * _Nonnull error) {
    //        NSLog(@"BlotoutAnalytics SDK version%@ and Init %d:or Error: %@", [boaObj sdkVersion], isSuccess, error);
    //        [boaObj logEvent:@"AppLaunched" withInformation:launchOptions];
    //    }];
    
}

- (IBAction)prodcutionTokenEdited:(id)sender {
    //    UITextField *currentTxtFld = (UITextField*)sender;
    //    NSString *newToken = currentTxtFld.text;
    
    //[boaObj updateAnalyticsEngineTest:self.testToken.text andProduction:newToken];
}

- (IBAction)modeChangeClicked:(id)sender {
    if ([self.modeButton.titleLabel.text isEqualToString:@"Mode: Test"]) {
        self.modeButton.titleLabel.text = @"Mode: Production";
        [self.modeButton setTitle:@"Mode: Production" forState:UIControlStateNormal];
    }else{
        [self.modeButton setTitle:@"Mode: Test" forState:UIControlStateNormal];
    }
}
@end
