//
//  MTFirstViewController.m
//  FBAPIPractice
//
//  Created by Michael Thomas on 7/16/14.
//  Copyright (c) 2014 Nutech-Inc. All rights reserved.
//

#import "MTFirstViewController.h"
#import "MTConstants.h"

@interface MTFirstViewController ()

@property (strong, nonatomic) NSMutableData *imageData;

@end

@implementation MTFirstViewController
UIImage *profilePic;
BOOL edit = 1;

-(void)refreshBirthdate
{
    PFUser *user= [PFUser currentUser];
    NSDictionary *userDictionary = (NSDictionary *)[user valueForKey:@"profile"];
    NSString *title = [NSString stringWithFormat:@"%@", userDictionary[kCCUserProfileBirthdayKey]];
    [self.birthYearLabel setTitle:title forState:UIControlStateNormal] ;
    [_delegate refreshBirthdate];
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];

}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    edit=1;
	// Do any additional setup after loading the view, typically from a nib.
    self.nameTextField.delegate =self;
    self.aboutMeTextField.delegate = self;
    [self.nameLabel setHidden:NO] ;
    [self.includeInSearchLabel  setHidden:YES];
    [self.imageButtonLabel setEnabled:NO];
    [self.birthLabelStatic setHidden:NO];
    [self.birthYearLabel setHidden:NO];
    [self.includeInSearchLabel setHidden:YES];
    [self.loadingView setHidden:YES];
    [self.activityIndicatiorView setHidden:YES];
    _activityIndicatiorView.frame = [[UIScreen mainScreen] bounds];
    
    PFUser *user= [PFUser currentUser];
    NSDictionary *profile = user[@"profile"];
    NSString *gender = profile[@"gender"];
    UIColor *styleColor;
    
    if ([gender isEqualToString:@"male"]) {
        styleColor = [UIColor colorWithRed:204.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:.7];
    } else {
        styleColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:203.0/255.0 alpha:.7];
        UIColor *buttonColor = [UIColor colorWithRed:255.0/255.0 green:20.0/255.0 blue:147.0/255.0 alpha:1.0];
        [_birthYearLabel setTitleColor:buttonColor forState:UIControlStateNormal];
        [_updateInfoButton setTitleColor:buttonColor forState:UIControlStateNormal];
        [_deleteAccountButton setTitleColor:buttonColor forState:UIControlStateNormal];
        [_logoutButton setTitleColor:buttonColor forState:UIControlStateNormal];
    }
    self.view.backgroundColor = styleColor;

    
    NSDictionary *userDictionary = (NSDictionary *)[user valueForKey:@"profile"];
    
    self.nameLabel.text = [user valueForKey:USERNAME];
    
    NSString *title = [NSString stringWithFormat:@"%@", userDictionary[kCCUserProfileBirthdayKey]];
    if (title.length <10) {
        [self.birthYearLabel setTitle:@"Set Birthday" forState:UIControlStateNormal] ;
    } else {
        [self.birthYearLabel setTitle:title forState:UIControlStateNormal] ;
    }
    
    
    self.nameTextField.text = [user valueForKey:USERNAME];
    self.aboutMeTextField.text =[user valueForKey:USERABOUTME];
    
    if ([[user valueForKey:USERYEARSEARCH]integerValue] == 0)
    {
        [self.yearSwitchProp setOn:NO];
    }
    else
    {
        [self.yearSwitchProp setOn:YES];
    }
    
    PFFile *theImage = [[PFUser currentUser] objectForKey:USERPROFILEIMAGE];
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        
        profilePic=image;
        [self.imageButtonLabel setBackgroundImage:image forState:UIControlStateNormal];
        [self.imageButtonLabel setBackgroundImage:image forState:UIControlStateDisabled];
    }];
    
    [self.nameTextField setHidden:YES] ;
    [self.yearSwitchProp setHidden:YES];
    [self.updateInfoButton setHidden:YES];
    [self.deleteAccountButton setHidden:YES];
    [self.aboutMeTextField setEditable:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)uploadImage:(NSData *)imageData
{
    PFFile *imageFile = [PFFile fileWithName:@"ProfileImage.jpg" data:imageData];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hide old HUD, show completed HUD (see example for code)
            
            // Create a PFObject around a PFFile and associate it with the current user
            [[PFUser currentUser] setObject:imageFile forKey:USERPROFILEIMAGE];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    //[self refresh:nil];
                    [self viewDidLoad];
                }
                else{
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else
        {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender
{
    if (edit == 1)
    {
        [self.nameTextField setHidden:NO];
        [self.updateInfoButton setHidden:NO];
        [self.deleteAccountButton setHidden:NO];
        [self.aboutMeTextField setEditable:YES];
        [self.yearSwitchProp setHidden:NO];
        [self.birthYearLabel setHidden:YES];
        [self.birthLabelStatic setHidden:YES];
        [self.includeInSearchLabel  setHidden:NO];
        [self.imageButtonLabel setEnabled:YES];
        [self.nameLabel setHidden:YES];
        
        edit = 0;
    }
    else
    {
        [self viewDidLoad];
    }
}

- (IBAction)deleteButtonPressed:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete Profile" message:@"Are you sure that you want to delete your profile?\n CAUTION: This will delete all your Born Together information" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // NO = 0, YES = 1
    if(buttonIndex == 0)
    {
    }
    else
    {
        [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Deleted" message:@"Your account was successfully deleted" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alert show];
                 [self.navigationController popToRootViewControllerAnimated:YES];
             }
             else
             {
                 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error deleting your account, please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alert show];
             }
         }];
    }
}

