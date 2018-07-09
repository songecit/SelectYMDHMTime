//
//  RSTDatePickerView.m
//  rongyp-company
//
//  Created by Apple on 2016/11/16.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "RSTDatePickerView.h"

@interface RSTDatePickerView () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) UIPickerView *pickerView; // 选择器
@property (nonatomic, strong) UIView *bgView;
@property (strong, nonatomic) UILabel *titleLbl; // 标题

@property (strong, nonatomic) NSMutableArray *dataArray; // 数据源
@property (copy, nonatomic) NSString *selectStr; // 选中的时间


@property (strong, nonatomic) NSMutableArray *yearArr; // 年数组
@property (strong, nonatomic) NSMutableArray *monthArr; // 月数组
@property (strong, nonatomic) NSMutableArray *dayArr; // 日数组
@property (strong, nonatomic) NSMutableArray *hourArr; // 时数组
@property (strong, nonatomic) NSMutableArray *minuteArr; // 分数组
@property (strong, nonatomic) NSArray *timeArr; // 当前时间数组

@property (copy, nonatomic) NSString *year; // 选中年
@property (copy, nonatomic) NSString *month; //选中月
@property (copy, nonatomic) NSString *day; //选中日
@property (copy, nonatomic) NSString *hour; //选中时
@property (copy, nonatomic) NSString *minute; //选中分

@end

static CGFloat pickerHeight = 245.f;
static CGFloat bgViewHeight = 290.f;

@implementation RSTDatePickerView

#pragma mark - init
/// 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {

      self.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
      self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
      
      self.timeArr = [NSArray array];
      
      self.dataArray = [NSMutableArray array];
      self.minuteArr = [NSMutableArray array];
      [self.dataArray addObject:self.yearArr];
      [self.dataArray addObject:self.monthArr];
      [self.dataArray addObject:self.dayArr];
      [self.dataArray addObject:self.hourArr];
      
      [self configData];
      [self configSubviews];
   }
   return self;
}

- (void)configData {
   
   self.isSlide = YES;
   self.minuteInterval = 5;
   
   NSDate *date = [NSDate date];
   NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
   [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
   
   self.date = [dateFormatter stringFromDate:date];
}


#pragma mark - 配置界面
- (void)configSubviews
{
   UIView *bgView = [UIView new];
   bgView.frame = CGRectMake(0, kMainScreenHeight-bgViewHeight, kMainScreenWidth, bgViewHeight);
   bgView.backgroundColor = [UIColor whiteColor];
   [self addSubview:bgView];
   self.bgView = bgView;
   
   UIView *toolBgView = [UIView new];
   toolBgView.frame = CGRectMake(0, 0, kMainScreenWidth, 45);
   toolBgView.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
   [bgView addSubview:toolBgView];
   
   UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(0, 0, 80, 45)];
   [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
   cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
   [cancelBtn addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
   [toolBgView addSubview:cancelBtn];
   
   UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setFrame:CGRectMake(kMainScreenWidth - 80, 0, 80, 45)];
   [sureBtn setTitle:@"确认" forState:UIControlStateNormal];
   [sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
   sureBtn.titleLabel.font = [UIFont systemFontOfSize:17];
   [sureBtn addTarget:self action:@selector(clickSaveButton:) forControlEvents:UIControlEventTouchUpInside];
   [toolBgView addSubview:sureBtn];
   
   self.titleLbl = [[UILabel alloc] init];
   self.titleLbl.frame = CGRectMake(60, 2, self.frame.size.width - 120, 40);
   self.titleLbl.textAlignment = NSTextAlignmentCenter;
   self.titleLbl.textColor = [UIColor blueColor] ;
   [bgView addSubview:self.titleLbl];
   
   self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 45, kMainScreenWidth, pickerHeight)];
   self.pickerView.backgroundColor = [UIColor whiteColor];
   self.pickerView.dataSource = self;
   self.pickerView.delegate = self;
   self.pickerView.showsSelectionIndicator = YES;
   [bgView addSubview:self.pickerView];
}

