#import <Foundation/Foundation.h>

@interface NSString (OFStringHelpers)

- (NSString*) stringByTrimmingWhitespace;
- (BOOL) isBlank;
- (BOOL) isPresent;

@end
