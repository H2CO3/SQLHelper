/*
 * SQLHelper.m
 * SQLEd
 *
 * Created by Árpád Goretity on 27/08/2012.
 * Licensed under the 3-clause BSD license
 */

#include "SQLHelper.h"

@implementation SQLHelper

- (id)initWithContentsOfFile:(NSString *)file
{
        if ((self = [super init])) {
                if (sqlite3_open([file UTF8String], &db) != 0) {
                        [self release];
                        return nil;
                }
        }
        return self;
}

- (void)dealloc
{
        sqlite3_close(db);
        [super dealloc];
}

- (NSArray *)executeQuery:(NSString *)query
{
        sqlite3_stmt *stmt;
        const char *tail;
        sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt, &tail);
        if (stmt == NULL)
                return nil;

        int status;
        int num_cols;
        int i;
        int type;
        id obj;
        NSString *key;
        NSMutableArray *result;
        NSMutableDictionary *row;

        result = [NSMutableArray array];
        while ((status = sqlite3_step(stmt)) != SQLITE_DONE) {
                if (status != SQLITE_ROW)
                        continue;

                row = [NSMutableDictionary dictionary];
                num_cols = sqlite3_data_count(stmt);
                for (i = 0; i < num_cols; i++) {
                        obj = nil;
                        type = sqlite3_column_type(stmt, i);
                        switch (type) {
                        case SQLITE_INTEGER:
                                obj = [NSNumber numberWithLongLong:sqlite3_column_int64(stmt, i)];
                                break;
                        case SQLITE_FLOAT:
                                obj = [NSNumber numberWithDouble:sqlite3_column_double(stmt, i)];
                                break;
                        case SQLITE_TEXT:
                                obj = [NSString stringWithUTF8String:sqlite3_column_text(stmt, i)];
                                break;
                        case SQLITE_BLOB:
                                obj = [NSData dataWithBytes:sqlite3_column_blob(stmt, i)
                                	length:sqlite3_column_bytes(stmt, i)];
                                break;
                        case SQLITE_NULL:
                                obj = [NSNull null];
                                break;
                        default:
                                break;
                        }

                        key = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
                        [row setObject:obj forKey:key];
                }

                [result addObject:row];
        }

        sqlite3_finalize(stmt);
        return result;
}

- (NSArray *)tables
{
        NSArray *descs = [self executeQuery:@"SELECT tbl_name FROM sqlite_master WHERE type = 'table'"];
        NSMutableArray *result = [NSMutableArray array];
        for (NSDictionary *row in descs) {
                NSString *tblName = [row objectForKey:@"tbl_name"];
                [result addObject:tblName];
        }
        return result;
}

- (NSArray *)columnsInTable:(NSString *)table
{
        char *sql = sqlite3_mprintf("PRAGMA table_info(%q)", [table UTF8String]);
        NSString *query = [NSString stringWithUTF8String:sql];
        sqlite3_free(sql);
        return [self executeQuery:query];        
}

@end