- (IBAction)logoutButtonPressed:(UIButton *)sender
{
    [[PFFacebookUtils session] closeAndClearTokenInformation];
    [[PFFacebookUtils session] close];
    
    [PFTwitterUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
        if (!error && succeeded) {
            NSLog(@"The user is no longer associated with their Twitter account.");
        }
    }];
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[FBSession activeSession] close];
    [FBSession setActiveSession:nil];
    [PFUser logOut];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)imageButtonPressed:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take New Profile Picture", @"Upload New Profile Picture",nil];
    [actionSheet showInView:self.view];
}

- (IBAction)updateBirthday:(id)sender {
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"changeDate"]) {
        birthDateViewController *bvc = segue.destinationViewController;
        bvc.delegate = self;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSLog(@"Take");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else if(buttonIndex == 1)
    {
        NSLog(@"upload");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *profileImg = info[UIImagePickerControllerEditedImage];
    
    profilePic = profileImg;
    [self.imageButtonLabel setBackgroundImage:profileImg forState:UIControlStateDisabled];
    [self.imageButtonLabel setBackgroundImage:profileImg forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)updateInfoButtonPressed:(UIButton *)sender
{
    [self.loadingView setHidden:NO];
    [self.activityIndicatiorView setHidden:NO];
    
    PFUser *user= [PFUser currentUser];
    
    NSDictionary *userDictionary = (NSDictionary *)[user valueForKey:@"profile"];
    
    NSLog(@"Switch %@", self.yearSwitchProp);
    
    if (self.yearSwitchProp.on)
    {
        [[PFUser currentUser]setObject:@YES forKey:USERYEARSEARCH];
    }
    else
    {
        [[PFUser currentUser]setObject:@NO forKey:USERYEARSEARCH];
    }
    
    [[PFUser currentUser] setObject:self.nameTextField.text forKey:@"Alias"];
    [[PFUser currentUser] setObject:self.aboutMeTextField.text forKey:@"aboutMe"];
    [[PFUser currentUser] setObject:userDictionary forKey:@"profile"];
    [[PFUser currentUser] saveInBackground];
    
    NSData *imageData = UIImageJPEGRepresentation(profilePic, 0.05f);
    [self uploadImage:imageData];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        NSDictionary *info=[notification userInfo];
        CGSize keyboardSize=[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        f.origin.y = -keyboardSize.height;  //set the -35.0f to your required value


        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

- (void)tapToDismissKeyboard:(UITapGestureRecognizer *)recognizer {
    [self.nameTextField resignFirstResponder];
    [self.aboutMeTextField resignFirstResponder];
}

@end