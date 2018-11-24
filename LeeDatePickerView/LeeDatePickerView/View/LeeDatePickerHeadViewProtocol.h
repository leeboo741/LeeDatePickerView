//
//  LeeDatePickerHeadViewProtocol.h
//  LeeDatePickerView
//
//  Created by mac on 2018/11/23.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeeDatePickerHeadViewDelegate.h"

@protocol LeeDatePickerHeadViewProtocol <NSObject>

@property (nonatomic, copy) NSString * startTimeStr;
@property (nonatomic, copy) NSString * endTimeStr;

@property (nonatomic, weak) id<LeeDatePickerHeadViewDelegate>delegate;

@end
