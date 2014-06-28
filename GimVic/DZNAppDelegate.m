//
//  DZNAppDelegate.m
//  GimVic
//
//  Created by Vid Drobnič on 18/05/14.
//  Copyright (c) 2014 Vid Drobnic. All rights reserved.
//

#import "DZNAppDelegate.h"
#import "DZNPageViewController.h"
#import "Reachability.h"
#import "DZNRefresh.h"

@implementation DZNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    DZNPageViewController *rootViewController = [[DZNPageViewController alloc] init];
    
    self.window.rootViewController = rootViewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DZNRefresh *refresh = [[DZNRefresh alloc] init];
    
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        
    }
    else if (status == ReachableViaWiFi) {
        [NSThread detachNewThreadSelector:@selector(downloadNewContent) toTarget:refresh withObject:nil];
    }
    else if (status == ReachableViaWWAN) {
        [NSThread detachNewThreadSelector:@selector(downloadNewContent) toTarget:refresh withObject:nil];
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString *filter = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/filter", documentsPath] encoding:NSUTF8StringEncoding error:nil];
    if (filter == nil) {
        filter = @"";
        [filter writeToFile:[NSString stringWithFormat:@"%@/filter", documentsPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSMutableArray *files = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL]];
    [files removeObjectAtIndex:0];
    
    for (int i = 0; i < [files count]; i++) {
        NSRange range = [files[i] rangeOfString:@"-"];
        NSMutableString *fileDateString = [NSMutableString stringWithString:[files[i] substringFromIndex:range.location + 1]];
        
        NSDateFormatter *dFormatter = [[NSDateFormatter alloc] init];
        dFormatter.dateFormat = @"yyyy-MM-dd";
        
        NSDate *fileDate = [dFormatter dateFromString:fileDateString];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [calendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
        
        NSDate *currentDate = [calendar dateFromComponents:comps];
        
        if ([fileDate compare:currentDate] == NSOrderedAscending) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsPath, files[i]] error:NULL];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
