//
//  KYRouter.m
//  KYRouter
//
//  Created by Macx on 2017/12/19.
//  Copyright © 2017年 FEC. All rights reserved.
//

#import "KYRouter.h"

#ifdef DEBUG
#define KYRouterLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define KYRouterLog(...)
#endif
//******************************************************************************
//*
//*           RouterOptions类
//*           配置跳转时的各种设置
//******************************************************************************

@implementation RouterOptions
+(instancetype)options
{
    RouterOptions *options = [RouterOptions new];
    options.transFormVCStyle = RouterTransformVCStyleDefault;
    options.animated = YES;
    return options;
}

+(instancetype)optionsWithModuleID:(NSString *)moduleID
{
    RouterOptions *options = [RouterOptions options];
    options.moduleID  =  moduleID;
    return options;
}


+ (instancetype)optionsWithDefaultParams:(NSDictionary *)params{
    
    RouterOptions *options = [RouterOptions options];
    options.defaultParams = params;
    return options;
}


- (instancetype)optionsWithDefaultParams:(NSDictionary *)params{
    
    self.defaultParams = params;
    return self;
}



@end

//**********************************************************************************
//*
//*           KYRouter类
//*
//**********************************************************************************



@interface KYRouter()
@property (nonatomic, copy, readwrite) NSSet * modules;     ///< 存储路由，moduleID信息，权限配置信息
@property (nonatomic,copy) NSArray<NSString *> *routerFileNames; // 路由配置信息的json文件名数组
@property (nonatomic,strong) NSSet *urlSchemes;//支持的URL协议集合
@property (nonatomic,strong) NSString *webContainerName;//自定义的URL协议名字
@property (nonatomic,weak) UINavigationController *navigationController; ///< app的导航控制器

@end


@implementation KYRouter

//重写该方法，防止外部修改该类的对象
+ (BOOL)accessInstanceVariablesDirectly{
    
    return NO;
}


/**
 初始化单例
 
 @return KYRouter 的单例对象
 */
+ (instancetype)router{
    static KYRouter *defaultRouter =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRouter = [KYRouter new];
    });
    return defaultRouter;
}

- (UINavigationController *)navigationController{
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [rootVC isKindOfClass:[UINavigationController class]]?(UINavigationController *)rootVC:nil;
}


+ (void)configWithRouterFiles:(NSArray<NSString *> *)routerFileNames{
    [KYRouter router].routerFileNames = routerFileNames;
    [KYRouter router].urlSchemes  =  [NSSet setWithArray:[KYRouterExtension urlSchemes]];
    [KYRouter router].webContainerName = [KYRouterExtension kyWebVCClassName];
}

- (NSSet<NSDictionary *> *)modules
{
    if (!_modules) {
        NSArray *moudulesArr = [KYJSONHanler getModulesFromJsonFile:[KYRouter router].routerFileNames];
        _modules = [NSSet setWithArray:moudulesArr];
    }
    return _modules;
}

# pragma mark the open functions - - - - - - - - -
+ (void)open:(NSString *)vcClassName{
    RouterOptions *options = [RouterOptions options];
    [self open:vcClassName options:options];
}

+ (void)open:(NSString *)vcClassName options:(RouterOptions *)options{
    
    [self open:vcClassName options:options CallBack:nil];
}

+ (void)openSpecifiedVC:(UIViewController *)vc options:(RouterOptions *)options{
    if (!options) {
        options = [RouterOptions options];
    }
    [self routerViewController:vc options:options];
}


+ (void)open:(NSString *)vcClassName options:(RouterOptions *)options CallBack:(void(^)(void))callback{
    
    if (!JKSafeStr(vcClassName)) {
        NSAssert(NO, @"vcClassName is nil or vcClassName is not a string");
        return;
    }
    if (!options) {
        options = [RouterOptions options];
    }
    UIViewController *vc = [self configVC:vcClassName options:options];
    //根据配置好的VC，options配置进行跳转
    if (![self routerViewController:vc options:options]) {//跳转失败
        return;
    }
    if (callback) {
        callback();
    }
    
}

+ (void)URLOpen:(NSString *)url{
    
    [self URLOpen:url params:nil];
}

