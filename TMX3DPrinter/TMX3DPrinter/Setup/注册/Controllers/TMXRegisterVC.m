//
//  TMXRegisterVC.m
//  TMX3DPrinter
//
//  Created by wutaobo on 16/6/8.
//  Copyright © 2016年 kobe. All rights reserved.
//

#import "TMXRegisterVC.h"
#import "KBTimer.h"
#import "TMXAccountRegisterModel.h"

@interface TMXRegisterVC ()<UITextFieldDelegate>

{
    TMXAccountRegisterModel *tMXAccountRegisterModel;
    TMXSendEmailTokenModel *sendEmailTokenModel;
    BOOL isSelectProtrol;       ///<判断是否选择协议
    NSString *code;             ///<判断是哪种语言
}

@property (strong, nonatomic) IBOutlet UIView *middleView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet UITextField *inputUserName;           ///<用户名
@property (strong, nonatomic) IBOutlet UITextField *inputPassword;           ///<用户密码
@property (strong, nonatomic) IBOutlet UITextField *inputRepeatPassword;     ///<重复密码
@property (strong, nonatomic) IBOutlet UITextField *InputPhoneNumber;        ///<手机号码

@property (strong, nonatomic) IBOutlet UITextField *inputCode;

@property (strong, nonatomic) IBOutlet UIButton *selectButton;
@property (strong, nonatomic) IBOutlet UILabel *describe;

@property (strong, nonatomic) IBOutlet UIButton *registerBtn;
@property (strong, nonatomic) IBOutlet UILabel *password;

@property (weak, nonatomic) IBOutlet UILabel *validateCode;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *rePasswordLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *check;


@property (weak, nonatomic) IBOutlet UILabel *navTitle;

@end

@implementation TMXRegisterVC
//修改属性
- (void)modify
{
    self.inputPassword.secureTextEntry = YES;
    self.inputRepeatPassword.secureTextEntry = YES;
    self.inputUserName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.inputPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.inputRepeatPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.inputUserName.borderStyle = UITextBorderStyleNone;
    self.inputPassword.borderStyle = UITextBorderStyleNone;
    self.inputRepeatPassword.borderStyle = UITextBorderStyleNone;
    self.InputPhoneNumber.borderStyle = UITextBorderStyleNone;
    self.InputPhoneNumber.delegate=self;
    
   
    self.registerBtn.layer.cornerRadius = 5.0;
    self.registerBtn.layer.masksToBounds = YES;
    self.middleView.backgroundColor = [UIColor whiteColor];
    self.middleView.layer.borderWidth = 1.0;
    self.middleView.layer.borderColor = RGBColor(192, 192, 192).CGColor;
    self.middleView.layer.cornerRadius = 10.0;
    self.middleView.layer.masksToBounds = YES;
    self.bottomView.backgroundColor = backGroundColor;
    
    self.validateCode.backgroundColor=[UIColor grayColor];
    self.validateCode.userInteractionEnabled=NO;
    self.validateCode.textColor=[UIColor whiteColor];
    self.validateCode.userInteractionEnabled=YES;
    self.validateCode.layer.cornerRadius=5.0;
    self.validateCode.layer.masksToBounds=YES;
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(checkPhoneNum)];
    [self.validateCode addGestureRecognizer:tap];
    
    self.selectButton.hidden = _isHideDescribe;
    self.describe.hidden = _isHideDescribe;
    self.password.text = self.passwordStr;
    [self.registerBtn setTitle:self.btnStr forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"protrolSelect_normal"] forState:UIControlStateNormal];
    
    if (_isForgetPassword) {
        
        self.navTitle.text=NSLocalizedString(@"Reset_Password", nil);
    }else
    {
        self.navTitle.text=NSLocalizedString(@"Register", nil);
    }
    self.validateCode.userInteractionEnabled=NO;
    
    self.usernameLabel.text = NSLocalizedString(@"UserName", nil);
    self.password.text = NSLocalizedString(@"Password", nil);
    self.rePasswordLabel.text = NSLocalizedString(@"Repassword", nil);
    self.validateCode.text = NSLocalizedString(@"Get_code", nil);
    self.check.text = NSLocalizedString(@"Code", nil);
    self.describe.text = NSLocalizedString(@"Protocol", nil);
    self.phoneLabel.text = NSLocalizedString(@"Phone", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self modify];

    self.view.backgroundColor = backGroundColor;
    tMXAccountRegisterModel=[[TMXAccountRegisterModel alloc]init];
    sendEmailTokenModel = [TMXSendEmailTokenModel new];
    isSelectProtrol = NO;
    code=[[NSUserDefaults standardUserDefaults]objectForKey:@"AppleLanguages"][0];
}

