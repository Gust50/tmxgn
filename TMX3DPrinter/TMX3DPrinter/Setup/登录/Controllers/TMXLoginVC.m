//
//  TMXLoginVC.m
//  TMX3DPrinter
//
//  Created by wutaobo on 16/6/8.
//  Copyright © 2016年 kobe. All rights reserved.
//

#import "TMXLoginVC.h"
#import "TMXRegisterVC.h"
#import "TMXAccountModel.h"
#import "TMXLeftVC.h"
#import "TMXBaseVC.h"
#import "KBNavigationVC.h"
#import "AppDelegate.h"
#import "TMXHomeVC.h"

@interface TMXLoginVC ()<TMXRegisterVCDelegate>

{
    TMXAccountLoginModel *tMXAccountLoginModel;
}
@property (strong, nonatomic) IBOutlet UIImageView *icon;
@property (strong, nonatomic) IBOutlet UIView *viewBack;

@property (strong, nonatomic) IBOutlet UIView *middleView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIImageView *userNameIcon;
@property (strong, nonatomic) IBOutlet UIImageView *passwordIcon;
@property (strong, nonatomic) IBOutlet UITextField *inputUserName;      ///<用户名
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UITextField *inputPassword;     ///<用户密码

@property (strong, nonatomic) IBOutlet UILabel *registerAccount;

@property (strong, nonatomic) IBOutlet UIButton *QQLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *wechatLoginButton;

@property (strong, nonatomic) IBOutlet UIButton *returnButton;  ///返回按钮
@property (strong, nonatomic) IBOutlet UIButton *forget;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineWidth;


@end

@implementation TMXLoginVC

//修改属性
- (void)modify
{
    self.QQLoginButton.titleEdgeInsets = UIEdgeInsetsMake(30*AppScale, -35*AppScale, 0, 0);
    self.QQLoginButton.imageEdgeInsets = UIEdgeInsetsMake(-50*AppScale, 20*AppScale, 0, 0);
    self.wechatLoginButton.titleEdgeInsets = UIEdgeInsetsMake(30*AppScale, -30*AppScale, 0, 0);
    self.wechatLoginButton.imageEdgeInsets = UIEdgeInsetsMake(-50*AppScale, 20*AppScale, 0, 0);
    self.icon.layer.cornerRadius = 40.0;
    self.icon.layer.masksToBounds = YES;
    self.viewBack.backgroundColor = backGroundColor;
    self.middleView.backgroundColor = [UIColor whiteColor];
    self.middleView.layer.cornerRadius = 5.0;
    self.middleView.layer.masksToBounds = YES;
    self.middleView.layer.borderWidth = 1.0;
    self.middleView.layer.borderColor = RGBColor(201, 201, 201).CGColor;
    self.bottomView.backgroundColor = backGroundColor;
    self.inputUserName.borderStyle = UITextBorderStyleNone;
    
    
    self.inputPassword.borderStyle = UITextBorderStyleNone;
    self.loginButton.layer.cornerRadius = 5.0;
    self.loginButton.layer.masksToBounds = YES;
    
    self.registerAccount.textAlignment = NSTextAlignmentCenter;
    self.registerAccount.font = [UIFont systemFontOfSize:14];
    
    self.registerAccount.textColor = RGBColor(201, 201, 201);
    self.registerAccount.textAlignment = NSTextAlignmentCenter;
    self.registerAccount.userInteractionEnabled = YES;
    UITapGestureRecognizer *registerGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addRegisterAccountGesture)];
    [self.registerAccount addGestureRecognizer:registerGesture];
    self.inputUserName.clearButtonMode =    UITextFieldViewModeWhileEditing;
    self.inputPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.inputPassword.secureTextEntry = YES;
    
    self.QQLoginButton.hidden=YES;
    self.wechatLoginButton.hidden=YES;
    self.inputUserName.placeholder = NSLocalizedString(@"UserName_input", nil);
    self.inputPassword.placeholder = NSLocalizedString(@"Password_input", nil);
    [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    self.registerAccount.text = NSLocalizedString(@"Account", nil);
    CGSize size = [NSString sizeWithStr:self.registerAccount.text font:[UIFont systemFontOfSize:14] width:SCREENWIDTH];
    self.lineWidth.constant = size.width;
    [self.forget setTitle:NSLocalizedString(@"Forget", nil) forState:UIControlStateNormal];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Login", nil)];
    self.view.backgroundColor = backGroundColor;
    [self modify];
    self.returnButton.hidden = YES;
    
    tMXAccountLoginModel=[[TMXAccountLoginModel alloc]init];
    
    NSMutableDictionary *info=[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]];
    if (info.count!=0) {
        self.inputUserName.text=info[@"username"];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.isPenson) {
        //关闭侧滑
//        [self enalbeOpenLeftDrawer:NO];
    }
    if (self.isReturn) {
        self.returnButton.hidden = YES;
    }else
    {
        self.returnButton.hidden = NO;
    }
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.isPenson) {
        //开启侧滑
//        [self enalbeOpenLeftDrawer:YES];
    }
}
//注册账号
- (void)addRegisterAccountGesture
{
    TMXRegisterVC *registerVC = [[TMXRegisterVC alloc] init];
    registerVC.delegate=self;
    registerVC.titleStr = NSLocalizedString(@"Register", nil);
    registerVC.passwordStr = NSLocalizedString(@"Password", nil);
    registerVC.isHideDescribe = NO;
    registerVC.btnStr = NSLocalizedString(@"Register", nil);
    [self presentViewController:registerVC animated:YES completion:nil];
}

