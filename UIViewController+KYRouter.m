//
//  UIViewController+KYRouter.m
//  KYRouter
//
//  Created by Macx on 2017/12/20.
//  Copyright © 2017年 FEC. All rights reserved.
//

#import "UIViewController+KYRouter.h"
#import <objc/runtime.h>


@implementation UIViewController (KYRouter)

static char moduleID;

- (NSString *)moduleID
{
    return objc_getAssociatedObject(self,&moduleID);
}

- (void)setModuleID:(NSString *)moduleID
{
    objc_setAssociatedObject(self, &moduleID, moduleID, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

+(instancetype)kyRouterViewController
{
    return [[[self class] alloc] init];

}

/**
 根据权限等级判断是否可以打开，具体通过category重载来实现
 
 @return 是否进行正常的跳转
 */
+ (BOOL)validateTheAccessToOpen
{
    return YES;
}

/**
 处理没有权限去打开的情况
 */
+ (void)handleNoAccessToOpen
{
    
}

/**
 用户自定义转场动画
 
 @param naVC 根部导航栏
 */
- (void)kyRouterSpecialTransformWithNaVC:(UINavigationController *)naVC
{
    
}


/**
 自定义的转场方式
 
 @return 转场方式
 */
- (RouterTransformVCStyle)kyRouterTransformStyle
{
    return RouterTransformVCStylePush;

}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}


@end
