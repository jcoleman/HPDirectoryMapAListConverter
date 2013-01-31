#import <Foundation/Foundation.h>

@interface JCConversionIntermediateRecord : NSObject

@property (strong, nonatomic) NSString* household;
@property (strong, nonatomic) NSString* primary;
@property (strong, nonatomic) NSString* secondary;
@property (strong, nonatomic) NSString* address;

@end


@interface JCConvertedRecord : NSObject

@property (strong, nonatomic) NSString* household;
@property (strong, nonatomic) NSString* moreInformation;
@property (strong, nonatomic) NSString* address;

@end
