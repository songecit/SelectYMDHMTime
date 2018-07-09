//
//  ViewController.m
//  SeletYMDHMTime
//
//  Created by 86links_dsqi on 2018/7/9.
//  Copyright © 2018年 TM. All rights reserved.
//

#import "ViewController.h"
#import "RSTDatePickerView.h"

@interface ViewController ()

@property (nonatomic, strong) RSTDatePickerView *datePickerView;
- (IBAction)clickSelectTimeButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *timeResultLabel;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(RSTDatePickerView *)datePickerView
{
    if (!_datePickerView) {
        _datePickerView = [[RSTDatePickerView alloc]init];
        _datePickerView.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
    }
    return _datePickerView;
}

- (IBAction)clickSelectTimeButton:(UIButton *)sender {
    

    __weak __typeof(self) weakSelf = self;
    self.datePickerView.selectValue  = ^(NSString *value){
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        NSString *time_str = [NSString stringWithFormat:@"%@",value];
        strongSelf.timeResultLabel.text = time_str;
    };
    
    [self.datePickerView show];
}

@end