- (void)setTitle:(NSString *)title {
   _title = title;
   self.titleLbl.text = title;
}

- (void)setDate:(NSString *)date {
   _date = date;
   
   NSString *newDate = [[date stringByReplacingOccurrencesOfString:@"-" withString:@" "] stringByReplacingOccurrencesOfString:@":" withString:@" "];
   NSMutableArray *timerArray = [NSMutableArray arrayWithArray:[newDate componentsSeparatedByString:@" "]];
   [timerArray replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@年", timerArray[0]]];
   [timerArray replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%@月", timerArray[1]]];
   [timerArray replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%@日", timerArray[2]]];
   [timerArray replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%@时", timerArray[3]]];
   [timerArray replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"%@分", timerArray[4]]];
   self.timeArr = timerArray;
}

- (void)setMinuteInterval:(NSInteger)minuteInterval {
   _minuteInterval = minuteInterval;
   
   if (self.minuteArr.count > 0) {
      [self.minuteArr removeAllObjects];
      self.minuteArr = [self configMinuteArray];
      [self.dataArray replaceObjectAtIndex:self.dataArray.count - 1 withObject:self.minuteArr];
   } else {
      self.minuteArr = [self configMinuteArray];
      [self.dataArray addObject:self.minuteArr];
   }
}

#pragma mark - UIPickerViewDelegate and UIPickerViewDataSource
/// UIPickerView返回多少组
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
   return self.dataArray.count;
}

/// UIPickerView返回每组多少条数据
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
   return  [self.dataArray[component] count] * 200;
}

/**
 * a、更改年：1、对比当前年；2、更新月，更新日，更新时；
 * b、更改月：1、对比当前年，对比当前月；2、更新日，更新时；
 * c、更新日：1、对比当前年，对比当前月，对比当前日；2、更新时；
 * d、更新时：1、对比当前年，对比当前月，对比当前日，对比当前时；
 */

/// UIPickerView选择哪一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
   
   switch (component) {
      case 0: { // 年
         
         NSString *year_integerValue = self.yearArr[row%[self.dataArray[component] count]];
         if (!self.isSlide) {
            self.year = year_integerValue;
            // 选择年，2月份刷新日
            if (self.month.integerValue == 2) {
               [self refreshDay];
            }
            return;
         }
         
         // 选择年，刷新日
         if (year_integerValue.integerValue >  [self.timeArr[component] integerValue]) {
            self.year = year_integerValue;
            
            // 2月份刷新日
            if (self.month.integerValue == 2) {
               
               [self refreshDay];
               // 根据当前选择的年份和月份获取当月的天数
               NSString *dayStr = [self getDayNumber:[self.year integerValue] month:[self.month integerValue]];
               if (self.dayArr.count > [dayStr integerValue]) {
                  if (self.day.integerValue > [dayStr integerValue]) {
                     [pickerView selectRow:[self.dataArray[2] indexOfObject:[dayStr stringByAppendingString:@"日"]] inComponent:2 animated:YES];
                     self.day = [dayStr stringByAppendingString:@"日"];
                  }
               }
            }
            
         } else {
            
            [pickerView selectRow:[self.dataArray[component] indexOfObject:self.timeArr[component]] inComponent:component animated:YES];
            self.year = self.timeArr[component];
            
            // 更新月，更新日，更新时；
            if (self.month.integerValue <= [self.timeArr[1] integerValue]) {
               
               // 刷新月
               [pickerView selectRow:[self.dataArray[1] indexOfObject:self.timeArr[1]] inComponent:1 animated:YES];
               self.month = self.timeArr[1];
               
               // 刷新日，刷新时；
               if (self.day.integerValue <= [self.timeArr[2] integerValue]) {
                  
                  // 刷新日
                  [pickerView selectRow:[self.dataArray[2] indexOfObject:self.timeArr[2]] inComponent:2 animated:YES];
                  self.day = self.timeArr[2];
                  
                  // 刷新时；
                  if (self.hour.integerValue < [self.timeArr[3] integerValue]) {
                     
                     [pickerView selectRow:[self.dataArray[3] indexOfObject:self.timeArr[3]] inComponent:3 animated:YES];
                     self.hour = self.timeArr[3];
                  }
               }
            }
         }
      }
         break;
         
      case 1: {
         // 月
         NSString *month_value = self.monthArr[row%[self.dataArray[component] count]];
         if (!self.isSlide) {
            self.month = month_value;
            /// 刷新日
            [self refreshDay];
            return;
         }
         
         if ([self.year integerValue] > [self.timeArr[0] integerValue]) {
            
            // 如果选择年大于当前年 就直接赋值月
            self.month = month_value;
            
            // 根据当前选择的年份和月份获取当月的天数 : 每个月对应的天数会变化
            NSString *dayStr = [self getDayNumber:[self.year integerValue] month:[self.month integerValue]];
            if (self.dayArr.count > [dayStr integerValue]) {
               if (self.day.integerValue > [dayStr integerValue]) {
                  [pickerView selectRow:[self.dataArray[2] indexOfObject:[dayStr stringByAppendingString:@"日"]] inComponent:2 animated:YES];
                  self.day = [dayStr stringByAppendingString:@"日"];
               }
            }
            
            // 刷新日
            [self refreshDay];
            
         } else if ([self.year integerValue] == [self.timeArr[0] integerValue]) {
            
            // 如果选择的年等于当前年，就判断月份
            if (month_value.integerValue > [self.timeArr[component] integerValue]) {
               
               // 如果选择的月份大于当前月份，就直接赋值月份
               self.month = month_value;
               
               // 根据当前选择的年份和月份获取当月的天数
               NSString *dayStr = [self getDayNumber:[self.year integerValue] month:[self.month integerValue]];
               if (self.dayArr.count > dayStr.integerValue) {
                  if (self.day.integerValue > dayStr.integerValue) {
                     [pickerView selectRow:[self.dataArray[2] indexOfObject:[dayStr stringByAppendingString:@"日"]] inComponent:2 animated:YES];
                     self.day = [dayStr stringByAppendingString:@"日"];
                  }
               }
               
               // 刷新日
               [self refreshDay];
               
            } else {
               
               // 如果选择的月份不大于当前月份 就刷新到当前月份
               [pickerView selectRow:[self.dataArray[component] indexOfObject:self.timeArr[component]] inComponent:component animated:YES];
               self.month = self.timeArr[component];
               
               // 刷新日，刷新时；
               if (self.day.integerValue <= [self.timeArr[2] integerValue]) {
                  
                  // 选择的日不大于当前日
                  [pickerView selectRow:[self.dataArray[2] indexOfObject:self.timeArr[2]] inComponent:2 animated:YES];
                  self.day = self.timeArr[2];
                  
                  // 刷新时；
                  if (self.hour.integerValue < [self.timeArr[3] integerValue]) {
                     
                     [pickerView selectRow:[self.dataArray[3] indexOfObject:self.timeArr[3]] inComponent:3 animated:YES];
                     self.hour = self.timeArr[3];
                  }
               }
            }
         }
      }
         break;
         
      case 2: {
         // 日
         /// 根据当前选择的年份和月份获取当月的天数
         NSString *day_value = self.dayArr[row%[self.dataArray[component] count]];
         if (!self.isSlide) {
            self.day = day_value;
            return;
         }
         
         NSString *dayStr = [self getDayNumber:[self.year integerValue] month:[self.month integerValue]];
         if ([self.year integerValue] > [self.timeArr[0] integerValue]) {
            
            // 如果选择年大于当前年 就直接赋值日
            if (self.dayArr.count <= [dayStr integerValue]) {
               
               self.day = day_value;
               
            } else {
               
               if (day_value.integerValue <= [dayStr integerValue]) {
                  
                  self.day = day_value;
                  
               } else {
                  
                  [pickerView selectRow:[self.dataArray[component] indexOfObject:[dayStr stringByAppendingString:@"日"]] inComponent:component animated:YES];
                  self.day = [dayStr stringByAppendingString:@"日"];
               }
            }
            
         } else if ([self.year integerValue] == [self.timeArr[0] integerValue]) {
            
            // 如果选择的年等于当前年，就判断月份
            if ([self.month integerValue] > [self.timeArr[1] integerValue]) {
               
               if (self.dayArr.count <= [dayStr integerValue]) {
                  
                  // 如果选择的月份大于当前月份 就直接赋值
                  self.day = day_value;
                  
               } else {
                  
                  if (day_value.integerValue <= [dayStr integerValue]) {
                     
                     self.day = day_value;
                     
                  } else {
                     
                     [pickerView selectRow:[self.dataArray[component] indexOfObject:[dayStr stringByAppendingString:@"日"]] inComponent:component animated:YES];
                     self.day = [dayStr stringByAppendingString:@"日"];
                  }
               }
               
            } else if ([self.month integerValue] == [self.timeArr[1] integerValue]) {
               
               // 如果选择的月份等于当前月份，就判断日
               if (day_value.integerValue > [self.timeArr[component] integerValue]) {
                  
                  // 如果选择的日大于当前日，就赋值日
                  if (self.dayArr.count <= [dayStr integerValue]) {
                     
                     self.day = day_value;
                     
                  } else {
                     
                     if ([self.dayArr[row%[self.dataArray[component] count]] integerValue] <= [dayStr integerValue]) {
                        
                        self.day = day_value;
                        
                     } else {
                        
                        [pickerView selectRow:[self.dataArray[component] indexOfObject:[dayStr stringByAppendingString:@"日"]] inComponent:component animated:YES];
                        self.day = [dayStr stringByAppendingString:@"日"];
                     }
                  }
                  
               } else {
                  
                  // 如果选择的日不大于当前日，就刷新到当前日
                  [pickerView selectRow:[self.dataArray[component] indexOfObject:self.timeArr[component]] inComponent:component animated:YES];
                  self.day = self.timeArr[component];
                  
                  // 刷新时；
                  if (self.hour.integerValue < [self.timeArr[3] integerValue]) {
                     
                     [pickerView selectRow:[self.dataArray[3] indexOfObject:self.timeArr[3]] inComponent:3 animated:YES];
                     self.hour = self.timeArr[3];
                  }
               }
            }
         }
      }
         break;
         
      case 3: {
         
         // 时
         NSString *hour_value = self.hourArr[row%[self.dataArray[component] count]];
         if (!self.isSlide) {
            self.hour = hour_value;
            return;
         }
         
         if ([self.year integerValue] > [self.timeArr[0] integerValue]) {
            
            // 如果选择年大于当前年 就直接赋值时
            self.hour = hour_value;
            
         } else if ([self.year integerValue] == [self.timeArr[0] integerValue]) {
            
            // 如果选择的年等于当前年，就判断月份
            if ([self.month integerValue] > [self.timeArr[1] integerValue]) {
               
               // 如果选择的月份大于当前月份 就直接赋值时
               self.hour = hour_value;
               
            } else if ([self.month integerValue] == [self.timeArr[1] integerValue]) {
               
               // 如果选择的月份等于当前月份，就判断日
               if ([self.day integerValue] > [self.timeArr[2] integerValue]) {
                  
                  // 如果选择的日大于当前日，就直接赋值时
                  self.hour = hour_value;
                  
               } else if ([self.day integerValue] == [self.timeArr[2] integerValue]) {
                  
                  // 如果选择的日等于当前日，就判断时
                  if ([self.hourArr[row%[self.dataArray[component] count]] integerValue] < [self.timeArr[3] integerValue]) {
                     
                     // 如果选择的时小于当前时，就刷新到当前时
                     [pickerView selectRow:[self.dataArray[component] indexOfObject:self.timeArr[component]] inComponent:component animated:YES];
                     
                     self.hour = self.timeArr[component];
                     
                  } else {
                     
                     // 如果选择的时大于当前时，就直接赋值
                     self.hour = hour_value;
                  }
               }
            }
         }
      }
         break;
         
      case 4: {
         // 分 直接赋值
         self.minute = self.minuteArr[row%[self.dataArray[component] count]];
      }
         break;
         
      default:
         break;
   }
}

