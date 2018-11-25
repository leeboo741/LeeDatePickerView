//
//  ViewController.m
//  LeeDatePickerView
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController.h"
#import "LeeDatePickerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonAction:(id)sender {
    [LeeDatePickerView showLeeDatePickerViewWithBlock:^(NSDate *startDate, NSDate *endDate) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy.MM.dd"];
        NSLog(@"%@",[formatter stringFromDate:startDate]);
        NSLog(@"%@",[formatter stringFromDate:endDate]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
