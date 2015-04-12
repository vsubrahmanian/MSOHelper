//
//  MSOContactHelper.m
//  office365Demo
//
//  Created by Vijay Subrahmanian on 08/04/15.
//  Copyright (c) 2015 Vijay Subrahmanian. All rights reserved.
//

#import "MSOContactHelper.h"
#import <office365_odata_base/office365_odata_base.h>
#import <office365-lists-sdk/OAuthentication.h>
#import <office365-lists-sdk/HttpConnection.h>
#import "MSOContactInfoModel.h"

@interface MSOContactHelper()

@property (nonatomic, strong) OAuthentication *authCredentials;
@property (nonatomic, strong) NSString *resourceID;

@end


@implementation MSOContactHelper

- (id)initWithADAuthToken:(NSString *)iToken andResourceID:(NSString *)iResourceID {

    NSAssert(iToken.length, @"Invalid Token");
    NSAssert(iResourceID.length, @"Invalid Resource ID");
    
    self = [super init];
    
    if (self) {
        OAuthentication *anAuthCredentials = [[OAuthentication alloc] initWith:iToken];
        self.authCredentials = anAuthCredentials;
        self.resourceID = iResourceID;
    }
    return self;
}

- (void)getContacts {
    NSString *url = [NSString stringWithFormat:@"%@/sites/portal/_api/lists/GetByTitle('%@')/Items", self.resourceID, [@"Contacts" urlencode]];
    HttpConnection *connection = [[HttpConnection alloc] initWithCredentials:self.authCredentials url:url];
    __block NSArray *aContactList = nil;
    
    [[connection execute:@"GET" callback:^(NSData *data, NSURLResponse *response, NSError *error) {
         aContactList = [self handleResponse:data withResponse:response andError:error];
        NSArray *array = [self createContactObjectsWithArray:aContactList];
        
        if ([self.delegate respondsToSelector:@selector(contactsFetchResponse:andError:)]) {
            [self.delegate contactsFetchResponse:array andError:error];
        }
    }] resume];
}

- (NSArray *)createContactObjectsWithArray:(NSArray *)iArray {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"contactRelation" ofType:@"plist"];
    NSDictionary *aContactRelationDictionary = (NSDictionary *)[[NSDictionary dictionaryWithContentsOfFile:filePath] valueForKey:@"contactFields"];

    NSMutableArray *aNewContactArray = [[NSMutableArray alloc] init];
    for (NSDictionary *aContactData in iArray) {
        MSOContactInfoModel *aContact = [[MSOContactInfoModel alloc] init];

        for (NSDictionary *aContactRelation in [aContactRelationDictionary allValues]) {
            NSString *identifierKey = [aContactRelation valueForKey:@"identifier"];
            NSString *variableKey = [aContactRelation valueForKey:@"key"];
            
            [aContact setFieldValue:[aContactData valueForKeyPath:identifierKey] forKey:variableKey];
            aContact.ID = [aContactData valueForKeyPath:@"ID"];
        }
        [aNewContactArray addObject:aContact];
    }
    return aNewContactArray;
}

- (void)createContactWithDictionary:(NSDictionary *)iDictionary {
    NSError *anError;
    NSData *aContactData = [NSJSONSerialization dataWithJSONObject:iDictionary options:0 error:&anError];

    if (anError) {
        NSLog(@"Error: %@", anError.localizedDescription);
    } else {
        [self createContact:aContactData];
    }
}
    
- (void)createContact:(NSData *)iData {
    NSString *url = [NSString stringWithFormat:@"%@/sites/portal/_api/lists/GetByTitle('%@')/Items", self.resourceID, [@"Contacts" urlencode]];
    HttpConnection *connection = [[HttpConnection alloc] initWithCredentials:self.authCredentials url:url bodyArray:iData];
    
    [[connection execute:@"POST" callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleResponse:data withResponse:response andError:error];
    }] resume];
}

- (void)updateContactID:(int)iContactID withDictionary:(NSDictionary *)iDictionary {
    NSError *anError;
    NSData *aContactData = [NSJSONSerialization dataWithJSONObject:iDictionary options:0 error:&anError];
    
    if (anError) {
        NSLog(@"Error: %@", anError.localizedDescription);
    } else {
        [self updateContactID:iContactID withData:aContactData];
    }
}

- (void)updateContactID:(int)iContactID withData:(NSData *)iData {
    NSString *url = [NSString stringWithFormat:@"%@/sites/portal/_api/lists/GetByTitle('%@')/Items(%d)", self.resourceID, [@"Contacts" urlencode], iContactID];
    HttpConnection *connection = [[HttpConnection alloc] initWithCredentials:self.authCredentials url:url bodyArray:iData];
    
    [[connection execute:@"MERGE" callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleResponse:data withResponse:response andError:error];
    }] resume];
}

- (void)deleteContactID:(int)iContactID {
    NSString *url = [NSString stringWithFormat:@"%@/sites/portal/_api/lists/GetByTitle('%@')/Items(%d)", self.resourceID, [@"Contacts" urlencode], iContactID];
    HttpConnection *connection = [[HttpConnection alloc] initWithCredentials:self.authCredentials url:url];
    
    [[connection execute:@"DELETE" callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleResponse:data withResponse:response andError:error];
    }] resume];
}

- (NSArray *)handleResponse:(NSData *)iData withResponse:(NSURLResponse *)iResponse andError:(NSError *)iError {
    NSLog(@"Data: %@", [[NSString alloc] initWithData:iData encoding:NSUTF8StringEncoding]);
    NSLog(@"Response: %@", iResponse);
    if (iError) NSLog(@"Error: %@", iError);
    
    NSLog(@"\nParsed Response Data");
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableArray *listsItemsArray = [self parseDataArray:iData];
    for (NSDictionary* value in listsItemsArray) {
        [array addObject: value];
    }
    NSLog(@"Array: %@", array);
    
    return array;
}

#pragma mark - Utility methods

- (NSMutableArray *)parseDataArray:(NSData *)iData {
    
    NSMutableArray *array = [NSMutableArray array];
    NSError *error ;
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:[self sanitizeJson:iData]
                                                               options: NSJSONReadingMutableContainers
                                                                 error:&error];
    
    NSArray *jsonArray = [[jsonResult valueForKey:@"d"] valueForKey:@"results"];
    
    if (jsonArray != nil) {
        for (NSDictionary *value in jsonArray) {
            [array addObject:value];
        }
    } else {
        NSDictionary *jsonItem = [jsonResult valueForKey:@"d"];
        
        if(jsonItem != nil) {
            [array addObject:jsonItem];
        }
    }
    
    return array;
}

- (NSData *)sanitizeJson:(NSData *)iData {
    NSString *dataString= [[NSString alloc] initWithData:iData encoding:NSUTF8StringEncoding];
    NSString *replacedDataString = [dataString stringByReplacingOccurrencesOfString:@"E+308" withString:@"E+127"];
    NSData *bytes = [replacedDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    return bytes;
}

@end
