/*
 * SQLHelper.h
 * SQLHelper
 * 
 * Created by Árpád Goretity on 25/12/2011.
 */

#import <sqlite3.h>
#import <Foundation/Foundation.h>


@interface SQLHelper: NSObject {
	sqlite3 *db;
}

/* The designated initializer */
- (id) initWithFile:(NSString *)name;

/* Metadata */
- (NSArray *) tables;
- (NSArray *) columnsInTable:(NSString *)table;

/* Simple query, this is the base method */
- (NSArray *) executeQuery:(NSString *)query;

/* Creation/deletion/adding - short-hands */
- (void) createTable:(NSString *)table withColumns:(NSArray *)columns;
- (void) deleteTable:(NSString *)table;
- (void) addRecord:(NSDictionary *)record toTable:(NSString *)table;

@end