//验证手机号
- (void)checkPhoneNum
{
    if ([KBRegexp checkPhoneNumInput:self.InputPhoneNumber.text])
    {
        
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        params[@"mobile"]=self.InputPhoneNumber.text;
        [tMXAccountRegisterModel FetchTMXAccountCheckPhoneNumData:params callBack:^(BOOL isSuccess, id result) {
            if (isSuccess) {
                tMXAccountRegisterModel = result;
                
                if (_isForgetPassword) {
                    if (!tMXAccountRegisterModel.result) {
                        [self tap];
                    }else{
                        [MBProgressHUD showError:NSLocalizedString(@"Mailbox_notregistered", nil)];
                    }
                }else
                {
                    if (tMXAccountRegisterModel.result) {
                        [self tap];
                    }else{
                        [MBProgressHUD showError:NSLocalizedString(@"Mailbox_registered", nil)];
                    }
                }
                
            }else
            {
                
                [MBProgressHUD showError:result];
            }
            
        }];
    }else
    {
        [MBProgressHUD showError:NSLocalizedString(@"Phone_Error", nil)];
        self.validateCode.backgroundColor=[UIColor grayColor];
    }
}

/**
 *  获取验证码
 */
-(void)tap{
    
    if (_isForgetPassword)
    {
        
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        params[@"mobile"]=self.InputPhoneNumber.text;
        params[@"type"]=@(2);
        [tMXAccountRegisterModel PostTMXAccountPhoneNumData:params callBack:^(BOOL isSuccess, id result) {
            if (isSuccess) {
                [MBProgressHUD showSuccess:NSLocalizedString(@"Code_Sending", nil)];
                KBTimer *tiemr=[[KBTimer alloc]init];
                [tiemr countDown:self.validateCode];
            }else
            {
                [MBProgressHUD showSuccess:result];
            }
        }];
    }else
    {
        
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        params[@"mobile"]=self.InputPhoneNumber.text;
        params[@"type"]=@(1);
        [tMXAccountRegisterModel PostTMXAccountPhoneNumData:params callBack:^(BOOL isSuccess, id result) {
            if (isSuccess) {
                [MBProgressHUD showSuccess:NSLocalizedString(@"Code_Sending", nil)];
                KBTimer *tiemr=[[KBTimer alloc]init];
                [tiemr countDown:self.validateCode];
            }else
            {
                [MBProgressHUD showSuccess:result];
            }
        }];
    }
}

