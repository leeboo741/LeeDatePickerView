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
@property (weak, nonatomic) IBOutlet UILabel *startTimelabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimelabel;
@property (weak, nonatomic) IBOutlet UILabel *singleTimelabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonAction:(id)sender {
    [LeeDatePickerView showLeeDatePickerViewWithStyle:LeeDatePickerViewStyle_StartAndEnd
                                       formatterStyle:LeeDatePickerViewDateFormatterStyle_yMd
                                                block:^(NSArray<NSDate *> *dateArray) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.startTimelabel.text = [dateFormatter stringFromDate:dateArray[LeeDatePickerViewSelectTimeArrayIndex_Start]];
        self.endTimelabel.text =[dateFormatter stringFromDate:dateArray[LeeDatePickerViewSelectTimeArrayIndex_End]];
    }];
}
- (IBAction)ymdhmZoneAction:(id)sender {
    [LeeDatePickerView showLeeDatePickerViewWithStyle:LeeDatePickerViewStyle_StartAndEnd
                                       formatterStyle:LeeDatePickerViewDateFormatterStyle_yMdHm
                                                block:^(NSArray<NSDate *> *dateArray) {
                                                    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
                                                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                                                    self.startTimelabel.text = [dateFormatter stringFromDate:dateArray[LeeDatePickerViewSelectTimeArrayIndex_Start]];
                                                    self.endTimelabel.text =[dateFormatter stringFromDate:dateArray[LeeDatePickerViewSelectTimeArrayIndex_End]];
                                                }];
}
- (IBAction)ymdhmsZoneAction:(id)sender {
    [LeeDatePickerView showLeeDatePickerViewWithStyle:LeeDatePickerViewStyle_StartAndEnd
                                       formatterStyle:LeeDatePickerViewDateFormatterStyle_yMdHms
                                                block:^(NSArray<NSDate *> *dateArray) {
                                                    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
                                                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                                    self.startTimelabel.text = [dateFormatter stringFromDate:dateArray[LeeDatePickerViewSelectTimeArrayIndex_Start]];
                                                    self.endTimelabel.text =[dateFormatter stringFromDate:dateArray[LeeDatePickerViewSelectTimeArrayIndex_End]];
                                                }];
}
- (IBAction)singleSelectAction:(id)sender {
    [LeeDatePickerView showLeeDatePickerViewWithStyle:LeeDatePickerViewStyle_Single
                                       formatterStyle:LeeDatePickerViewDateFormatterStyle_yMd block:^(NSArray<NSDate *> *dateArray) {
                                           NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
                                           [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                           self.singleTimelabel.text = [dateFormatter stringFromDate:dateArray[LeeDatePickerViewSelectTimeArrayIndex_Single]];
                                       }];
}
- (IBAction)ymdhmSingleAction:(id)sender {
    [LeeDatePickerView showLeeDatePickerViewWithStyle:LeeDatePickerViewStyle_Single
                                       formatterStyle:LeeDatePickerViewDateFormatterStyle_yMdHm
                                                block:^(NSArray<NSDate *> *dateArray) {
                                           NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
                                                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                                           self.singleTimelabel.text = [dateFormatter stringFromDate:dateArray[LeeDatePickerViewSelectTimeArrayIndex_Single]];
                                       }];
}
- (IBAction)ymdhmsSingleAction:(id)sender {
    [LeeDatePickerView showLeeDatePickerViewWithStyle:LeeDatePickerViewStyle_Single
                                       formatterStyle:LeeDatePickerViewDateFormatterStyle_yMdHms
                                                block:^(NSArray<NSDate *> *dateArray) {
                                           NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
                                                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                           self.singleTimelabel.text = [dateFormatter stringFromDate:dateArray[LeeDatePickerViewSelectTimeArrayIndex_Single]];
                                       }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
