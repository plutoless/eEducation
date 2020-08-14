//
//  AlertViewUtil.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/20.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^KAlertHandler)(UIAlertAction * _Nullable action);
NS_ASSUME_NONNULL_BEGIN

@interface AlertViewUtil : NSObject

@property (nonatomic, copy) KAlertHandler handler;

+ (void)showAlertWithController:(UIViewController *)viewController title:(NSString *)title cancelHandler:(KAlertHandler)cancelHandler sureHandler:(KAlertHandler)sureHandler;

+ (void)showAlertWithController:(UIViewController *)viewController title:(NSString *)title sureHandler:(KAlertHandler)sureHandler;

+ (void)showAlertWithController:(UIViewController *)viewController title:(NSString *)title;

+ (void)showAlertWithController:(UIViewController *)viewController title:(NSString *)title message:(NSString * _Nullable)message cancelText:(NSString * _Nullable)cancelText sureText:(NSString * _Nullable)sureText cancelHandler:(KAlertHandler _Nullable)cancelHandler sureHandler:(KAlertHandler _Nullable)sureHandler;

@end

NS_ASSUME_NONNULL_END
