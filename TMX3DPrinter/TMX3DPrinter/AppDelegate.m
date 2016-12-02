//
//  AppDelegate.m
//  TMX3DPrinter
//
//  Created by kobe on 16/8/25.
//  Copyright © 2016年 kobe. All rights reserved.
//

#import "AppDelegate.h"
#import "TMXLeftVC.h"
#import "TMXHomeVC.h"
#import "TMXAccountModel.h"
#import "IQKeyboardManager.h"
#import "KBGuideViewController.h"

@interface AppDelegate ()
{
    TMXAccountLoginModel *loginModel;
    NSUserDefaults *userDefaults;
    
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [NSBundle setLanguage:@"zh-Hans"];
    [[NSUserDefaults standardUserDefaults] setObject:@[@"zh-Hans"] forKey:@"AppleLanguages"];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [[IQKeyboardManager sharedManager] setEnable:YES];
//    [[IQKeyboardManager sharedManager]setEnableAutoToolbar:NO];
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    if (![userDefaults boolForKey:@"NotFirstLoad"]) {
        [userDefaults setBool:YES forKey:@"NotFirstLoad"];
        KBGuideViewController *kbGuideVC=[KBGuideViewController new];
        kbGuideVC.guideImgArr=@[@"第1页",@"第2页",@"第3页",@"第4页"];
        self.window.rootViewController=kbGuideVC;
        [self.window makeKeyAndVisible];
        
        kbGuideVC.startBtnBlock=^(){
            [self initRootViewController];
        };
#warning appstore crash
        kbGuideVC.skipBtnBlock=^(){
            [self initRootViewController];

        };
    }else{
        [self initRootViewController];
    }
    [self initData];
    [self getPublicKey];
    
    return YES;
}

-(void)initRootViewController{
    
    [self.drawerController setShowsShadow:YES];
    KBNavigationVC *leftNavVC=[[KBNavigationVC alloc]initWithRootViewController:[TMXLeftVC new]];
    KBNavigationVC *centerNavVC=[[KBNavigationVC alloc]initWithRootViewController:[TMXHomeVC new]];
    self.drawerController=[[MMDrawerController alloc]initWithCenterViewController:centerNavVC leftDrawerViewController:leftNavVC];
    [self.drawerController setMaximumLeftDrawerWidth:SCREENWIDTH*2/3 animated:YES completion:^(BOOL finished) {
        
    }];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    self.window.rootViewController=self.drawerController;
    [self.window makeKeyAndVisible];
}

-(void)setRootVC{
    KBNavigationVC *nav=[[KBNavigationVC alloc]initWithRootViewController:[TMXHomeVC new]];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [ShareApp.drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];

}

-(void)initData{
    loginModel=[TMXAccountLoginModel new];
}

//获取App公钥
-(void)getPublicKey{
    __weak AppDelegate *weakSelf = self;
    
    [[FetchAppPublicKeyModel shareAppPublicKeyManager]fetchAppPublicKey:nil callBack:^(BOOL isSuccess, id result) {
        
        if (isSuccess) {
            [FetchAppPublicKeyModel shareAppPublicKeyManager].publicKey=result;
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogined"]){
                
                NSMutableDictionary *params=[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"]];
                
                if ([params[@"username"] length] != 0 && [params[@"password"] length] != 0) {
                    
                    [loginModel FetchTMXAccountLoginData:params callBack:^(BOOL isSuccess, id  _Nonnull result) {
                        
                    }];
                }else{
                     [[NSNotificationCenter defaultCenter]postNotificationName:@"LoginSuccess" object:nil userInfo:@{@"isSuccess":@(NO)}];
                }
            }
        }else{
            [weakSelf getPublicKey];
        }
    }];
}


-(void)againLogin{
    
    [MBProgressHUD showSuccess:@"你的账号已在另外一台设备登录"];
     [[KBGCDTimerManager shareInstance]cancelAllTimerTask];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"LoginSuccess" object:nil userInfo:@{@"isSuccess":@(NO)}];
    KBNavigationVC *nav=[[KBNavigationVC alloc]initWithRootViewController:[TMXHomeVC new]];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [ShareApp.drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
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
