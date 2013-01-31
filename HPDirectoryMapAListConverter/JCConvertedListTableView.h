#import <Cocoa/Cocoa.h>

@interface JCConvertedListTableView : NSTableView <NSTableViewDataSource>

- (void) updateTableFrom:(NSArray*)rows;

@end