+ (void)URLOpen:(NSString *)url params:(NSDictionary *)params{
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *targetURL = [NSURL URLWithString:url];
    NSString *scheme =targetURL.scheme;
    if (![[KYRouter router].urlSchemes containsObject:scheme]) {
        return;
    }
    if (![KYRouterExtension safeValidateURL:url]) {
        return;
    }

    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        
        [self httpOpen:targetURL];
        return;
    }
    
    //URL的端口号作为moduleID
    NSNumber *moduleID = targetURL.port;
    if (moduleID) {
        NSString *homePath = [KYJSONHanler getHomePathWithModuleID:moduleID];
        if ([NSClassFromString(homePath) isSubclassOfClass:[UIViewController class]]) {
            NSString *parameterStr = [[targetURL query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *dic = nil;
            if (JKSafeStr(parameterStr)) {
                
                dic = [self convertUrlStringToDictionary:parameterStr];
                [dic addEntriesFromDictionary:params];
            }else{
                dic = [NSMutableDictionary dictionaryWithDictionary:params];
            }
            NSString *vcClassName = homePath;
            RouterOptions *options = [RouterOptions optionsWithModuleID:[NSString stringWithFormat:@"%@",moduleID]];
            options.defaultParams = [dic copy];
            //执行页面的跳转
            [self open:(NSString *)vcClassName options:options];
            
        }else{
            NSString *subPath = targetURL.resourceSpecifier;
            NSString *path = [NSString stringWithFormat:@"%@/%@",homePath,subPath];
            RouterOptions *options = [RouterOptions optionsWithModuleID:[NSString stringWithFormat:@"%@",moduleID]];
            [self jumpToHttpWeb:path options:options];
            
        }
    }else{
        NSString *path = targetURL.path;
        if ([NSClassFromString(path) isKindOfClass:[UIViewController class]]) {
            NSString *parameterStr = [[targetURL query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *dic = nil;
            if (JKSafeStr(parameterStr)) {
                
                dic = [self convertUrlStringToDictionary:parameterStr];
                [dic addEntriesFromDictionary:params];
            }else{
                dic = [NSMutableDictionary dictionaryWithDictionary:params];
            }
            NSString *vcClassName = path;
            RouterOptions *options = [RouterOptions optionsWithModuleID:[NSString stringWithFormat:@"%@",moduleID]];
            options.defaultParams = [dic copy];
            //执行页面的跳转
            [self open:(NSString *)vcClassName options:options];
        }else{
            RouterOptions *options = [RouterOptions optionsWithModuleID:[NSString stringWithFormat:@"%@",moduleID]];
            [self jumpToHttpWeb:path options:options];
        }
    }

}


+ (void)httpOpen:(NSURL *)targetURL{
    NSString *parameterStr = [[targetURL query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (JKSafeStr(parameterStr)) {
        NSMutableDictionary *dic = [self convertUrlStringToDictionary:parameterStr];
        NSDictionary *params = [dic copy];
        if (JKSafeDic(params) && [[params objectForKey:KYRouterHttpOpenStyleKey] isEqualToString:@"1"]) {//判断是否是在app内部打开网页
            RouterOptions *options = [RouterOptions options];
            [self jumpToHttpWeb:targetURL.absoluteString options:options];
            return;
        }
    }
    [self openExternal:targetURL];
}


/**
 根据路径跳转到指定的httpWeb页面
 
 @param directory 指定的路径
 */
+ (void)jumpToHttpWeb:(NSString *)directory options:(RouterOptions *)options{
    if (!JKSafeStr(directory)) {
        KYRouterLog(@"路径不存在");
        return;
    }
    
    NSString *path =[NSString stringWithFormat:@"%@/%@",[KYRouterExtension sandBoxBasePath],directory];
    NSDictionary *params = @{[KYRouterExtension kyWebURLKey]:path};
    options.defaultParams =params;
    [self open:[KYRouter router].webContainerName options:options];
    
}

+ (void)openExternal:(NSURL *)targetURL {
    if ([targetURL.scheme isEqualToString:@"http"] ||[targetURL.scheme isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:targetURL options:@{} completionHandler:nil];
    }else{
        NSAssert(NO, @"请打开http／https协议的url地址");
    }
}

#pragma mark  the pop functions - - - - - - - - - -
+ (void)pop{
    [self pop:YES];
}

+ (void)pop:(BOOL)animated{
    [self pop:nil :animated];
}

+ (void)pop:(NSDictionary *)params :(BOOL)animated{
    
    NSArray *vcArray = [KYRouter router].navigationController.viewControllers;
    NSUInteger count = vcArray.count;
    UIViewController *vc= nil;
    if (vcArray.count>1) {
        vc = vcArray[count-2];
    }else{
        //已经是根视图，不再执行pop操作  可以执行dismiss操作
        [self popToSpecifiedVC:nil animated:animated];
        
        return;
    }
    RouterOptions *options = [RouterOptions optionsWithDefaultParams:params];
    [self configTheVC:vc options:options];
    [self popToSpecifiedVC:vc animated:animated];
    
}

+ (void)popToSpecifiedVC:(UIViewController *)vc{
    
    [self popToSpecifiedVC:vc animated:YES];
}

+ (void)popToSpecifiedVC:(UIViewController *)vc animated:(BOOL)animated{
    
    if ([KYRouter router].navigationController.presentedViewController) {
        
        [[KYRouter router].navigationController dismissViewControllerAnimated:animated completion:nil];
    }
    else {
        
        [[KYRouter router].navigationController popToViewController:vc animated:animated];
    }
}

+ (void)popWithSpecifiedModuleID:(NSString *)moduleID{
    
    [self popWithSpecifiedModuleID:moduleID :nil :YES];
}

+ (void)popWithSpecifiedModuleID:(NSString *)moduleID :(NSDictionary *)params :(BOOL)animated{
    NSArray *vcArray  = [KYRouter router].navigationController.viewControllers;
    for (NSInteger i = vcArray.count-1; i>0; i--) {
        UIViewController *vc = vcArray[i];
        if ([vc.moduleID isEqualToString:moduleID]) {
            RouterOptions *options = [RouterOptions optionsWithDefaultParams:params];
            [self configTheVC:vc options:options];
            [self popToSpecifiedVC:vc animated:animated];
        }
    }
}



#pragma mark  the tool functions - - - - - - - -

//为ViewController 的属性赋值
+ (UIViewController *)configVC:(NSString *)vcClassName options:(RouterOptions *)options {
    
    Class VCClass = NSClassFromString(vcClassName);
    UIViewController *vc = [VCClass kyRouterViewController];
    [vc setValue:options.moduleID forKey:KYRouterModuleIDKey];
    
    [KYRouter configTheVC:vc options:options];
    
    return vc;
}

/**
 对于已经创建的vc进行赋值操作
 
 @param vc 对象
 @param options 跳转的各种设置
 */
+ (void)configTheVC:(UIViewController *)vc options:(RouterOptions *)options{
    
    if (JKSafeDic(options.defaultParams)) {
        NSArray *propertyNames = [options.defaultParams allKeys];
        for (NSString *key in propertyNames) {
            id value =options.defaultParams[key];
            [vc setValue:value forKey:key];
            
        }
        
    }
    
}
//将url ？后的字符串转换为NSDictionary对象
+ (NSMutableDictionary *)convertUrlStringToDictionary:(NSString *)string{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *parameterArr = [string componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameterArr) {
        NSArray *parameterBoby = [parameter componentsSeparatedByString:@"="];
        if (parameterBoby.count == 2) {
            [dic setObject:parameterBoby[1] forKey:parameterBoby[0]];
        }else
        {
            KYRouterLog(@"参数不完整");
        }
    }
    return dic;
}

//根据相关的options配置，进行跳转
+ (BOOL)routerViewController:(UIViewController *)vc options:(RouterOptions *)options{
    
    if (![[vc class]  validateTheAccessToOpen]) {//权限不够进行别的操作处理
        //根据具体的权限设置决定是否进行跳转，如果没有权限，跳转中断，进行后续处理
        [[vc class] handleNoAccessToOpen];
        return NO;
    }
    if (!([KYRouter router].navigationController && [[KYRouter router].navigationController isKindOfClass:[UINavigationController class]])) {
        return NO;
    }
    if ([KYRouter router].navigationController.presentationController) {
        
        [[KYRouter router].navigationController dismissViewControllerAnimated:NO completion:nil];
    }
    if (options.transFormVCStyle == RouterTransformVCStyleDefault) {
        options.transFormVCStyle =  [vc kyRouterTransformStyle];
    }
    switch (options.transFormVCStyle) {
        case RouterTransformVCStylePush:
        {
            [self _openWithPushStyle:vc options:options];
        }
            break;
        case RouterTransformVCStylePresent:
        {
            [self _openWithPresentStyle:vc options:options];
        }
            break;
        case RouterTransformVCStyleOther:
        {
            [self _openWithOtherStyle:vc options:options];
        }
            break;
            
        default:
            break;
    }
    
    return NO;
}

+ (BOOL)_openWithPushStyle:(UIViewController *)vc options:(RouterOptions *)options{
    [[KYRouter router].navigationController pushViewController:vc animated:options.animated];
    return YES;
}

+ (BOOL)_openWithPresentStyle:(UIViewController *)vc options:(RouterOptions *)options{
    [[KYRouter router].navigationController presentViewController:vc animated:options.animated completion:nil];
    return YES;
}

+ (BOOL)_openWithOtherStyle:(UIViewController *)vc options:(RouterOptions *)options{
    [vc kyRouterSpecialTransformWithNaVC:[KYRouter router].navigationController];
    return YES;
}


@end
