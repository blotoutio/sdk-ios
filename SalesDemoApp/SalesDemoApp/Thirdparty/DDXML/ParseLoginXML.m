//
//  ParseLoginXML.m
//  KronosMobile
//
//  Created by James Turner on 7/26/10.
//  Copyright 2010 Kronos Incorporated. All rights reserved.
//
// CHANGE HISTORY:


#import "ParseLoginXML.h"
#import "DDXML.h"



@implementation ParseLoginXML

//+(id) singleNodeForXPath:(id) node xpath:(NSString *) xpath missingOk:(BOOL) missingOk {
//	NSError *error = nil;
//	 NSArray *nodes = [node nodesForXPath:xpath error:&error];
//	if (error != nil) {
//		NSLog(@"Error looking for %@", xpath);
//		@throw [NSException exceptionWithName:@"XPATH_ERROR" reason:[error localizedFailureReason]
//                                     userInfo:error.userInfo];
//	}
//	if ((nodes == nil) || ([nodes count] != 1)) {
//		if (missingOk) {
//			return nil;
//		}
//		NSLog(@"Didn't find %@", xpath);
//		@throw [NSException exceptionWithName:@"XPATH_ERROR" reason:@"Didn't find element"
//                                     userInfo:nil];
//	}
//	
//	return [nodes objectAtIndex:0];
//		
//}
//
//+(NSArray *) nodesForXPath:(id) node xpath:(NSString *) xpath {
//	NSError *error = nil;
//	NSArray *nodes = [node nodesForXPath:xpath error:&error];
//	if (error != nil) {
//		NSLog(@"Error looking for %@", xpath);
//		@throw [NSException exceptionWithName:@"XPATH_ERROR" reason:[error localizedFailureReason]
//                                     userInfo:error.userInfo];
//	}
//	return nodes;
//}
//
//
//NSDate* dateFromISO8601(NSString* str) {
//	static NSDateFormatter* sISO8601 = nil;
//	NSString * choppedString = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
//	if (!sISO8601) {
//		sISO8601 = [[NSDateFormatter alloc] init];
//		[sISO8601 setTimeStyle:NSDateFormatterFullStyle];
//		[sISO8601 setDateFormat:@"yyyy-MM-dd'T'HHmmss.SSSZZZ"]; 
//	}
//	if ([str hasSuffix:@"Z"]) {
//		str = [[str substringToIndex:(choppedString.length-1)]
//			   stringByAppendingString:@"GMT"];
//	}
//	NSDate *date = [sISO8601 dateFromString:choppedString];
//	if (date == nil) {
//		[sISO8601 setDateFormat:@"yyyy-MM-dd'T'HHmmssZZZ"]; 
//		date = [sISO8601 dateFromString:choppedString];
//	}
//	
//	return date;
//}
//
//NSDate* dateFromISO8601StripTZ(NSString* str) {
//	NSDateFormatter* sISO8601StripTZ = nil;
//	NSString * choppedString = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
//	
//	if (!sISO8601StripTZ) {
//		sISO8601StripTZ = [[NSDateFormatter alloc] init];
//		[sISO8601StripTZ setTimeStyle:NSDateFormatterFullStyle];
//		[sISO8601StripTZ setDateFormat:@"yyyy-MM-dd'T'HHmmss.SSS"]; 
//	}
//	if ([choppedString hasSuffix:@"Z"]) {
//		choppedString = [choppedString substringToIndex:(choppedString.length-1)];
//	}
//	NSRange range = [choppedString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"+-"] options:NSCaseInsensitiveSearch
//                                                     range:NSMakeRange(10, ([choppedString length] - 10))];
//	if (range.location != NSNotFound) {
//		choppedString = [choppedString substringToIndex:(range.location)];
//	}
//	NSDate *date = [sISO8601StripTZ dateFromString:choppedString];
//	if (date == nil) {
//		[sISO8601StripTZ setDateFormat:@"yyyy-MM-dd'T'HHmmss"]; 
//		date = [sISO8601StripTZ dateFromString:choppedString];
//	}
//	return date;
//}
//
//
//NSNumber * boolIntFromString(NSString *str) {
//	if ([str isEqualToString:@"TRUE"]) {
//		return [[NSNumber numberWithInt:1] retain];
//	}
//	if ([str isEqualToString:@"true"]) {
//		return [[NSNumber numberWithInt:1] retain];
//	}
//	return [[NSNumber numberWithInt:0] retain];
//}
//
//Exception * readException(DDXMLDocument *node, TimecardRow * row) {
//	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
//	[f setNumberStyle:NSNumberFormatterDecimalStyle];
//    
//	Exception *exception = [NSEntityDescription insertNewObjectForEntityForName:@"Exception" inManagedObjectContext:OBJECT_CONTEXT];	
//	[exception setDurationOfException:getSingleEntityAttribute(node , @"./durationOfException", true)];
//	[exception setDurationPaycode:getSingleEntityAttribute(node , @"./durationPaycode", true)];
//	[exception setExceptionType:getSingleEntityAttribute(node , @"./exceptionType", true)];
//	[exception setExceptionTypeId:[f numberFromString:getSingleEntityAttribute(node , @"./exceptionTypeId", true)]];
//	[exception setId:[f numberFromString:getSingleEntityAttribute(node , @"./id", true)]];
//	[exception setMarkedSW:boolIntFromString(getSingleEntityAttribute(node , @"./markedSW", true))];
//	[exception setName:getSingleEntityAttribute(node , @"./name", true)];
//	[exception setUpdatedSW:boolIntFromString(getSingleEntityAttribute(node , @"./updatedSW", true))];
//	[exception setFromTimecardRow:row];
//	
//	return exception;
//}
//
//
//Punch * readPunch(DDXMLDocument *node, TimecardRow *row) {
//	Punch *punch = [NSEntityDescription insertNewObjectForEntityForName:@"Punch" inManagedObjectContext:OBJECT_CONTEXT];	
//	[punch setMarkedSW:boolIntFromString(getSingleEntityAttribute(node , @"./markedSW", true))];
//	[punch setTimeStr:getSingleEntityAttribute(node , @"./timeStr", true)];
//	[punch setType:getSingleEntityAttribute(node , @"./type", true)];
//	for (id ex in [ParseLoginXML nodesForXPath:node xpath:@"./exceptions/Exception"]) {
//		Exception * except = readException(ex, row);
//		except.fromPunch = punch;
//		[punch addExceptionListObject:except];
//	}
//	for (id comm in [ParseLoginXML nodesForXPath:node xpath:@"./comments/currentElements/CommentNoteInstance"]) {
//		Comment *comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:OBJECT_CONTEXT];
//		comment.commentId = getSingleEntityAttribute(comm , @"./commentId", false);
//		comment.id = getSingleEntityAttribute(comm , @"./id", true);
//		comment.notes = getSingleEntityAttribute(comm , @"./notes", true);
//		[punch addCommentsObject:comment];
//	}
//	
//	return punch;
//}
//
//XFer * readXfer(DDXMLDocument *node, TimecardRow *row) {
//	if ([getSingleEntityAttribute(node , @"./transferString", true) length] == 0) {
//		return nil;
//	}
//	XFer *xfer = [NSEntityDescription insertNewObjectForEntityForName:@"XFer" inManagedObjectContext:OBJECT_CONTEXT];	
//	xfer.transferString = getSingleEntityAttribute(node , @"./transferString", false);
//	xfer.trimPath = getSingleEntityAttribute(node , @"./trimPath", true);
//	xfer.type = getSingleEntityAttribute(node , @"./type", false);
//	xfer.workRuleId = getSingleEntityAttribute(node , @"./workRuleId", true);
//	xfer.laborAccountId = getSingleEntityAttribute(node , @"./laborAccountId", true);
//	xfer.orgJobId = getSingleEntityAttribute(node , @"./orgJobId", true);
//	
//	return xfer;
//}
//
//NSString * getSingleEntityAttribute( DDXMLNode *doc, NSString * xpath, BOOL emptyOk) {
//	NSError *error = nil;
//	NSArray *nodes = [doc nodesForXPath:xpath error:&error];
//	if (error != nil) {
//        NSLog(@"Looking for %@, got error", xpath);
//		@throw [NSException exceptionWithName:@"XPATH_ERROR" reason:[error description] userInfo:[error userInfo]];
//	}
//	if ([nodes count] != 1) {
//        if (!emptyOk) {
//            NSLog(@"Looking for %@, not found", xpath);
//            @throw [NSException exceptionWithName:@"XPATH_ERROR" reason:@"No nodes found" 
//                                     userInfo:nil];
//        } else {
//            return @"";
//        }
//	}
//    NSString *string = [[[nodes objectAtIndex:0] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    if (!emptyOk) {
//        if ((string == nil) || ([string length] == 0)) {
//            NSLog(@"Excepted value for %@ not found", xpath);
//            @throw [NSException exceptionWithName:@"BADXML" reason:@"String nil or blank" userInfo:nil];
//        }
//    }
//	return [string retain];
//}
//
//void errorIfNilOrBlank(NSString * string) {
//    if ((string == nil) || ([string length] == 0)) {
//        @throw [NSException exceptionWithName:@"BADXML" reason:@"String nil or blank" userInfo:nil];
//    }
//}
//
//+(CurrentUserEntity *) parseLogin:(NSString *) loginString {
//	NSError *error = nil;
//	DDXMLDocument *ddDoc = [[DDXMLDocument alloc] initWithXMLString:loginString options:0 error:&error];
//	if (error != nil) {
//        @throw [NSException exceptionWithName:@"BADXML" reason:@"XML Did not Parse" userInfo:error.userInfo];
//	}
//	
//	currentUser.apiVersion = getSingleEntityAttribute(ddDoc , @"/Logon/@apiversion", false);
//	
//	NSString *timeout = getSingleEntityAttribute(ddDoc , @"/Logon/@timeout", false);
//	currentUser.applicationTimeout = [NSNumber numberWithInt:[timeout integerValue]];
//	
////	NSString *remember = getSingleEntityAttribute(ddDoc , @"/Logon/@rememberpassword");
////	if (remember == nil) {
////		return [[NSError alloc] initWithDomain:@"RESTApi" code:ERROR_BAD_XML userInfo:error.userInfo];
////	}
////	currentUser.rememberPassword = [[NSNumber numberWithBool:[remember isEqualToString:@"true"]] retain];
////	
////	NSString *usepin = getSingleEntityAttribute(ddDoc , @"/Logon/@usepin");
////	if (usepin == nil) {
////		return [[NSError alloc] initWithDomain:@"RESTApi" code:ERROR_BAD_XML userInfo:error.userInfo];
////	}
////	currentUser.allowPin = [[NSNumber numberWithBool:[usepin isEqualToString:@"true"]] retain];
//	
//	
//	NSString *ismanager = getSingleEntityAttribute(ddDoc , @"/Logon/@manager", false);
//    
//	currentUser.isManager = [[NSNumber numberWithBool:[ismanager isEqualToString:@"true"]] retain];
//	
//	currentUser.lastName = getSingleEntityAttribute(ddDoc , @"/Logon/@lastname", false);
//
//	
//	currentUser.firstName = getSingleEntityAttribute(ddDoc , @"/Logon/@firstname", true);
//
//	return currentUser;
//}
//
//+(void) parseModules:(NSString *) string {
//    NSError *error = nil;
//    DDXMLDocument *ddDoc = [[DDXMLDocument alloc] initWithXMLString:string options:0 error:&error];
//	if (error != nil) {
//        @throw [NSException exceptionWithName:@"BADXML" reason:@"XML Did not Parse" userInfo:error.userInfo];
//	}
//	[currentUser removeHomeScreenManagerItems:[currentUser homeScreenManagerItems]];
//	[currentUser removeHomeScreenUserItems:[currentUser homeScreenUserItems]];
//	error = nil;
//	NSArray *nodes = [ddDoc nodesForXPath:@"//Modules/Alerts/Alert" error:&error];
//	int usercount = 0;
//	for (id node in nodes) {
//        NSString * itemTag = getSingleEntityAttribute(node , @"./@id", false);
//        NSNumber * itemType = nil;
//        if ([itemTag isEqualToString:@"com.kronos.wfc.exceptions"]) {
//            itemType = [NSNumber numberWithInt:REVIEW_EXCEPTIONS];
//        }
//        if ([itemTag isEqualToString:@"com.kronos.wfc.timeoffrequest"]) {
//            itemType = [NSNumber numberWithInt:APPROVE_TIME_OFF_REQUESTS];
//        }
//        if ([itemTag isEqualToString:@"com.kronos.wfc.scheduleservice"]) {
//            itemType = [NSNumber numberWithInt:REVIEW_SCHEDULE_CHANGES];
//        }
//        if ([itemTag isEqualToString:@"com.kronos.wfc.timecard"]) {
//            itemType = [NSNumber numberWithInt:APPROVE_EMPLOYEE_TIMECARDS];
//        }
//        if ([itemTag isEqualToString:@"com.kronos.wfc.employees"]) {
//            itemType = [NSNumber numberWithInt:MY_EMPLOYEES];
//        }
//        if (itemType == nil) {
//            continue;
//        }
//		HomeScreenItem *item = [NSEntityDescription	insertNewObjectForEntityForName:@"HomeScreenItem" inManagedObjectContext:OBJECT_CONTEXT];
//        [item setItemType:itemType];
//        NSString * itemId = getSingleEntityAttribute(node , @"./@id", false);
//		[item setItemTag:itemId];
//        NSString * itemName = getSingleEntityAttribute(node , @"./@name", false);
//		[item setItemLabelText:itemName];
//        NSString * itemtype = getSingleEntityAttribute(node , @"./@type", false);
//		[item setItemForManager:[NSNumber numberWithBool:[itemtype isEqualToString:@"mgr"]]];
//        NSString * itemCount = getSingleEntityAttribute(node , @"./@count", false);
//		[item setNGUIInstanceID:getSingleEntityAttribute(node , @"./@widgetInstanceId", false)];
//		[item setItemCount:[NSNumber numberWithInt:[itemCount intValue]]];
//   	    [item setItemDisplayOrder:[NSNumber numberWithInt:usercount++]];
//		if ([item.itemForManager intValue] == 0) {
//			[currentUser addHomeScreenUserItemsObject:item];
//		} else {
//			[currentUser addHomeScreenManagerItemsObject:item];
//		}
//	}
//	nodes = [ddDoc nodesForXPath:@"//Modules/Components/Component" error:&error];
//	usercount = 0;
//	for (id node in nodes) {
//        NSString * itemTag = getSingleEntityAttribute(node , @"./@id", false);
//        NSNumber * itemType = nil;
//        if ([itemTag isEqualToString:@"com.kronos.wfc.employeepunch"]) {
//            itemType = [NSNumber numberWithInt:PUNCH_FROM_PHONE];
//        }
//        if ([itemTag isEqualToString:@"com.kronos.wfc.requestopenshift"]) {
//            itemType = [NSNumber numberWithInt:REQUEST_OPEN_SHIFT];
//        }
//        if (itemType == nil) {
//            continue;
//        }
//		HomeScreenItem *item = [NSEntityDescription	insertNewObjectForEntityForName:@"HomeScreenItem" inManagedObjectContext:OBJECT_CONTEXT];
//        [item setItemType:itemType];
//        NSString * itemId = getSingleEntityAttribute(node , @"./@id", false);
//		[item setItemTag:itemId];
//        NSString * itemName = getSingleEntityAttribute(node , @"./@name", false);
//		[item setItemLabelText:itemName];
//		[item setNGUIInstanceID:getSingleEntityAttribute(node , @"./@widgetInstanceId", false)];
//
//        NSString * itemtype = getSingleEntityAttribute(node , @"./@type", false);
//		[item setItemForManager:[NSNumber numberWithBool:[itemtype isEqualToString:@"mgr"]]];
//        NSString * itemCount = getSingleEntityAttribute(node , @"./@count", false);
//		[item setItemCount:[NSNumber numberWithInt:[itemCount intValue]]];
//   	    [item setItemDisplayOrder:[NSNumber numberWithInt:usercount++]];
//		if ([item.itemForManager intValue] == 0) {
//			[currentUser addHomeScreenUserItemsObject:item];
//		} else {
//			[currentUser addHomeScreenManagerItemsObject:item];
//		}
//	}
//	
//
//}
//
//PayCode * readPaycode (id node) {
//	PayCode * paycode = [NSEntityDescription insertNewObjectForEntityForName:@"PayCode" inManagedObjectContext:OBJECT_CONTEXT];
//
//	paycode.paycodeDescription = getSingleEntityAttribute(node , @"./description", true);
//	paycode.id = [DECIMAL_FORMATTER numberFromString:getSingleEntityAttribute(node , @"./id", false)];
//	paycode.name = getSingleEntityAttribute(node , @"./name", false);
//	paycode.type = getSingleEntityAttribute(node , @"./type", false);
//	paycode.unit = getSingleEntityAttribute(node , @"./unit", false);
//
//	return paycode;
//}
//Total * readTotal(id node) {
//	Total * total = [NSEntityDescription insertNewObjectForEntityForName:@"Total" inManagedObjectContext:OBJECT_CONTEXT];
//	
//	total.account = getSingleEntityAttribute(node , @"./account", false);
//	total.job = getSingleEntityAttribute(node , @"./job", true);
//	NSString *days = getSingleEntityAttribute(node , @"./days", true);
//	if ((days != nil) && ([days length] > 0)) {
//		total.days = [DECIMAL_FORMATTER numberFromString:days];
//	}
//
//	NSString *hours = getSingleEntityAttribute(node , @"./hours", true);
//	if ((hours != nil) && ([hours length] > 0)) {
//		total.hours = [DECIMAL_FORMATTER numberFromString:hours];
//	}
//
//	NSString *wages = getSingleEntityAttribute(node , @"./wages", true);
//	if ((wages != nil) && ([wages length] > 0)) {
//		total.wages = [DECIMAL_FORMATTER numberFromString:wages];
//	}
//	
//	NSError *error = nil;
//	NSArray *paycodes = [node nodesForXPath:@"./payCode" error:&error];
//	if ((paycodes != nil) && ([paycodes count] == 1)) {
//		total.paycode = readPaycode([paycodes objectAtIndex:0]);
//	}
//	
//	total.homeAcct = boolIntFromString(getSingleEntityAttribute(node , @"./homeAcct", false));
//	total.deleted = boolIntFromString(getSingleEntityAttribute(node , @"./deleted", false));
//	total.location = getSingleEntityAttribute(node , @"./location", true);
//	total.modified = boolIntFromString(getSingleEntityAttribute(node , @"./modified", true));
//	total.unapprovedOT = boolIntFromString(getSingleEntityAttribute(node , @"./unapprovedOT", true));
//	
//	return total;
//}
//
//+(Timecard *) parseTimecard:(NSString *) string {
//    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
//	[f setNumberStyle:NSNumberFormatterDecimalStyle];
//	Timecard *tc;
//    @try {
//        NSError *error = nil;
//        DDXMLDocument *ddDoc = [[DDXMLDocument alloc] initWithXMLString:string options:0 error:&error];
//        if (error != nil) {
//            NSError *error =  [[NSError alloc] initWithDomain:@"RESTApi" code:ERROR_BAD_XML userInfo:error.userInfo];
//            @throw error;
//        }
//        
//        NSArray *nodes = [ddDoc nodesForXPath:@"//Timecard" error:&error];
//		if ((nodes == nil) || ([nodes count] != 1)) {
//            NSError *error =  [[NSError alloc] initWithDomain:@"RESTApi" code:ERROR_BAD_XML userInfo:nil];
//            @throw error;
//		}
//		id node = [nodes objectAtIndex:0];	
//         tc = [NSEntityDescription insertNewObjectForEntityForName:@"Timecard" inManagedObjectContext:OBJECT_CONTEXT];
//            NSString *fullname = getSingleEntityAttribute(node , @"./fullName", false);
//            [tc setFullName:fullname];
//            
//            NSString *personId = getSingleEntityAttribute(node , @"./personId", false);
//            [tc setPersonId:personId];
//            
//            NSString * periodStart = getSingleEntityAttribute(node , @"./beginTimeframeUTC", false);
//            NSDate * tcTime = [dateFromISO8601(periodStart) retain];
//            [tc setPayPeriodStart:tcTime];
//            
//            NSString * periodEnd = getSingleEntityAttribute(node , @"./endTimeframeUTC", false);
//            tcTime = [dateFromISO8601(periodEnd) retain];
//            [tc setPayPeriodEnd:tcTime];
//            
//            NSString *lastChangeTime = getSingleEntityAttribute(node , @"./lastChangeTimeUTC", false);
//            [tc setLastChangeTime:lastChangeTime];
//            
//            for (id dayNode in [node nodesForXPath:@"./daysWithExceptionsUTC/dateTime" error:&error]) {
//                DayWithException *dayException = [NSEntityDescription insertNewObjectForEntityForName:@"DayWithException" inManagedObjectContext:OBJECT_CONTEXT];
//                NSDate * exTime = [dateFromISO8601([dayNode stringValue]) retain];
//                [dayException setDateTime:exTime];
//                [tc addDaysWithExceptionsObject:dayException];
//            }
//            
//            for (id rowNode in [node nodesForXPath:@"./timecardRows/TimecardRow" error:&error]) {
//                TimecardRow *row = [NSEntityDescription insertNewObjectForEntityForName:@"TimecardRow" inManagedObjectContext:OBJECT_CONTEXT];
//                NSString *cumTotalString = getSingleEntityAttribute(rowNode , @"./cumulativeTotal", false);
//                [row setCumulativeTotal:[f numberFromString:cumTotalString]];
//                [row setDailyTotal:[f numberFromString:getSingleEntityAttribute(rowNode , @"./dailyTotal", false)]];
//                NSString * tcTimeString = getSingleEntityAttribute(rowNode , @"./dateUTC", true);
//                NSDate * tcTime = [dateFromISO8601(tcTimeString) retain];
//                [row setDate:tcTime];
//                [row setDateStr:getSingleEntityAttribute(rowNode , @"./dateStr", false)];
//                [row setSchedulePatternName:getSingleEntityAttribute(rowNode , @"./schedulePatternName", true)];
//                [row setEditable:boolIntFromString(getSingleEntityAttribute(rowNode , @"./editable", false))];
//                [row setEmpApproved:boolIntFromString(getSingleEntityAttribute(rowNode , @"./empApproved", false))];
//                [row setHasExceptions:boolIntFromString(getSingleEntityAttribute(rowNode , @"./hasExceptions", false))];
//                [row setMgrApproved:boolIntFromString(getSingleEntityAttribute(rowNode , @"./mgrApproved", false))];
//                [row setRowIndex:[f numberFromString:getSingleEntityAttribute(rowNode , @"./rowIndex", false)]];
//                [row setSchedulePatternName:getSingleEntityAttribute(rowNode , @"./schedulePatternName", true)];
//                [row setScheduledTotal:[f numberFromString:getSingleEntityAttribute(rowNode , @"./scheduledTotal", false)]];
//                [row setShiftName:getSingleEntityAttribute(rowNode , @"./shiftName", true)];
//                [row setShiftTotal:[f numberFromString:getSingleEntityAttribute(rowNode , @"./shiftTotal", false)]];
//                [tc addTimecardRowsObject:row];
//                [row setTimecard:tc];
//                for (id exceptionNode in [rowNode nodesForXPath:@"./exceptions/Exception" error:&error]) {
//                    [row addExceptionListObject:readException(exceptionNode, row)];
//                }
//                for (id s in [rowNode nodesForXPath:@"./shifts/ShiftAssignment" error:&error]) {
//                    ShiftAssignment *shift = [NSEntityDescription insertNewObjectForEntityForName:@"ShiftAssignment" inManagedObjectContext:OBJECT_CONTEXT];
//                    [shift setName:getSingleEntityAttribute(s, @"./name", true)];
//                    [shift setShiftDescription:getSingleEntityAttribute(s, @"./description", true)];
//                    [shift setEffPatternId:getSingleEntityAttribute(s, @"./effPatternId", true)];
//                    [shift setEndDateTime:[dateFromISO8601StripTZ(getSingleEntityAttribute(s, @"./endDateTimeUTC", false)) retain]];
//                    [shift setStartDateTime:[dateFromISO8601StripTZ(getSingleEntityAttribute(s, @"./startDateTimeUTC", false)) retain]];
//                    [shift setShiftDate:[dateFromISO8601(getSingleEntityAttribute(s, @"./shiftDateUTC", false)) retain]];
//                    [shift setShiftStr:getSingleEntityAttribute(s, @"./shiftStr", false)];
//                    [shift setShiftCodeId:[f numberFromString:getSingleEntityAttribute(s, @"./shiftCodeId", true)]];
//                    [shift setShiftAssignmentId:[f numberFromString:getSingleEntityAttribute(s, @"./shiftAssignmentId", true)]];
//                    [shift setPatternName:getSingleEntityAttribute(s, @"./patternName", true)];
//                    [shift setIsTransfer:boolIntFromString(getSingleEntityAttribute(s , @"./isTransfer", true))];
//                    [shift setTotal:[f numberFromString:getSingleEntityAttribute(s, @"./total", true)]];
//                    [row addHasShiftsObject:shift];
//                }
//				for (id t in [rowNode nodesForXPath:@"./totals/Total" error:&error]) {
//					Total *total = readTotal(t);
//					[row addTotalsObject:total];
//				}
//                
//				NSArray *paycodeEdits = [rowNode nodesForXPath:@"./paycodeEdit" error:&error];
//				if ((paycodeEdits != nil) && ([paycodeEdits count] == 1)) {
//					id paycodeEdit = [paycodeEdits objectAtIndex:0];
//					NSArray *paycode = [paycodeEdit nodesForXPath:@"./paycode" error:&error];
//					if ((paycode != nil) && ([paycode count] == 1)) {
//						PaycodeEdit *pe = [NSEntityDescription insertNewObjectForEntityForName:@"PaycodeEdit" inManagedObjectContext:OBJECT_CONTEXT];
//						pe.payCode = readPaycode([paycode objectAtIndex:0]);
//						pe.amount = getSingleEntityAttribute(paycodeEdit, @"./amount", true);
//						pe.applyDate = [dateFromISO8601(getSingleEntityAttribute(paycodeEdit, @"./applyDateUTC", false)) retain];
//						for (id exceptionNode in [paycodeEdit nodesForXPath:@"./exceptions/Exception" error:&error]) {
//							[pe addExceptionsListObject:readException(exceptionNode, row)];
//						}
//						[row setPaycodeEdit:pe];
//					}
//				}
//                NSArray *punchNodes = [rowNode nodesForXPath:@"./firstInPunch" error:&error];
//                if ([punchNodes count] == 1) {
//                    [row setFirstInPunch:readPunch([punchNodes objectAtIndex:0], row)];
//                }
//                punchNodes = [rowNode nodesForXPath:@"./firstOutPunch" error:&error];
//                if ([punchNodes count] == 1) {
//                    [row setFirstOutPunch:readPunch([punchNodes objectAtIndex:0], row)];
//                }
//                punchNodes = [rowNode nodesForXPath:@"./firstXfer" error:&error];
//                if ([punchNodes count] == 1) {
//                    [row setFirstXfer:readXfer([punchNodes objectAtIndex:0], row)];
//                }
//				
//                punchNodes = [rowNode nodesForXPath:@"./secondInPunch" error:&error];
//                if ([punchNodes count] == 1) {
//                    [row setSecondInPunch:readPunch([punchNodes objectAtIndex:0], row)];
//                }
//                punchNodes = [rowNode nodesForXPath:@"./secondOutPunch" error:&error];
//                if ([punchNodes count] == 1) {
//                    [row setSecondOutPunch:readPunch([punchNodes objectAtIndex:0], row)];
//                }
//                punchNodes = [rowNode nodesForXPath:@"./secondXfer" error:&error];
//                if ([punchNodes count] == 1) {
//                    [row setSecondXfer:readXfer([punchNodes objectAtIndex:0], row)];
//                }
//            }
//    }
//    @finally {
//        [f release];
//    }
//    return tc;
//}
//
//+(void) parseSaveExceptionResponse:(NSString *) string {
//    
//    NSError *error = nil;
//	DDXMLDocument *ddDoc = [[DDXMLDocument alloc] initWithXMLString:string options:0 error:&error];
//	if (error != nil) {
//        NSException *ex = [NSException exceptionWithName:@"XML_PARSE_ERROR" reason:@"Error parsing XML" userInfo:error.userInfo];
//        @throw ex;
//    }
//	NSArray *nodes = [ddDoc nodesForXPath:@"//Timecard" error:&error];
//	if ([nodes count] != 1) {
//        NSException *ex = [NSException exceptionWithName:@"XML_PARSE_ERROR" reason:@"Error parsing XML" userInfo:nil];
//        @throw ex;
//	}
//    DDXMLNode *node = [nodes objectAtIndex:0];
//    NSString * errorMsg = getSingleEntityAttribute(node, @"./BusinessException", true);
//    if ((errorMsg != nil) && ([errorMsg  length] > 0)) {
//		NSException *ex = [NSException exceptionWithName:@"WFC_FAILURE" reason:errorMsg userInfo:nil];
//        @throw ex;
//	}
//}
//
//+(void) parseGetConfiguration:(NSString *) string {
//    NSError *error = nil;
//    DDXMLDocument *ddDoc = [[DDXMLDocument alloc] initWithXMLString:string options:0 error:&error];
//    if (error != nil) {
//        NSException *ex = [NSException exceptionWithName:@"XML_PARSE_ERROR" reason:@"Error parsing XML" userInfo:error.userInfo];
//        @throw ex;
//    }
//    [currentUser removeComments:[currentUser comments]];
//    NSArray *nodes = [ddDoc nodesForXPath:@"//Configuration/Comments/Comment" error:&error];
//    for (id node in nodes) {
//        ConfiguredComment *comment = [NSEntityDescription	insertNewObjectForEntityForName:@"ConfiguredComment" inManagedObjectContext:OBJECT_CONTEXT];
//        [comment setCommentId:getSingleEntityAttribute(node , @"./CommentId", false)];
//        [comment setCommentText:getSingleEntityAttribute(node , @"./CommentText", false)];
//        [currentUser addCommentsObject:comment];
//    }
//}
//
//+(void) parsePunchResponse:(NSString *) string {
//	NSError *error = nil;
//    DDXMLDocument *ddDoc = [[DDXMLDocument alloc] initWithXMLString:string options:0 error:&error];
//    if (error != nil) {
//        NSException *ex = [NSException exceptionWithName:@"XML_PARSE_ERROR" reason:@"Error parsing XML" userInfo:error.userInfo];
//        @throw ex;
//    }
//    [currentUser removeComments:[currentUser comments]];
//    NSArray *nodes = [ddDoc nodesForXPath:@"//SimplePunchResponse" error:&error];
//	if ((nodes == nil) || ([nodes count] != 1)) {
//		NSException *ex = [NSException exceptionWithName:@"XML_PARSE_ERROR" reason:@"Error parsing XML" userInfo:nil];
//        @throw ex;
//	}
//	id node = [nodes objectAtIndex:0];
//	NSString *success = getSingleEntityAttribute(node , @"./succeeded", false);
//	if	([success compare:@"false"] == NSOrderedSame) {
//		nodes = [ddDoc nodesForXPath:@"//SimplePunchResponse/exception" error:&error];
//		if ((nodes == nil) || ([nodes count] != 1)) {
//			NSException *ex = [NSException exceptionWithName:@"SERVER_ERROR" reason:nil userInfo:nil];
//			@throw ex;
//		} else {
//			node = [nodes objectAtIndex:0];
//			NSException *ex = [NSException exceptionWithName:@"PUNCH_ERROR" reason:getSingleEntityAttribute(node , @"./reason", false) userInfo:nil];
//			@throw ex;
//		}
//	}
//	return;
//}
//
//
//
//+(NSArray *) parseExceptionBuckets:(NSString *) string {
//	NSMutableArray *array = [[[NSMutableArray alloc] init] retain];
//    NSError *error = nil;
//    DDXMLDocument *ddDoc = [[DDXMLDocument alloc] initWithXMLString:string options:0 error:&error];
//    if (error != nil) {
//        NSException *ex = [NSException exceptionWithName:@"XML_PARSE_ERROR" reason:@"Error parsing XML" userInfo:error.userInfo];
//        @throw ex;
//    }
//	NSArray *nodes = [ddDoc nodesForXPath:@"//exceptionsCounts" error:&error];
//    if (error != nil) {
//        NSException *ex = [NSException exceptionWithName:@"XML_PARSE_ERROR" reason:@"Error parsing XML" userInfo:error.userInfo];
//        @throw ex;
//    }
//	for (id node in nodes) {
//        UserExceptionsCount *count = [NSEntityDescription	insertNewObjectForEntityForName:@"UserExceptionsCount" inManagedObjectContext:OBJECT_CONTEXT];
//		[count setPersonId:getSingleEntityAttribute(node , @"./personId", false)];
//		[count setPersonName:getSingleEntityAttribute(node , @"./employeeName", false)];
//		NSArray *buckets = [node nodesForXPath:@".//exceptionsCount" error:&error];
//		if (error != nil) {
//			NSException *ex = [NSException exceptionWithName:@"XML_PARSE_ERROR" reason:@"Error parsing XML" userInfo:error.userInfo];
//			@throw ex;
//		}
//		for (id bucket in buckets) {
//			ExceptionBucketCount *bc = [NSEntityDescription	insertNewObjectForEntityForName:@"ExceptionBucketCount" inManagedObjectContext:OBJECT_CONTEXT];
//			[bc setName:getSingleEntityAttribute(bucket , @"./name", false)];
//			[bc setType:getSingleEntityAttribute(bucket , @"./type", false)];
//			[bc setCount:[NSNumber numberWithInt:[getSingleEntityAttribute(bucket , @"./count", false) intValue]]];
//			[count addHasBucketsObject:bc];
//		}
//		if ([[count hasBuckets] count] > 0) {
//			[array addObject:count];
//		}
////		[array addObject:[[[node stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] retain]];
//	}
//	
//	return array;
//}
//
//+(NSArray *) parseGenie:(NSString *) string {
//	NSMutableArray *array = [[[NSMutableArray alloc] init] retain];
//    NSError *error = nil;
//    DDXMLDocument *ddDoc = [[DDXMLDocument alloc] initWithXMLString:string options:0 error:&error];
//    if (error != nil) {
//        NSException *ex = [NSException exceptionWithName:@"XML_PARSE_ERROR" reason:@"Error parsing XML" userInfo:error.userInfo];
//        @throw ex;
//    }
//	NSArray *nodes = [ddDoc nodesForXPath:@"//GenieDataRow" error:&error];
//    if (error != nil) {
//        NSException *ex = [NSException exceptionWithName:@"XML_PARSE_ERROR" reason:@"Error parsing XML" userInfo:error.userInfo];
//        @throw ex;
//    }
//	for (id node in nodes) {
//		NSMutableArray *values = [[[NSMutableArray alloc] init] retain];
//		[array addObject:values];
//		NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]retain];
//		[dict setValue:getSingleEntityAttribute(node , @"./employeeId", false) forKey:@"value"];
//		[dict setValue:@"personId" forKey:@"name"];
//		[values addObject:dict];
//
//		NSArray *valueNodes = [node nodesForXPath:@".//GenieDataRowValue" error:&error];
//		if (error != nil) {
//			NSException *ex = [NSException exceptionWithName:@"XML_PARSE_ERROR" reason:@"Error parsing XML" userInfo:error.userInfo];
//			@throw ex;
//		}
//		for (id val in valueNodes) {
//			dict = [[[NSMutableDictionary alloc]init]retain];
//			[dict setValue:getSingleEntityAttribute(val , @"./name", false) forKey:@"name"];
//			[dict setValue:getSingleEntityAttribute(val , @"./value", false) forKey:@"value"];
//			[values addObject:dict];
//		}
//	}
//	
//	return array;
//}

@end
