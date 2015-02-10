//
//  birthDateViewController.m
//  BornTogether
//
//  Created by Nutech Systems on 11/3/14.
//  Copyright (c) 2014 Stefan Brown. All rights reserved.
//

#import "birthDateViewController.h"

@interface birthDateViewController ()

@property (nonatomic, weak) PFUser* currentUser;
@property (nonatomic, weak) NSDictionary *profile;
@property (nonatomic, strong) NSDateFormatter *birthdayFormat;

@end

@implementation birthDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _currentUser = [PFUser currentUser];
    _profile = _currentUser[@"profile"];
    _birthdayFormat = [[NSDateFormatter alloc]init];
    [_birthdayFormat setDateFormat:@"MM/dd/yyyy"];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    if ([_profile[@"birthday"] length]>0) {
        _datePicker.date = [_birthdayFormat dateFromString:_profile[@"birthday"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setDate:(id)sender {
    [_profile setValue:[_birthdayFormat stringFromDate:_datePicker.date] forKey:@"birthday"];
    NSLog(@"Setting date: %@", [_birthdayFormat stringFromDate:_datePicker.date]);
    NSLog(@"%@", _profile);
    [_currentUser setValue:_profile forKey:@"profile"];
    [_currentUser saveInBackground];
    [_delegate refreshBirthdate];
    [self.navigationController popViewControllerAnimated:YES];
}

@end