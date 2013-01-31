#import "JCMainView.h"
#import "JCConvertedListTableView.h"
#import "NSString+OFStringHelpers.h"
#import "JCRecord.h"

typedef enum JCRecordConversionState {
  JCRecordConversionStateScanningForNextRecord,
  JCRecordConversionStateReadingPrimary,
  JCRecordConversionStateReadingSecondary,
  JCRecordConversionStateReadingAddress
} JCRecordConversionState;

@interface JCMainView ()

@property (weak, nonatomic) IBOutlet NSButton* openButton;
@property (weak, nonatomic) IBOutlet NSButton* saveButton;
@property (weak, nonatomic) IBOutlet NSProgressIndicator* progressIndicator;
@property (weak, nonatomic) IBOutlet JCConvertedListTableView* previewTableView;

@property (strong, nonatomic) NSMutableArray* convertedRows;
@property (nonatomic) JCRecordConversionState currentState;
@property (nonatomic) NSUInteger currentCSVIndex;
@property (nonatomic) NSMutableArray* currentCSVRow;
@property (strong, nonatomic) JCConversionIntermediateRecord* currentRecord;

@property (strong, nonatomic) NSMutableArray* rowIndicesWithErrors;

@end

@implementation JCMainView

- (IBAction) openButtonClicked:(NSButton*)sender {
  NSOpenPanel* openPanel = [NSOpenPanel openPanel];
  openPanel.allowedFileTypes = @[@"csv"];
  openPanel.canChooseDirectories = NO;
  openPanel.canChooseFiles = YES;
  openPanel.allowsMultipleSelection = NO;
  openPanel.allowsOtherFileTypes = NO;
  NSInteger openPanelResult = [openPanel runModal];
  if (openPanelResult == NSOKButton) {
    [self processCSVFile:openPanel.URL.path];
  } else if (openPanelResult == NSCancelButton) {
    // Do nothing.
  } else {
    // Unexpected result...do nothing.
  }
}

- (IBAction) saveButtonClicked:(NSButton*)sender {
  NSSavePanel* savePanel = [NSSavePanel savePanel];
  savePanel.allowedFileTypes = @[@"csv"];
  savePanel.allowsOtherFileTypes = NO;
  NSInteger savePanelResult = [savePanel runModal];
  if (savePanelResult == NSOKButton) {
    [self saveCSVFile:savePanel.URL.path];
  } else if (savePanelResult == NSCancelButton) {
    // Do nothing.
  } else {
    // Unexpected result...do nothing.
  }
}


- (void) processCSVFile:(NSString*)filename {
  self.openButton.enabled = NO;
  self.saveButton.enabled = NO;
  [self.progressIndicator startAnimation:self];

  CHCSVParser* parser = [[CHCSVParser alloc] initWithContentsOfCSVFile:filename];
  parser.sanitizesFields = YES;
  parser.delegate = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [parser parse];
  });
}

- (void) updatePreviewTableView {
  NSArray* rows = self.convertedRows;
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.previewTableView updateTableFrom:rows];
  });
}

- (void) saveCSVFile:(NSString*)filename {
  CHCSVWriter* writer = [[CHCSVWriter alloc] initForWritingToCSVFile:filename];
  [writer writeField:@"Household"];
  [writer writeField:@"More Information"];
  [writer writeField:@"Address"];
  [writer finishLine];
  for (JCConvertedRecord* record in self.convertedRows) {
    [writer writeField:record.household];
    [writer writeField:record.moreInformation];
    [writer writeField:record.address];
    [writer finishLine];
  }
}


#pragma mark - Records Conversion

