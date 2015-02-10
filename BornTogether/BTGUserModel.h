//
//  BTGUserModel.h
//  BornTogether
//
//  Created by Nutech Systems on 11/14/14.
//  Copyright (c) 2014 Stefan Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BTGUserModelDelegate <NSObject>

-(void)updatedUserList;

@end

@interface BTGUserModel : NSObject

@property (nonatomic, weak) id<BTGUserModelDelegate> delegate;

+(BTGUserModel *)bornTogetherUsers;
-(void)updateBirthdate;
//-(NSUInteger)countOfCurrentUsers;
-(PFUser *)userAtIndex:(unsigned long)index;
-(unsigned long)countOfTotalUsersThatMatchBirthdate;


@end
