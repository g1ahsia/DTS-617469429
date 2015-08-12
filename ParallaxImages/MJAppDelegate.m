//
//  MJAppDelegate.m
//  ParallaxImages
//
//  Created by Mayur on 4/1/14.
//  Copyright (c) 2014 sky. All rights reserved.
//

#import "MJAppDelegate.h"
#import "MJRootViewController.h"

@implementation MJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    MJRootViewController *rootVC = [[MJRootViewController alloc] init];
    
    UITabBarItem *root = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"main@2x.png"] selectedImage:[UIImage imageNamed:@"main@2x.png"]];
    root.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    rootVC.tabBarItem = root;
    
    UINavigationController *rootNav = [[UINavigationController alloc] init];
    [rootNav pushViewController:rootVC animated:YES];
    rootNav.navigationBarHidden = YES;
    
    UITabBarController *myTabBarController = [[UITabBarController alloc] init];
    myTabBarController.viewControllers = [NSArray arrayWithObjects:rootNav, nil];
    
    [myTabBarController.tabBar setTintColor:[UIColor whiteColor]];
    [myTabBarController.tabBar setBarTintColor:[UIColor clearColor]];
    myTabBarController.delegate = self;
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    
    
    [self.window makeKeyAndVisible];
    [self.window setRootViewController:myTabBarController];
    
    
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
