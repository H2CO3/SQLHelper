/*
 * SQLHelper.h
 * SQLEd
 *
 * Created by Árpád Goretity on 27/08/2012.
 * Licensed under the 3-clause BSD license
 */

#include <sqlite3.h>
#include <Foundation/Foundation.h>

@interface SQLHelper: NSObject {
        sqlite3 *db;
}

- (id)initWithContentsOfFile:(NSString *)file;
- (NSArray *)executeQuery:(NSString *)query;
- (NSArray *)tables;
- (NSArray *)columnsInTable:(NSString *)table;

@end

