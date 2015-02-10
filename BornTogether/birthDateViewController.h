//
//  birthDateViewController.h
//  BornTogether
//
//  Created by Nutech Systems on 11/3/14.
//  Copyright (c) 2014 Stefan Brown. All rights reserved.
//

#import <UIKit/UIKit.h>

//protocol to allow updating of birthdate labels.
@protocol birthdateDelegate
-(void)refreshBirthdate;
@end

@interface birthDateViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak) id <birthdateDelegate> delegate;

@end
