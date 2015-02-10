//
//  ProfileViewController.m
//  BornTogether
//
//  Created by Michael Thomas on 8/5/14.
//  Copyright (c) 2014 Nutech-Inc. All rights reserved.
//

#import "ProfileViewController.h"
//#import "ChatViewController.h"
#import "ImprovedChatViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"user from home, %@", self.matchedUser);
    
    NSDictionary *profileDict = self.matchedUser[@"profile"];
    
    self.usernameLabel.text = self.matchedUser[@"Alias"];
    self.birthdayLabel.text = profileDict[@"birthday"];
    self.aboutmeLabel.text = self.matchedUser[@"aboutMe"];
    self.aboutmeLabel.backgroundColor = [UIColor clearColor];
    
    NSString *gender = profileDict[@"gender"];
    UIColor *styleColor;
    
    if ([gender isEqualToString:@"male"]) {
        styleColor = [UIColor colorWithRed:204.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7];
    } else {
        styleColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:203.0/255.0 alpha:0.7];
//        UIColor *buttonColor = [UIColor colorWithRed:255.0/255.0 green:20.0/255.0 blue:147.0/255.0 alpha:1.0];
//        [_birthYearLabel setTitleColor:buttonColor forState:UIControlStateNormal];
//        [_updateInfoButton setTitleColor:buttonColor forState:UIControlStateNormal];
//        [_deleteAccountButton setTitleColor:buttonColor forState:UIControlStateNormal];
//        [_logoutButton setTitleColor:buttonColor forState:UIControlStateNormal];
    }
    self.view.backgroundColor = styleColor;

    
    PFFile *theImage = [self.matchedUser objectForKey:USERPROFILEIMAGE];
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        self.profilePicImageView.image = image;
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chatButtonClicked:(UIBarButtonItem *)sender
{
    PFFile *theImage = [[PFUser currentUser] objectForKey:USERPROFILEIMAGE];
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];

        ImprovedChatViewController *ivc = [ImprovedChatViewController messagesViewController];
        ivc.matchedUser = _matchedUser;
        ivc.matchedImage = _profilePicImageView.image;
        ivc.currentImage = image;
        [self.navigationController pushViewController:ivc animated:YES];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toChat"])
    {
//        if ([segue.destinationViewController isKindOfClass:[ChatViewController class]])
//        {
//            ChatViewController *cvc = segue.destinationViewController;
//            cvc.matchedUser =  self.matchedUser;
//        }
    }
}

@end