/// UIPickerView返回每一行数据
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
   return  [self.dataArray[component] objectAtIndex:row%[self.dataArray[component] count]];
}
/// UIPickerView返回每一行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
   return 44;
}
/// UIPickerView返回每一行的View
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
   UILabel *titleLbl;
   if (!view) {
      titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 44)];
      titleLbl.font = [UIFont systemFontOfSize:15];
      titleLbl.textAlignment = NSTextAlignmentCenter;
   } else {
      titleLbl = (UILabel *)view;
   }
   titleLbl.text = [self.dataArray[component] objectAtIndex:row%[self.dataArray[component] count]];
   return titleLbl;
}


- (void)pickerViewLoaded:(NSInteger)component row:(NSInteger)row{
   NSUInteger max = 16384;
   NSUInteger base10 = (max/2)-(max/2)%row;
   [self.pickerView selectRow:[self.pickerView selectedRowInComponent:component] % row + base10 inComponent:component animated:NO];
}

/// 获取年份
- (NSMutableArray *)yearArr {
   if (!_yearArr) {
      _yearArr = [NSMutableArray array];
      for (int i = 2016; i < 2115; i ++) {
         [_yearArr addObject:[NSString stringWithFormat:@"%d年", i]];
      }
   }
   return _yearArr;
}

