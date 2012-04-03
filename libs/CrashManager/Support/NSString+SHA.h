//
//  NSString+SHA.h
//  CrashManager
//
//  Created by Carl Jahn on 03.04.12.
//  Copyright (c) 2012 NIDAG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SHA)

- (NSString *)sha1;
- (NSString *)sha224;
- (NSString *)sha256;
- (NSString *)sha384;
- (NSString *)sha512;


@end
