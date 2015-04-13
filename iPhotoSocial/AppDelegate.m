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
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    PS_DiscoverViewController *findVC = [[PS_DiscoverViewController alloc] init];
    PS_HotViewController *hotVC = [[PS_HotViewController alloc] init];
    PS_NotificationViewController *notificationVC = [[PS_NotificationViewController alloc] init];
    PS_AchievementViewController *achievementVC = [[PS_AchievementViewController alloc] init];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsLogin] == YES) {
        achievementVC.uid = [[NSUserDefaults standardUserDefaults] objectForKey:kUid];
        achievementVC.userImage = [[NSUserDefaults standardUserDefaults] objectForKey:kPic];
        achievementVC.userName = [[NSUserDefaults standardUserDefaults] objectForKey:kUsername];
    }
    PS_BaseNavigationController *findNC = [[PS_BaseNavigationController alloc] initWithRootViewController:findVC];
    PS_BaseNavigationController *hotNC = [[PS_BaseNavigationController alloc] initWithRootViewController:hotVC];
    PS_BaseNavigationController *notificationNC = [[PS_BaseNavigationController alloc] initWithRootViewController:notificationVC];
    PS_BaseNavigationController *achievementNC = [[PS_BaseNavigationController alloc] initWithRootViewController:achievementVC];

    PS_TabBarViewController *tabBarVC = [[PS_TabBarViewController alloc] init];
    tabBarVC.viewControllers = @[findNC,hotNC,notificationNC,achievementNC];
    
//    ViewController *vc = [[ViewController alloc] init];
//    self.window.rootViewController = vc;
    self.window.rootViewController = tabBarVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
