//
//  NSString+SHA.h
//  CrashManager
//
//  Created by Carl Jahn on 03.04.12.
//
// Copyright 2012 Carl Jahn
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Note: You are NOT required to make the license available from within your
// iOS application. Including it in your project is sufficient.
//
// Attribution is not required, but appreciated :)
//

#import <Foundation/Foundation.h>

@interface NSString (SHA)

- (NSString *)sha1;
- (NSString *)sha224;
- (NSString *)sha256;
- (NSString *)sha384;
- (NSString *)sha512;


@end
