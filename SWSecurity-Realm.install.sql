-- noinspection SqlSignatureForFile @ routine/"sp_executesql"

if object_id('SWSecurity.RealmViewPolicy') is not null
	begin
		print '[Skipping] Realm Security is already installed.';
		print '[Skipping] To re-install first run view-security.uninstall.sql.';
		set noexec on;
	end;

begin transaction;
	if (select 1 from Sys.Schemas where [Name] = 'SWSecurity') is null
		create schema [SWSecurity];
go
	create security policy [SWSecurity].[RealmViewPolicy];
	create table [SWSecurity].[Realms] (
		[Id] uniqueidentifier not null
			constraint RealmPk primary key
			constraint RealmDfId default newid(),
		[Name] nvarchar(100) not null,
		[Client] nvarchar(50) not null,

		constraint RealmUqClientName unique([Client],[Name]),
	);
	create table [SWSecurity].[RealmTransactions] (
		[Id] uniqueidentifier not null
			constraint [RealmTransactionPk] primary key,
		[Realm] uniqueidentifier not null
			constraint [RealmTransactionRfRealm]
				references [SWSecurity].[Realms]([Id])
					on delete cascade
					on update cascade,
	);
	insert into [SWSecurity].[Realms] ([Id], [Name], [Client]) values
			('00000000-0000-0000-0000-000000000000', 'Unassigned', 'UA'),
			(newid(), 'Production', 'SWC');
go
	create procedure [SWSecurity].[CreateSecurityTransactionColumn] (
		@schema sysname, @table sysname, @column sysname = 'SecurityId'
	) as
		begin
			declare @sql nvarchar(max) =
				'alter table ' + quotename(@schema) + '.' + quotename(@table) +
				'	add ' + quotename(@column) + ' uniqueidentifier not null' +
				' 	constraint ' + quotename(@table + 'Uq' + @column) + ' unique' +
				' 	constraint ' + quotename(@table + 'Df' + @column) + ' default newid();';

			exec sp_executesql @sql;
		end;
go
	create procedure [SWSecurity].[AddToRealmViewPolicy] (
		@schema sysname, @table sysname, @column sysname
	) as
		begin
			declare @sql nvarchar(max) =
				'alter security policy [SWSecurity].[RealmViewPolicy]' +
				'  add filter predicate [SWSecurity].InRealmViewFilter(' + quotename(@column) + ')' +
				'  on ' + quotename(@schema) + '.' + quotename(@table);

			execute sp_executesql @sql;
		end;
go
	create procedure [SWSecurity].[CreateTriggerForRealmTransactionAfterInsert] (
		@schema sysname, @table sysname, @column sysname = 'SecurityId'
	) as
		begin
			declare @sql nvarchar(max) =
				'create trigger ' + quotename(@schema) + '.' + quotename(@table + 'AfterInsert') +
				'		on ' + quotename(@schema) + '.' + quotename(@table) + ' after insert as' +
				' 	begin' +
				'	 	execute sp_set_session_context ''SecurityTriggerRunning'', ''1'';' +
				' 		declare @realmId uniqueidentifier = [SWSecurity].[CurrentRealmId]();' +
				'' +
				' 		if (@realmId is null)' +
				'				set @realmId = ''00000000-0000-0000-0000-000000000000''' +
				' 		insert into [SWSecurity].[RealmTransactions] (Id, Realm)' +
				' 			select ' + quotename(@column) + ', @realmId from inserted;' +
				'	 	execute sp_set_session_context ''SecurityTriggerRunning'', null;' +
				' 	end;';

			exec sp_executesql @sql;
		end;
go
	create procedure [SWSecurity].[ApplyRealmSecurity] (
		@schema sysname, @table sysname, @column sysname = 'SecurityId'
	) as
		begin
			exec [SWSecurity].[CreateSecurityTransactionColumn] @schema, @table, @column;
			exec [SWSecurity].[CreateTriggerForRealmTransactionAfterInsert] @schema, @table, @column;
			exec [SWSecurity].[AddToRealmViewPolicy] @schema, @table, @column;
		end;
go
	create function [SWSecurity].[CurrentRealmId]()
	returns uniqueidentifier with schemabinding as
		begin
			return cast(session_context(N'RealmId') as uniqueidentifier);
		end;
go
	create function [SWSecurity].[InRealmView] (
		@id uniqueidentifier
	) returns bit with schemabinding as
		begin
			if @id is null
				return 0
			return cast((
				select count(*)
				from
					[SWSecurity].[RealmTransactions]
				where
					[Id] = @id and
					[Realm] = [SWSecurity].[CurrentRealmId]()
			) as bit);
		end;
go
	create function [SWSecurity].[InRealmViewFilter] (
		@id uniqueidentifier
	) returns table with schemabinding as
		return (
			select 1 as result
			where
				@id is null or
				[SWSecurity].[CurrentRealmId]() is null or
				cast(session_context(N'SecurityTriggerRunning') as nvarchar(1)) = '1' or
				[SWSecurity].[InRealmView] (@id) = 1
		);
go

commit;
set noexec off;
