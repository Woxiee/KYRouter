//
//  KYJSONHanler.h
//  KYRouter
//
//  Created by Macx on 2017/12/19.
//  Copyright © 2017年 FEC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KYJSONHanler : NSObject
// 解析JSON文件 获取到所有的Modules
+ (NSArray *)getModulesFromJsonFile:(NSArray <NSString *>*)files;


/**
 根据读取到的json文件中的内容找到对应的路径
 
 @param moduleID 对应的module的主页路径
 @return 对应模块的home页面路径
 */
+ (NSString *)getHomePathWithModuleID:(NSNumber *)moduleID;
@end
