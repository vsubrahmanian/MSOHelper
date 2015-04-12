//
//  MSOContactInfoModel.m
//  office365Demo
//
//  Created by Vijay Subrahmanian on 08/04/15.
//  Copyright (c) 2015 Vijay Subrahmanian. All rights reserved.
//

#import "MSOContactInfoModel.h"

@implementation MSOContactInfoModel

- (void)setFieldValue:(NSString *)iValue forKey:(NSString *)iKey {

    if ([self respondsToSelector:NSSelectorFromString(iKey)]) {
    
        if (![iValue isEqual:[NSNull null]]) {
            [self setValue:iValue forKey:iKey];
        }
    }
}

- (NSString *)valueForFieldKey:(NSString *)iKey {
    NSString *value = @"";
    
    if ([self respondsToSelector:NSSelectorFromString(iKey)]) {
        value = [self valueForKey:iKey];
    }
    return value;
}

- (NSString *)description {
    // Printing all Values in Description.
    return [NSString stringWithFormat:@"\nLast name: %@\nFirst name: %@\nFull name: %@\nEmail: %@\nCompany: %@\nJob Title: %@\nBusiness Ph: %@\nHome Ph: %@\nMob: %@\nFax: %@\nAddress: %@\nCity: %@\nState: %@\nZip: %@\nCountry: %@\nWeb URL: %@\nWeb Desc: %@\nNotes: %@\n", self.lastName, self.firstName, self.fullName, self.emailAddress, self.company, self.jobTitle, self.businesPhone, self.homePhone, self.mobileNumber, self.faxNumber, self.address, self.city, self.stateOrProvince, self.zipOrPostalCode, self.countryOrRegion, self.webpageURL, self.webpageDescription, self.notes];
}

@end
