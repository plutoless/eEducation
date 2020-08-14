//
//  AlertViewUtil.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/20.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "AlertViewUtil.h"

@implementation AlertViewUtil
+ (void)showAlertWithController:(UIViewController *)viewController title:(NSString *)title cancelHandler:(KAlertHandler)cancelHandler sureHandler:(KAlertHandler)sureHandler {
    
    [AlertViewUtil showAlertWithController:viewController title:title message:nil cancelText:NSLocalizedString(@"CancelText", nil) sureText:NSLocalizedString(@"OKText", nil) cancelHandler:cancelHandler sureHandler:sureHandler];
}

+ (void)showAlertWithController:(UIViewController *)viewController title:(NSString *)title sureHandler:(KAlertHandler)sureHandler {
    
    [AlertViewUtil showAlertWithController:viewController title:title message:nil cancelText:NSLocalizedString(@"CancelText", nil) sureText:NSLocalizedString(@"OKText", nil) cancelHandler:nil sureHandler:sureHandler];
}

+ (void)showAlertWithController:(UIViewController *)viewController title:(NSString *)title {
    
    [AlertViewUtil showAlertWithController:viewController title:title message:nil cancelText:NSLocalizedString(@"CancelText", nil) sureText:nil cancelHandler:nil sureHandler:nil];
}

+ (void)showAlertWithController:(UIViewController *)viewController title:(NSString *)title message:(NSString * _Nullable)message cancelText:(NSString * _Nullable)cancelText sureText:(NSString * _Nullable)sureText cancelHandler:(KAlertHandler _Nullable)cancelHandler sureHandler:(KAlertHandler _Nullable)sureHandler {
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (sureText != nil && sureText.length > 0) {
        UIAlertAction *actionDone = [UIAlertAction actionWithTitle:sureText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            !sureHandler ? : sureHandler(action);
        }];
        [alertVc addAction:actionDone];
    }
    
    if (cancelText != nil && cancelText.length > 0) {
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            !cancelHandler ? : cancelHandler(action);
        }];
        [alertVc addAction:actionCancel];
    }
    
    [viewController presentViewController:alertVc animated:YES completion:nil];
}

@end
