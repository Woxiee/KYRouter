//
//  KYRouterHeader.h
//  KYRouter
//
//  Created by Macx on 2017/12/20.
//  Copyright © 2017年 FEC. All rights reserved.
//

#ifndef KYRouterHeader_h
#define KYRouterHeader_h

typedef NS_ENUM(NSInteger,RouterTransformVCStyle){///< ViewController的转场方式
    RouterTransformVCStyleDefault =-1, ///< 不指定转场方式，使用自带的转场方式
    RouterTransformVCStylePush,        ///< push方式转场
    RouterTransformVCStylePresent,     ///< present方式转场
    RouterTransformVCStyleOther        ///< 用户自定义方式转场
};

#import "UIViewController+KYRouter.h"
#import "KYRouter.h"
#import "KYJSONHanler.h"
#import "KYRouterExtension.h"
#import "JKDataHelper.h"

#endif /* KYRouterHeader_h */