//忘记密码
- (IBAction)setForgetPassword:(UIButton *)sender {
    
    TMXRegisterVC *registerVC = [[TMXRegisterVC alloc] init];
    registerVC.titleStr = NSLocalizedString(@"Reset_Password", nil);
    registerVC.passwordStr = NSLocalizedString(@"NewPassword", nil);
    registerVC.btnStr = NSLocalizedString(@"Res", nil);
    registerVC.isHideDescribe = YES;
    registerVC.isForgetPassword=YES;
    [self presentViewController:registerVC animated:YES completion:nil];

}
//登录
- (IBAction)setLoginAccount:(UIButton *)sender {
   
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    params[@"username"]=[NSString encodeString:self.inputUserName.text];
    params[@"password"]=self.inputPassword.text;
    
    if ([self ValidateIsSuccess]) {
        [tMXAccountLoginModel FetchTMXAccountLoginData:params callBack:^(BOOL isSuccess, id  _Nonnull result) {
            
            if (isSuccess)
            {
                [MBProgressHUD showSuccess:NSLocalizedString(@"Login_success", nil)];
                
                //记住登录账号和密码
                params[@"username"]=self.inputUserName.text;
                [[NSUserDefaults standardUserDefaults]setObject:params forKey:@"userInfo"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                //判断此账号是否成功登录过
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isLogined"];
                
                if (_isDismissVC) {
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    KBNavigationVC *nav=[[KBNavigationVC alloc]initWithRootViewController:[TMXHomeVC new]];
                    [ShareApp.drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
                    
                }
                
            }else
            {
                [MBProgressHUD showError:result];
            }
        }];
    }
    
}

//表单验证
- (BOOL)ValidateIsSuccess{
    
//    if (![KBRegexp validateUserName:self.inputUserName.text])
//    {
//        [MBProgressHUD showError:NSLocalizedString(@"InputRight_Username", nil)];
//        return NO;
//    }else
    if ([KBRegexp isBlankString:self.inputPassword.text])
    {
        [MBProgressHUD showError:NSLocalizedString(@"InputRight_Password", nil)];
        return NO;
    }else if (self.inputPassword.text.length<5)
    {
        [MBProgressHUD showError:NSLocalizedString(@"Password_Hight", nil)];
        return NO;
    }else
    {
        return YES;
    }
}

//QQ登录
- (IBAction)setQQLogin:(UIButton *)sender {
    
}
//微信登录
- (IBAction)setWechatLogin:(UIButton *)sender {
}

//setter getter
-(void)setIsPenson:(BOOL)isPenson
{
    _isPenson = isPenson;
}
-(void)setIsReturn:(BOOL)isReturn
{
    _isReturn = isReturn;
}

//返回
- (IBAction)setReturn:(UIButton *)sender {
    
    if (_isBackToRootTabbar) {
         [ShareApp.drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        KBNavigationVC *nav=[[KBNavigationVC alloc]initWithRootViewController:[TMXHomeVC new]];
        [ShareApp.drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
    }else if (_isDismissVC){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [ShareApp.drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
    
}

-(void)returnBackAccountInfo:(NSDictionary *)dict{
    
    self.inputUserName.text=dict[@"username"];
    self.inputPassword.text=dict[@"password"];
}


-(void)setIsBackToRootTabbar:(BOOL)isBackToRootTabbar{
    
    _isBackToRootTabbar=isBackToRootTabbar;
}

-(void)setIsDismissVC:(BOOL)isDismissVC{
    _isDismissVC=isDismissVC;
}

@end
