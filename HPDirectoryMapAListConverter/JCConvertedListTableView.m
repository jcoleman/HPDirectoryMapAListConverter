#import "JCConvertedListTableView.h"
#import "JCRecord.h"

@interface JCConvertedListTableView ()

@property (strong, nonatomic) NSArray* rows;
@property (nonatomic) NSInteger rowCount;

@end

@implementation JCConvertedListTableView

- (id) initWithCoder:(NSCoder*)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.dataSource = self;
  }
  return self;
}

- (void) updateTableFrom:(NSArray*)rows {
  self.rows = rows;
  self.rowCount = rows.count;
  [self reloadData];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView*)tableView {
  return self.rowCount;
}

static NSString* const householdColumnIdentifier = @"HOUSEHOLD";
static NSString* const moreInformationColumnIdentifier = @"MORE-INFORMATION";
static NSString* const addressColumnIdentifier = @"ADDRESS";

- (id) tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)rowIndex {
  JCConvertedRecord* record = [self.rows objectAtIndex:rowIndex];
  if ([tableColumn.identifier isEqualToString:householdColumnIdentifier]) {
    return record.household;
  } else if ([tableColumn.identifier isEqualToString:moreInformationColumnIdentifier]) {
    return record.moreInformation;
  } else if ([tableColumn.identifier isEqualToString:addressColumnIdentifier]) {
    return record.address;
  } else {
    return nil;
  }
}

@end
