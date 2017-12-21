//
//  UIViewController+KYRouter.h
//  KYRouter
//
//  Created by Macx on 2017/12/20.
//  Copyright © 2017年 FEC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KYRouterHeader.h"
@interface UIViewController (KYRouter)

//每个VC 所属的moduleID，默认为nil
@property (nonatomic, copy) NSString *moduleID;

+(instancetype)kyRouterViewController;

/**
 根据权限等级判断是否可以打开，具体通过category重载来实现
 
 @return 是否进行正常的跳转
 */
+ (BOOL)validateTheAccessToOpen;

/**
 处理没有权限去打开的情况
 */
+ (void)handleNoAccessToOpen;


/**
 用户自定义转场动画
 
 @param naVC 根部导航栏
 */
- (void)kyRouterSpecialTransformWithNaVC:(UINavigationController *)naVC;


/**
 自定义的转场方式
 
 @return 转场方式
 */
- (RouterTransformVCStyle)kyRouterTransformStyle;
@end
