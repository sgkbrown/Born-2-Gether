//
//  ImprovedChatViewController.h
//  BornTogether
//
//  Created by Nutech Systems on 11/6/14.
//  Copyright (c) 2014 Stefan Brown. All rights reserved.
//

#import "JSQMessagesViewController.h"

@interface ImprovedChatViewController : JSQMessagesViewController

@property (strong, nonatomic) PFUser *matchedUser; //This is the user you are matched up with

@property (strong, nonatomic) UIImage *currentImage;
@property (weak, nonatomic) UIImage *matchedImage;

@end
