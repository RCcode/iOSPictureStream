//
//  AppDelegate.m
//  iPhotoSocial
//
//  Created by MAXToooNG on 15/3/24.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "AppDelegate.h"
#import "PS_TabBarViewController.h"
#import "PS_DiscoverViewController.h"
#import "PS_HotViewController.h"
#import "PS_NotificationViewController.h"
#import "PS_AchievementViewController.h"
#import "PS_BaseNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    PS_DiscoverViewController *findVC = [[PS_DiscoverViewController alloc] init];
    PS_HotViewController *hotVC = [[PS_HotViewController alloc] init];
    PS_NotificationViewController *notificationVC = [[PS_NotificationViewController alloc] init];
    PS_AchievementViewController *achievementVC = [[PS_AchievementViewController alloc] init];

    PS_TabBarViewController *tabBarVC = [[PS_TabBarViewController alloc] init];
    tabBarVC.viewControllers = @[findVC,hotVC,notificationVC,achievementVC];
    
    PS_BaseNavigationController *naVC = [[PS_BaseNavigationController alloc] initWithRootViewController:tabBarVC];
    self.window.rootViewController = naVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
