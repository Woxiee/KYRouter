//
//  KYRouter.h
//  KYRouter
//
//  Created by Macx on 2017/12/19.
//  Copyright © 2017年 FEC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KYRouterHeader.h"

//******************************************************************************
//*
//*           RouterOptions类
//*           配置跳转时的各种设置
//******************************************************************************

@interface RouterOptions : NSObject
//转场方式
@property (nonatomic, readwrite) RouterTransformVCStyle transFormVCStyle;

//跳转时是否有动画
@property (nonatomic, readwrite) BOOL animated;

//每个页面所对应的moduleID
@property (nonatomic,copy) NSString *moduleID;

// 跳转时传入参数，默认为nil
@property (nonatomic, copy, readwrite) NSDictionary *defaultParams;

/**
 创建默认配置的options对象
 
 @return RouterOptions 实例对象
 */
+(instancetype)options;

/**
 创建options对象，并配置moduleID
 
 @param moduleID 模块的ID
 @return RouterOptions 实例对象
 */
+ (instancetype)optionsWithModuleID:(NSString *)moduleID;

/**
 创建单独配置的options对象,其余的是默认配置
 
 @param params 跳转时传入的参数
 @return RouterOptions 实例对象
 */
+ (instancetype)optionsWithDefaultParams:(NSDictionary *)params;

/**
 已经创建的option对象传入参数
 
 @param params 跳转时传入的参数
 @return RouterOptions 实例对象
 */
- (instancetype)optionsWithDefaultParams:(NSDictionary *)params;

@end

//***********************************************************************************
//*
//*           KYRouter类
//*
//***********************************************************************************
@interface KYRouter : NSObject
@property (nonatomic, copy, readonly) NSSet <NSDictionary *>* modules;     ///< 存储路由，moduleID信息，权限配置信息

/**
 初始化单例
 
 @return KYRouter 的单例对象
 */
+ (instancetype)router;

/**
 配置router信息
 @param routerFileNames  router的配置信息
 */
+ (void)configWithRouterFiles:(NSArray<NSString *> *)routerFileNames;

/**
 默认打开方式
 一般由native调用
 @param vcClassName 跳转的控制器类名
 */
+ (void)open:(NSString *)vcClassName;


/**
 根据options的设置进行跳转
 
 @param vcClassName 跳转的控制器类名
 @param options 跳转的各种设置
 */
+ (void)open:(NSString *)vcClassName options:(RouterOptions *)options;

/**
 根据options和已有的vc进行跳转
 
 @param vc 已经创建的指定的vc
 @param options 跳转的各种设置
 */
+ (void)openSpecifiedVC:(UIViewController *)vc options:(RouterOptions *)options;


/**
 根据options的设置进行跳转,并执行相关的回调操作
 
 @param vcClassName 跳转的控制器类名
 @param options 跳转的各种设置
 @param callback 回调
 */
+ (void)open:(NSString *)vcClassName options:(RouterOptions *)options CallBack:(void(^)(void))callback;


/**
 遵守用户指定协议的跳转
 在外部浏览器唤醒app，H5调用相关模块时使用
 适用于携带少量参数，不带参数的跳转
 @param url 跳转的路由 携带参数
 */
+ (void)URLOpen:(NSString *)url;


/**
 遵守用户指定协议的跳转
 
 适用于携带大量参数的跳转,多用于H5页面跳转到native页面
 @param url 跳转的路由，不携带参数
 @param params 传入的参数
 */
+ (void)URLOpen:(NSString *)url params:(NSDictionary *)params;


/**
 适用于访问基于http协议／https协议的路由跳转
 
 @param url 跳转的路由，可以携带少量参数
 */
+ (void)httpOpen:(NSURL *)url;


/**
 默认情况下的pop，或者dismiss ,animated:YES
 */
+ (void)pop;


/**
 默认情况下的pop，或者dismiss，animated:YES
 
 @param animated 是否有动画
 */
+ (void)pop:(BOOL)animated;


/**
 默认情况下的pop，或者dismiss animated
 
 @param params 返回时携带的参数
 @param animated 是否有动画
 */
+ (void)pop:(NSDictionary *)params :(BOOL)animated;


/**
 pop到指定的页面
 默认animated为YES，如果需要 dismiss，也会执行
 @param vc 指定的vc对象
 */
+ (void)popToSpecifiedVC:(UIViewController *)vc;



/**
 pop到指定的页面
 如果需要 dismiss，也会执行
 @param vc 指定的vc对象
 @param animated 是否有动画
 */
+ (void)popToSpecifiedVC:(UIViewController *)vc animated:(BOOL)animated;

/**
 根据moduleID pop回指定的模块
 
 @param moduleID 指定要返回的moduleID
 */
+ (void)popWithSpecifiedModuleID:(NSString *)moduleID;


/**
 根据moduleID pop回指定的模块
 并指定动画模式
 @param moduleID 指定要返回的moduleID
 @param params 返回时携带的参数
 @param animated 是否有动画
 */
+ (void)popWithSpecifiedModuleID:(NSString *)moduleID :(NSDictionary *)params :(BOOL)animated;

/**
 通过浏览器跳转到相关的url或者唤醒相关的app
 
 @param targetURL 路由信息
 */
+ (void)openExternal:(NSURL *)targetURL;

@end
