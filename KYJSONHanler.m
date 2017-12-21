//
//  KYJSONHanler.m
//  KYRouter
//
//  Created by Macx on 2017/12/19.
//  Copyright © 2017年 FEC. All rights reserved.
//

#import "KYJSONHanler.h"

@implementation KYJSONHanler
// 解析JSON文件 获取到所有的Modules
+ (NSArray *)getModulesFromJsonFile:(NSArray <NSString *>*)files {
    NSMutableArray *mutableArray = [NSMutableArray new];
    
    for (NSString *fileName in files) {
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSArray *modules = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [mutableArray addObjectsFromArray:modules];
    }
    
    
    return [mutableArray copy];
}

+ (NSString *)getHomePathWithModuleID:(NSNumber *)moduleID{
    
    return @"";
}

@end