- (void) parseRow {
  NSMutableArray* row = self.currentCSVRow;
  if (!self.currentRecord) {
    self.currentRecord = [JCConversionIntermediateRecord new];
  }

  switch (self.currentState) {
    case JCRecordConversionStateScanningForNextRecord: {
      NSString* field = nil;
      if (row.count > 1 && [(field = [row objectAtIndex:1]) isPresent]) {
        self.currentRecord.household = field;
        self.currentState = JCRecordConversionStateReadingPrimary;
      }
      break;
    }
    case JCRecordConversionStateReadingPrimary: {
      if (row.count > 0) {
        self.currentRecord.primary = [row objectAtIndex:0];
      }
      self.currentState = JCRecordConversionStateReadingSecondary;
      break;
    }
    case JCRecordConversionStateReadingSecondary: {
      NSString* field = nil;
      if (row.count > 0 && [(field = [row objectAtIndex:0]) isPresent]) {
        if (self.currentRecord.secondary) {
          self.currentRecord.secondary = [NSString stringWithFormat:@"%@, %@", self.currentRecord.secondary, field];
        } else {
          self.currentRecord.secondary = field;
        }
      } else {
        self.currentState = JCRecordConversionStateReadingAddress;
        [self parseRow];
      }
      break;
    }
    case JCRecordConversionStateReadingAddress: {
      NSString* field = nil;
      if (row.count > 1 && [(field = [row objectAtIndex:1]) isPresent]) {
        if (self.currentRecord.address) {
          self.currentRecord.address = [NSString stringWithFormat:@"%@, %@", self.currentRecord.address, field];
        } else {
          self.currentRecord.address = field;
        }
      } else {
        JCConvertedRecord* convertedRecord = [JCConvertedRecord new];
        convertedRecord.household = self.currentRecord.household;
        if ([self.currentRecord.secondary isPresent]) {
          convertedRecord.moreInformation = [NSString stringWithFormat:@"%@ (%@)", self.currentRecord.primary, self.currentRecord.secondary];
        } else {
          convertedRecord.moreInformation = self.currentRecord.primary;
        }
        convertedRecord.address = self.currentRecord.address;
        [self.convertedRows addObject:convertedRecord];
        if (![self.currentRecord.address isPresent]) {
          [self.rowIndicesWithErrors addObject:@(self.currentCSVIndex + 1)];
        }
        self.currentRecord = nil;
        self.currentState = JCRecordConversionStateScanningForNextRecord;
      }
      break;
    }
  }
}



#pragma  mark - CHCSVParserDelegate Implementation

- (void) parserDidBeginDocument:(CHCSVParser*)parser {
  self.convertedRows = [NSMutableArray new];
  self.rowIndicesWithErrors = [NSMutableArray new];
  [self updatePreviewTableView];
  self.currentState = JCRecordConversionStateScanningForNextRecord;
}

- (void) parserDidEndDocument:(CHCSVParser*)parser {
  [self updatePreviewTableView];
  self.openButton.enabled = YES;
  self.saveButton.enabled = YES;
  [self.progressIndicator stopAnimation:self];

  if (self.rowIndicesWithErrors.count) {
    NSAlert* alert = [NSAlert alertWithMessageText:@"Formatting Error(s) Encountered"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"Directory CSV file contained formatting errors on rows: %@.\nNote: fix the first format error and try again. One error may cause subsequent errors to be reported unnecessarily.", [self.rowIndicesWithErrors componentsJoinedByString:@", "]];
    [alert runModal];
  }
}

- (void) parser:(CHCSVParser*)parser didBeginLine:(NSUInteger)recordNumber {
  self.currentCSVRow = [NSMutableArray new];
}

- (void) parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
  self.currentCSVIndex = recordNumber;
  [self parseRow];

  if (recordNumber % 15 == 0) {
    [self updatePreviewTableView];
  }
}

- (void) parser:(CHCSVParser*)parser didReadField:(NSString*)field atIndex:(NSInteger)fieldIndex {
  [self.currentCSVRow insertObject:field atIndex:fieldIndex];
}

- (void)parser:(CHCSVParser*)parser didFailWithError:(NSError*)error {
  // TODO: Display error dialog.
  NSAlert* alert = [NSAlert alertWithError:error];
  [alert runModal];
  self.openButton.enabled = YES;
  self.saveButton.enabled = NO;
  [self.progressIndicator stopAnimation:self];
  [self updatePreviewTableView];
}


@end