/// 获取月份
- (NSMutableArray *)monthArr {
   //    NSDate *today = [NSDate date];
   //    NSCalendar *c = [NSCalendar currentCalendar];
   //    NSRange days = [c rangeOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:today];
   if (!_monthArr) {
      _monthArr = [NSMutableArray array];
      for (int i = 1; i <= 12; i ++) {
         [_monthArr addObject:[NSString stringWithFormat:@"%02d月", i]];
      }
   }
   return _monthArr;
}

/// 获取当前月的天数
- (NSMutableArray *)dayArr {
   if (!_dayArr) {
      _dayArr = [NSMutableArray array];
      for (int i = 1; i <= 31; i ++) {
         [_dayArr addObject:[NSString stringWithFormat:@"%02d日", i]];
      }
   }
   return _dayArr;
}

/// 获取小时
- (NSMutableArray *)hourArr {
   if (!_hourArr) {
      _hourArr = [NSMutableArray array];
      for (int i = 0; i < 24; i ++) {
         [_hourArr addObject:[NSString stringWithFormat:@"%02d时", i]];
      }
   }
   return _hourArr;
}

/// 获取分钟
- (NSMutableArray *)configMinuteArray {
   NSMutableArray *minuteArray = [NSMutableArray array];
   for (int i = 0; i <= 60 - self.minuteInterval; i ++) {
      if (i % self.minuteInterval == 0) {
         [minuteArray addObject:[NSString stringWithFormat:@"%02d分", i]];
         continue;
      }
   }
   return minuteArray;
}

