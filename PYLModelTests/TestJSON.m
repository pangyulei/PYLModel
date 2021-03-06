//
//  TestJSON.m
//  PYLModelTests
//
//  Created by yulei pang on 2019/1/31.
//  Copyright © 2019 pangyulei. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Book.h"
#import "Author.h"
#import "PYLModel+JSON.h"
#import <objc/runtime.h>

@interface TestJSON : XCTestCase
@end

@implementation TestJSON

- (NSDictionary *)bookJSON {
    NSDictionary *bookJSON = @{
                               @"salary":@30000,
                               @"sign":@('e'),
                               @"isSoldOut":@0,
                               @"isOkForKid":@"trUe",
                               @"id": @999999999999999999,
                               @"testShort": @([@2 shortValue]),
                               @"name":[NSNull null],
                               @"created_at": @190429809,
                               @"updated_at": @"2019-01-29",
                               @"previews":@[
                                       @"url1",
                                       @"url2"
                                       ],
                               @"authors": @[
                                       @{
                                           @"name":@"john",
                                           @"age":@27
                                           },
                                       @{
                                           @"name":@"jack",
                                           @"age":@"25"
                                           }
                                       ],
                               @"singleAuthor": @{
                                       @"name":@"smith",
                                       @"age":@30
                                       },
                               @"extraAuthDict":@{
                                       @"blacklist":@{
                                               @"name":@"lucy",
                                               @"age":@"18"
                                               }
                                       },
                               @"some":@"id value",
                               @"fatherClass": @"NSDictionary",
                               @"aSEL": @"someMethodName:",
                               @"ttt":@"变",
                               @"vvv":@"xxx"
                               };
    return bookJSON;
}

- (void)test_字典转模型 {
    Book *aBook = [[Book alloc] initWithJSON:[self bookJSON]];

    [self commonAssertBook:aBook];
    XCTAssert([aBook.fatherClass isSubclassOfClass:[NSDictionary class]]);
    XCTAssert([[NSString stringWithUTF8String:sel_getName(aBook.aSEL)] isEqualToString:@"someMethodName:"]);
}

- (void)test_测试归档解裆 {
    Book *a = [[Book alloc] initWithJSON:[self bookJSON]];
    NSError *e;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:a requiringSecureCoding:true error:&e];
    XCTAssert(data != nil);
    
    Book *aBook = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self commonAssertBook:aBook];
    XCTAssertNil(aBook.fatherClass); // Class 不支持归档解裆
    XCTAssert([@"<null selector>" isEqualToString:[NSString stringWithUTF8String:sel_getName(aBook.aSEL)]]); //SEL 不支持归档解裆
}

- (void)commonAssertBook:(Book *)aBook {
    [aBook setValue:@"asjoeijoae" forKey:@"key_not_exist"];
    
    XCTAssert(aBook.bookID == 999999999999999999);
    XCTAssert(aBook.testShort == 2);
    XCTAssert(sizeof(aBook.bookID) == sizeof(long long));
    XCTAssertNil(aBook.name);
    XCTAssert(aBook.created.timeIntervalSince1970 == 190429809);
    XCTAssert(aBook.updated.timeIntervalSince1970 == 1548691200);
    
    XCTAssert([aBook.salary isEqualToString:@"30000"]);
    XCTAssert([aBook.salary isKindOfClass:[NSString class]]);
    
    XCTAssert([aBook.extraAuthDict isMemberOfClass:objc_getClass("__NSDictionaryM")]);
    Author *author = aBook.extraAuthDict[@"blacklist"];
    XCTAssert([author isKindOfClass:[Author class]]);
    XCTAssert([author.name isEqualToString:@"lucy"]);
    XCTAssert(author.age == 18);
    
    XCTAssert(aBook.previews.count == 2);
    XCTAssert([aBook.previews[0] isKindOfClass:[NSString class]]);
    XCTAssert([aBook.previews isKindOfClass:[NSArray class]]);
    
    XCTAssert(aBook.authors.count == 2);
    XCTAssert([aBook.authors isMemberOfClass:objc_getClass("__NSArrayM")]);
    
    author = aBook.authors[0];
    XCTAssert([author isKindOfClass:[Author class]]);
    XCTAssert([author.name isEqualToString:@"john"]);
    XCTAssert(author.age == 27);
    
    author = aBook.single;
    XCTAssert([author.name isEqualToString:@"smith"]);
    XCTAssert(author.age == 30);
    
    author = aBook.authors[1];
    XCTAssert([author.name isEqualToString:@"jack"]);
    XCTAssert(author.age == 25);
    
    XCTAssert(aBook.isSoldOut == false);
    XCTAssert(aBook.isOkForKid == YES);
    XCTAssert(aBook.sign == 'e');
    XCTAssert([aBook.some isEqualToString:@"id value"]);
    
    XCTAssert([aBook.ttt isMemberOfClass:objc_getClass("__NSCFString")]);
    XCTAssert([aBook.ttt isEqualToString:@"变"]);
    XCTAssert([[aBook vvv] isEqualToString:@"xxx"]);
}

@end
