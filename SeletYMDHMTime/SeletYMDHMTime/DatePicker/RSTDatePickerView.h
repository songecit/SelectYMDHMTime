//
//  RSTDatePickerView.h
//  rongyp-company
//
//  Created by Apple on 2016/11/16.
//  Copyright © 2016年 Apple. All rights reserved.



// UIScreen width.
#define kMainScreenWidth           [UIScreen mainScreen].bounds.size.width
// UIScreen height.
#define kMainScreenHeight         [UIScreen mainScreen].bounds.size.height

//

#import <UIKit/UIKit.h>

@protocol RSTDatePickerViewDelegate <NSObject>

@optional;
/**
 保存按钮代理方法
 
 @param timer 选择的数据
 */
- (void)datePickerViewSaveBtnClickDelegate:(NSString *)timer;

/**
 取消按钮代理方法
 */
- (void)datePickerViewCancelBtnClickDelegate;

@end

@interface RSTDatePickerView : UIView

@property (copy, nonatomic) NSString *title;

/// 是否自动滑动 默认YES
@property (assign, nonatomic) BOOL isSlide;

/// 选中的时间， 默认是当前时间 2017-02-12 13:35
@property (copy, nonatomic) NSString *date;

/// 分钟间隔 默认5分钟
@property (assign, nonatomic) NSInteger minuteInterval;

@property (weak, nonatomic) id <RSTDatePickerViewDelegate> delegate;


//选中值
@property(nonatomic,copy)void(^selectValue)(NSString *value);

/**
 显示  必须调用
 */
- (void)show;

@end
