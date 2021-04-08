//
//  BOADeviceAndAppFraudController.m
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOADeviceAndAppFraudController.h"
#import "UIKit/UIKit.h"
#import <BlotoutFoundation/BOFLogs.h>
#include <sys/utsname.h>
#include <pwd.h>
#include <mach/mach.h>
#include <sys/sysctl.h>
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#import <sys/ioctl.h>
#import <sys/param.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <TargetConditionals.h>
#import "BOANetworkConstants.h"
#if TARGET_OS_OSX
#import <CFNetwork/CFNetwork.h>
#import <CFNetwork/CFProxySupport.h>
#else
#if ! defined(D_DISK)
#define D_DISK  2
#endif
#endif

#if TARGET_IPHONE_SIMULATOR && !defined(LC_ENCRYPTION_INFO)
#define LC_ENCRYPTION_INFO 0x21
struct encryption_info_command {
  uint32_t cmd;
  uint32_t cmdsize;
  uint32_t cryptoff;
  uint32_t cryptsize;
  uint32_t cryptid;
};
#endif

#if TARGET_IPHONE_SIMULATOR && !defined(LC_ENCRYPTION_INFO_64)
#define LC_ENCRYPTION_INFO_64 0x2C
struct encryption_info_command {
  uint32_t cmd;
  uint32_t cmdsize;
  uint32_t cryptoff;
  uint32_t cryptsize;
  uint32_t cryptid;
};
#endif

static id sBOAsdkFraudCheckSharedInstance = nil;

@implementation BOADeviceAndAppFraudController

-(instancetype)init {
  self = [super init];
  return self;
}

+ (nullable instancetype)sharedInstance {
  static dispatch_once_t boaSDKFraudCheckOnceToken = 0;
  dispatch_once(&boaSDKFraudCheckOnceToken, ^{
      sBOAsdkFraudCheckSharedInstance = [[[self class] alloc] init];
  });
  return  sBOAsdkFraudCheckSharedInstance;
}