// 比较选择的时间是否小于当前时间
- (int)compareDate:(NSString *)date01 withDate:(NSString *)date02{
   int ci;
   NSDateFormatter *df = [[NSDateFormatter alloc]init];
   [df setDateFormat:@"yyyy年,MM月,dd日,HH时,mm分"];
   NSDate *dt1 = [[NSDate alloc] init];
   NSDate *dt2 = [[NSDate alloc] init];
   dt1 = [df dateFromString:date01];
   dt2 = [df dateFromString:date02];
   NSComparisonResult result = [dt1 compare:dt2];
   switch (result) {
         //date02比date01大
      case NSOrderedAscending: ci=1;break;
         //date02比date01小
      case NSOrderedDescending: ci=-1;break;
         //date02=date01
      case NSOrderedSame: ci=0;break;
      default: NSLog(@"erorr dates %@, %@", dt2, dt1);break;
   }
   return ci;
}


- (void)refreshDay {
   NSMutableArray *arr = [NSMutableArray array];
   for (int i = 1; i < [self getDayNumber:self.year.integerValue month:self.month.integerValue].integerValue + 1; i ++) {
      [arr addObject:[NSString stringWithFormat:@"%02d日", i]];
   }
   
   [self.dataArray replaceObjectAtIndex:2 withObject:arr];
   [self.pickerView reloadComponent:2];
}

