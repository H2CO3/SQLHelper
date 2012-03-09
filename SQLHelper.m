/*
 * SQLHelper.m
 * SQLHelper
 * 
 * Created by Árpád Goretity on 25/12/2011.
 */

#import "SQLHelper.h"

int sqlhelper_query_callback(void *ctx, int argc, char **argv, char **columns);

int sqlhelper_query_callback(void *ctx, int argc, char **argv, char **columns)
{
	NSMutableArray *ar = (NSMutableArray *)ctx;
	NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
	for (int i = 0; i < argc; i++)
	{
		NSString *column = [[NSString alloc] initWithUTF8String:columns[i]];
		NSString *data = [[NSString alloc] initWithFormat:@"%s", argv[i]];
		[row setObject:data forKey:column];
		[column release];
		[data release];
	}
	[ar addObject:row];
	[row release];

	return 0;
}


@implementation SQLHelper

/* The designated initializer */
- (id) initWithFile:(NSString *)name
{
	if ((self = [super init]))
	{
		const char *fname = [name UTF8String];
		sqlite3_open(fname, &db);
	}
	
	return self;
}

- (id) init
{
	/* Initializing without a filename does not make sense */
	[self release];
	return NULL;
}

- (void) dealloc
{
	sqlite3_close(db);
	[super dealloc];
}

/* Metadata */
- (NSArray *) tables
{
	NSMutableArray *result = [NSMutableArray array];
	NSArray *info = [self executeQuery:@"SELECT name FROM sqlite_master WHERE type='table'"];
	int count = [info count];
	for (int i = 0; i < count; i++)
	{
		[result addObject:[(NSDictionary *)[info objectAtIndex:i] objectForKey:@"name"]];
	}
	
	return result;
}

- (NSArray *) columnsInTable:(NSString *)table
{
	NSString *query = [[NSString alloc] initWithFormat:@"PRAGMA table_info(%@);", table];
	NSArray *result = [self executeQuery:query];
	[query release];
	return result;
}

/* Simple query, this is the base method */
- (NSArray *) executeQuery:(NSString *)query
{
	const char *q = [query UTF8String];
	NSMutableArray *result = [NSMutableArray array];
	sqlite3_exec(db, q, sqlhelper_query_callback, result, NULL);
	return result;
}

/* Creation/deletion/adding - short-hands */
- (void) createTable:(NSString *)table withColumns:(NSArray *)columns
{
	NSString *query = [[NSString alloc] initWithFormat:@"CREATE TABLE %@ (%@);", table, [columns componentsJoinedByString:@", "]];
	[self executeQuery:query];
	[query release];
}

- (void) deleteTable:(NSString *)table
{
	NSString *query = [[NSString alloc] initWithFormat:@"DROP TABLE %@;", table];
       [self executeQuery:query];
       [query release];
}

- (void) addRecord:(NSDictionary *)record toTable:(NSString *)table
{
	NSArray *keys = [record allKeys];
	NSMutableArray *values = [[NSMutableArray alloc] init];
	int count = [record count];
	for (int i = 0; i < count; i++)
	{
		[values addObject:[record objectForKey:[keys objectAtIndex:i]]];
	}
	NSString *query = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (%@) VALUES (%@);", table, [keys componentsJoinedByString:@", "], [values componentsJoinedByString:@", "]];
	[values release];
	[self executeQuery:query];
	[query release];
}

@end

