//
//  MSOContactHelper.h
//  office365Demo
//
//  Created by Vijay Subrahmanian on 08/04/15.
//  Copyright (c) 2015 Vijay Subrahmanian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MSOContactHelperDelegate <NSObject>

- (void)contactsFetchResponse:(NSArray *)iContacts andError:(NSError *)iError;

@end

@interface MSOContactHelper : NSObject

@property (nonatomic, weak) id <MSOContactHelperDelegate> delegate;

- (id)initWithADAuthToken:(NSString *)iToken andResourceID:(NSString *)iResourceID;
- (void)getContacts;
- (void)createContactWithDictionary:(NSDictionary *)iDictionary; // NOT TESTED
- (void)updateContactID:(int)contactID withData:(NSData *)data; // NOT TESTED
- (void)deleteContactID:(int)contactID; // NOT TESTED

@end
