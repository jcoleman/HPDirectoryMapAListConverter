#import "NSString+OFStringHelpers.h"

@implementation NSString (OFStringHelpers)

- (NSString*) stringByTrimmingWhitespace {
  return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL) isBlank {
  return self.length == 0 || [self stringByTrimmingWhitespace].length == 0;
}

- (BOOL) isPresent {
  return ![self isBlank];
}

@end