- (NSString *)getDayNumber:(NSInteger)year month:(NSInteger)month
{
   NSArray *days = @[@"31", @"28", @"31", @"30", @"31", @"30", @"31", @"31", @"30", @"31", @"30", @"31"];
   if (2 == month && 0 == (year % 4) && (0 != (year % 100) || 0 == (year % 400))) {
      return @"29";
   }
   return days[month - 1];
}

#pragma mark - 点击方法
/// 保存按钮点击方法
- (void)clickSaveButton:(UIButton *)button
{
   NSString *resultTimeStr=[NSString stringWithFormat:@"%ld/%02ld/%02ld %02ld:%02ld", self.year.integerValue, self.month.integerValue, self.day.integerValue, self.hour.integerValue, self.minute.integerValue];
   if (self.selectValue) {
      self.selectValue(resultTimeStr);
   }
   [self removeSelfFromSupView];
   
   if ([self.delegate respondsToSelector:@selector(datePickerViewSaveBtnClickDelegate:)]) {
      [self.delegate datePickerViewSaveBtnClickDelegate:resultTimeStr];
   }
}

/// 取消按钮点击方法
- (void)clickCancelButton:(UIButton *)button
{
   [self removeSelfFromSupView];

   if ([self.delegate respondsToSelector:@selector(datePickerViewCancelBtnClickDelegate)]) {
      
      [self.delegate datePickerViewCancelBtnClickDelegate];
   }
}

#pragma mark -- 视图的关闭和显示
/**
 弹出视图
 */
- (void)show
{
   self.year = self.timeArr[0];
   self.month = self.timeArr[1];
   self.day = self.timeArr[2];
   self.hour = self.timeArr[3];
   self.minute = self.minuteInterval == 1 ? [NSString stringWithFormat:@"%02ld分", (long)[self.timeArr[4] integerValue]] : self.minuteArr[self.minuteArr.count / 2];
   
   [self.pickerView selectRow:[self.yearArr indexOfObject:self.year] inComponent:0 animated:YES];
   /// 重新格式化转一下，是因为如果是09月/日/时，数据源是9月/日/时,就会出现崩溃
   [self.pickerView selectRow:[self.monthArr indexOfObject:self.month] inComponent:1 animated:YES];
   [self.pickerView selectRow:[self.dayArr indexOfObject:self.day] inComponent:2 animated:YES];
   [self.pickerView selectRow:[self.hourArr indexOfObject:self.hour] inComponent:3 animated:YES];
   [self.pickerView selectRow:self.minuteInterval == 1 ? ([self.minuteArr indexOfObject:self.minute]) : (self.minuteArr.count / 2) inComponent:4 animated:YES];
   
   /// 刷新日
   [self refreshDay];
   
   self.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
   [[[UIApplication sharedApplication].delegate window] addSubview:self];
   //动画出现
   CGRect frame = self.bgView.frame;
   if (frame.origin.y == kMainScreenHeight) {
      frame.origin.y -= bgViewHeight;
      [UIView animateWithDuration:0.3 animations:^{
         self.bgView.frame = frame;
      }];
   }
}

/**
 移除视图
 */
- (void)removeSelfFromSupView
{
   CGRect selfFrame = self.bgView.frame;
   if (selfFrame.origin.y == kMainScreenHeight -  bgViewHeight) {
      selfFrame.origin.y += bgViewHeight;
      [UIView animateWithDuration:0.3 animations:^{
         self.bgView.frame = selfFrame;
      }completion:^(BOOL finished) {
         [self removeFromSuperview];
      }];
   }
}

/**
 点击空白关闭
 */
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
   [self removeSelfFromSupView];
}

@end