//注册
- (IBAction)setRegister:(UIButton *)sender {
    
    if ([self ValidateIsSuccess]) {
        
        NSMutableDictionary * needsparams = [NSMutableDictionary dictionary];
        needsparams[@"username"] = self.inputUserName.text;
        needsparams[@"enPassword"] = [KBRSA encryptString:self.inputPassword.text publicKey:[FetchAppPublicKeyModel shareAppPublicKeyManager].publicKey];
        needsparams[@"mobile"] = self.InputPhoneNumber.text;
        needsparams[@"smsToken"] = self.inputCode.text;
        
        if (_isForgetPassword)
        {
            
            [tMXAccountRegisterModel FetchTMXAccountResetPhoneNumData:needsparams callBack:^(BOOL isSuccess, id result) {
                
                if (isSuccess)
                {
                    
                    [MBProgressHUD showSuccess:NSLocalizedString(@"ResetPassword_Suc", nil)];
                    NSMutableDictionary *info=[NSMutableDictionary dictionary];
                    info[@"username"]=self.inputUserName.text;
                    info[@"password"]=nil;
                    if (self.delegate && [self.delegate respondsToSelector:@selector(returnBackAccountInfo:)])
                    {
                        [self.delegate returnBackAccountInfo:info];
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                }else
                {
                    [MBProgressHUD showError:result];
                }
            }];
            
        }else
        {
            if (isSelectProtrol) {
                [tMXAccountRegisterModel FetchTMXAccountRegisterData:needsparams callBack:^(BOOL isSuccess, id result) {
                    if (isSuccess)
                    {
                        [MBProgressHUD showSuccess:NSLocalizedString(@"Register_Suc", nil)];
                        NSMutableDictionary *info=[NSMutableDictionary dictionary];
                        info[@"username"]=self.inputUserName.text;
                        info[@"password"]=self.inputPassword.text;
                        if (self.delegate && [self.delegate respondsToSelector:@selector(returnBackAccountInfo:)])
                        {
                            [self.delegate returnBackAccountInfo:info];
                        }
                        [self dismissViewControllerAnimated:YES completion:nil];
                        
                    }else
                    {
                        
                        [MBProgressHUD showError:result];
                    }
                }];
            }else
            {
                [MBProgressHUD showError:NSLocalizedString(@"Accept_Protol", nil)];
                return;
            }
            
        }
    }
    
}
//是否接受协议
- (IBAction)setSelect:(UIButton *)sender {

    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.selectButton setImage:[UIImage imageNamed:@"protrolSelect_select"] forState:UIControlStateNormal];
        isSelectProtrol = YES;
    }else
    {
        [self.selectButton setImage:[UIImage imageNamed:@"protrolSelect_normal"] forState:UIControlStateNormal];
        isSelectProtrol = NO;
    }
}
//返回按钮
- (IBAction)setReturn:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


//setter getter
- (void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr;
}

-(void)setIsHideDescribe:(BOOL)isHideDescribe
{
    _isHideDescribe = isHideDescribe;
}

-(void)setBtnStr:(NSString *)btnStr
{
    _btnStr = btnStr;
}

-(void)setPasswordStr:(NSString *)passwordStr
{
    _passwordStr = passwordStr;
}

-(void)setIsForgetPassword:(BOOL)isForgetPassword{
    _isForgetPassword=isForgetPassword;
}

//表单验证
- (BOOL)ValidateIsSuccess{
    
    if (_isForgetPassword) {
        
    }else{
        
        if (![KBRegexp validateUserName:self.inputUserName.text])
        {
            [MBProgressHUD showError:NSLocalizedString(@"InputRight_Username", nil)];
            return NO;
        }
    }
    
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
    }else if (![self.inputPassword.text isEqualToString:self.inputRepeatPassword.text])
    {
        [MBProgressHUD showError:NSLocalizedString(@"Password_Different", nil)];
        return NO;
    }else if (self.inputCode.text.length==0)
    {
        [MBProgressHUD showError:NSLocalizedString(@"InputRight_Code", nil)];
        return NO;
    }else
    {
        return YES;
    }
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (self.InputPhoneNumber==textField)
    {
        NSString *str=[textField.text stringByReplacingCharactersInRange:range withString:string];
        if (str.length==11) {
            if ([KBRegexp checkPhoneNumInput:str])
            {
                self.validateCode.backgroundColor=RGBColor(232, 97, 1);
                self.validateCode.userInteractionEnabled=YES;
            }else
            {
                self.validateCode.backgroundColor=[UIColor grayColor];
                self.validateCode.userInteractionEnabled=NO;
            }
            
        }else{
            self.validateCode.backgroundColor=[UIColor grayColor];
            self.validateCode.userInteractionEnabled=NO;
        }
    }
    return YES;
}
@end