+(NSMutableDictionary*)getCurrentBinaryInfo {
  @try {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
#if TARGET_IPHONE_SIMULATOR
    [dictionary setObject:@"Simulator" forKey:@"unit_type"];
#else
    [dictionary setObject:@"Device" forKey:@"unit_type"];
#endif
    if (HardwareIs64BitArch()) {
      [dictionary setObject:@"x64" forKey:@"device_arch"];
      [dictionary setObject:[NSString stringWithFormat:@"%x",LC_ENCRYPTION_INFO_64] forKey:@"lc_info"];
    } else {
      [dictionary setObject:@"x32" forKey:@"device_arch"];
      [dictionary setObject:[NSString stringWithFormat:@"%x",LC_ENCRYPTION_INFO] forKey:@"lc_info"];
    }
    return dictionary;
  } @catch (NSException *exception) {
      BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return nil;
}

+(BOOL)isDylibInjectedToProcessWithName:(NSString*)dylib_name {
  @try {
    int max = _dyld_image_count();
    for (int i = 0; i < max; i++) {
      const char *name = _dyld_get_image_name(i);
      if (name != NULL) {
        NSString *namens = [NSString stringWithUTF8String:name];
        NSString *compare = [NSString stringWithString:dylib_name];
        if ([namens containsString:compare]) {
          return YES;
        }
      }
    }
    return NO;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return NO;
}

+(BOOL)isConnectionProxied {
  @try {
    if (![[self proxy_host] isEqualToString:@""] && ![[self proxy_port] isEqualToString:@""]) {
        return YES;
    } else {
        return NO;
    }
      
  } @catch (NSException *exception) {
      BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  
  return NO;
}

+(NSString *)proxy_host {
  @try {
    CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();
    const CFStringRef proxyCFstr = (const CFStringRef)CFDictionaryGetValue(dicRef,(const void*)kCFNetworkProxiesHTTPProxy);
    NSString *tmp = (__bridge NSString *)proxyCFstr;
    if ([tmp isEqualToString:@""] || [tmp isEqualToString:@"(null)"] || [tmp length] < 1) {
#if TARGET_OS_OSX
      const CFStringRef socksproxyCFstr = (const CFStringRef)CFDictionaryGetValue(dicRef,(const void*)kCFNetworkProxiesSOCKSProxy);
      tmp = (__bridge NSString *)socksproxyCFstr;
#endif
    }
    return  tmp;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return nil;
}

+(NSString*)proxy_port {
  @try {
    CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();
    const CFNumberRef portCFnum = (const CFNumberRef)CFDictionaryGetValue(dicRef, (const void*)kCFNetworkProxiesHTTPPort);
    SInt32 port;
    NSString *tmp = @"";
    if (portCFnum && CFNumberGetValue(portCFnum, kCFNumberSInt32Type, &port)) {
      tmp = [NSString stringWithFormat:@"%i",(int)port];
    } else {
#if TARGET_OS_OSX
      const CFNumberRef portCFnumSocks = (const CFNumberRef)CFDictionaryGetValue(dicRef, (const void*)kCFNetworkProxiesSOCKSPort);
      if (portCFnumSocks && CFNumberGetValue(portCFnumSocks, kCFNumberSInt32Type, &port)) {
        tmp = [NSString stringWithFormat:@"%i",(int)port];
      }
#endif
    }
    return tmp;
  } @catch (NSException *exception) {
      BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return nil;
}

+(BOOL)isDeviceJailbroken {
  @try {
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"]) {
      return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"]) {
      return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"]) {
      return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"]) {
      return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"]) {
      return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"]) {
      return YES;
    } else if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/AppStore.app"]) {
      //if PSProtector activated -- Tested on iOS 11.0.1
      return YES;
    } else if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/MobileSafari.app"]) {
      //if PSProtector activated -- Tested on iOS 11.0.1
      return YES;
    }
    
    __block bool isCydia;
    dispatch_sync(dispatch_get_main_queue(), ^{
      if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]) {
        isCydia = YES;
      }
    });
    
    if (isCydia) {
      return YES;
    }
    
    FILE *f = fopen("/bin/bash", "r");
    if (f != NULL) {
      fclose(f);
      return YES;
    }
    fclose(f);
    f = fopen("/Applications/Cydia.app", "r");
    if (f != NULL) {
      fclose(f);
      return YES;
    }
    fclose(f);
    f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r");
    if (f != NULL) {
      fclose(f);
      return YES;
    }
    fclose(f);
    f = fopen("/usr/sbin/sshd", "r");
    if (f != NULL) {
      fclose(f);
      return YES;
    }
    fclose(f);
    f = fopen("/etc/apt", "r");
    if (f != NULL) {
      fclose(f);
      return YES;
    }
    fclose(f);
    NSError *error;
    NSString *stringToBeWritten = @"if this string is saved, then device is jailbroken";
    [stringToBeWritten writeToFile:@"/private/test" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:@"/private/test" error:nil];
    if (error == nil) {
      return YES;
    }
  } @catch (NSException *exception) {
      BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return NO;
}

+(BOOL)ttyWayIsDebuggerConnected {
  @try {
    int fd = STDERR_FILENO;
    if (fcntl(fd, F_GETFD, 0) < 0) {
      return NO;
    }
    
    char buf[MAXPATHLEN + 1];
    if (fcntl(fd, F_GETPATH, buf ) >= 0) {
      if (strcmp(buf, "/dev/null") == 0) {
        return NO;
      }
      
      if (strncmp(buf, "/dev/tty", 8) == 0) {
        return YES;
      }
    }
    
    int type;
    if (ioctl(fd, FIODTYPE, &type) < 0) {
      return NO;
    }
    return type != D_DISK;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return NO;
}

+(BOOL)isDebuggerConnected {
  @try {
    int mib[4];
    struct kinfo_proc info;
    info.kp_proc.p_flag = 0;
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    size_t size = sizeof(info);
    int junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return NO;
}

int main (int argc, char *argv[]);

static BOOL HardwareIs64BitArch() {
  @try {
#if __LP64__
    return YES;
#endif
    static BOOL sHardwareChecked = NO;
    static BOOL sIs64bitHardware = NO;
    if (sHardwareChecked) {
      return sIs64bitHardware;
    }
    
    sHardwareChecked = YES;
#if TARGET_IPHONE_SIMULATOR
    sIs64bitHardware = DeviceIs64BitSimulator();
#else
    struct host_basic_info host_basic_info;
    unsigned int count;
    kern_return_t returnValue = host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)(&host_basic_info), &count);
    if (returnValue != KERN_SUCCESS) {
      sIs64bitHardware = NO;
    }
    sIs64bitHardware = (host_basic_info.cpu_type == CPU_TYPE_ARM64);
#endif
    return sIs64bitHardware;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return NO;
}

bool DeviceIs64BitSimulator() {
  @try {
    bool is64bitSimulator = false;
    int mib[6] = {0,0,0,0,0,0};
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_ALL;
    long numberOfRunningProcesses = 0;
    struct kinfo_proc* BSDProcessInformationStructure = NULL;
    size_t sizeOfBufferRequired = 0;
    BOOL successfullyGotProcessInformation = NO;
    int error = 0;
    while (successfullyGotProcessInformation == NO) {
      error = sysctl(mib, 3, NULL, &sizeOfBufferRequired, NULL, 0);
      if (error) {
        return NULL;
      }
      BSDProcessInformationStructure = (struct kinfo_proc*) malloc(sizeOfBufferRequired);
      if (BSDProcessInformationStructure == NULL) {
        return NULL;
      }
      error = sysctl(mib, 3, BSDProcessInformationStructure, &sizeOfBufferRequired, NULL, 0);
      if (error == 0) {
        successfullyGotProcessInformation = YES;
      } else {
        free(BSDProcessInformationStructure);
      }
    }
    numberOfRunningProcesses = sizeOfBufferRequired / sizeof(struct kinfo_proc);
    for (int i = 0; i < numberOfRunningProcesses; i++) {
      const char *name = BSDProcessInformationStructure[i].kp_proc.p_comm;
      if (strcmp(name, "SimulatorBridge") == 0) {
        int p_flag = BSDProcessInformationStructure[i].kp_proc.p_flag;
        is64bitSimulator = (p_flag & P_LP64) == P_LP64;
        break;
      }
    }
    free(BSDProcessInformationStructure);
    return is64bitSimulator;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
  }
  return NO;
}

@end
