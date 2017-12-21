//
//  KYRouterExtension.m
//  KYRouter
//
//  Created by Macx on 2017/12/20.
//  Copyright © 2017年 FEC. All rights reserved.
//

#import "KYRouterExtension.h"

@implementation KYRouterExtension

+ (BOOL)safeValidateURL:(NSString *)url{
    //默认都是通过安全性校验的
    return YES;
}

+ (NSString *)kyWebURLKey{
    return @"jkurl";
}

+ (NSString *)kyWebVCClassName{
    return @"";
}

+ (NSArray *)urlSchemes{
    return @[@"http",
             @"https"];
}

+ (NSString *)sandBoxBasePath{
    return [[NSBundle mainBundle] pathForResource:nil ofType:nil];
}


@end
