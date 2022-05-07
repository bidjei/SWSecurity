-- noinspection SqlSignatureForFile @ routine/"sp_set_session_context"

if object_id('SWSecurity.Realms', 'U') is null
	throw 50000 , 'Missing Dependency: SWSecurity.Realms', 0;

begin transaction;
	-- region [Assemble]
		create table [dbo].[Persons] (
			First nvarchar(120) not null,
			Last nvarchar(120) not null,
		);
		exec [SWSecurity].[ApplyRealmSecurity] 'dbo', 'Persons', default;
	-- endregion [Setup]
go
	-- region [Act]
		declare @Realm1 uniqueidentifier = newid();
		declare @Realm2 uniqueidentifier = newid();
		insert into [SWSecurity].[Realms] ([Id], [Name], [Client]) values (@Realm1, 'Realm T1', 'SWC');
		insert into [SWSecurity].[Realms] ([Id], [Name], [Client]) values (@Realm2, 'Realm T2', 'SWC');

		exec sp_set_session_context 'RealmId', @Realm1;
		insert into [dbo].[Persons] ([First], [Last]) values ('R1:F1', 'R1:L1'), ('R1:F2', 'R1:L2');

		exec sp_set_session_context 'RealmId', @Realm2;
		insert into [dbo].[Persons] ([First], [Last]) values ('R2:F1', 'R2:L1'), ('R2:F2', 'R2:L2');
	-- endregion [Run]
go
	-- region [Assert]
		declare @Realm1 uniqueidentifier = (select [Id] from [SWSecurity].[Realms] where [Name] = 'Realm T1');
		declare @Realm2 uniqueidentifier = (select [Id] from [SWSecurity].[Realms] where [Name] = 'Realm T2');
		declare @Count smallint;
		declare @Message varchar(120);

		exec sp_set_session_context 'RealmId', @Realm1;
		set @Count = (select count(*) from [dbo].[Persons]);
		if @Count <> 2
			begin
				set @Message = concat('FAILED: Ream 1|count: expected 2, got ', @Count);
				goto clean;
			end

		exec sp_set_session_context 'RealmId', @Realm2;
		set @Count = (select count(*) from [dbo].[Persons]);
		if @Count <> 2
			begin
				set @Message = concat('FAILED: Ream 2|count: expected 2, got ', @Count);
				goto clean;
			end

		exec sp_set_session_context 'RealmId', null;
		set @Count = (select count(*) from [dbo].[Persons]);
		if @Count <> 4
			begin
				set @Message = concat('FAILED: Admin-Mode|count: expected 4, got ', @Count);
				goto clean;
			end
	-- endregion [Assert]

	clean:
		alter security policy [SWSecurity].[RealmViewPolicy]
			drop filter predicate on [dbo].[Persons];
		drop table if exists [dbo].[Persons];
		delete from [SWSecurity].[Realms]
			where [Name] = 'Realm T1' or [Name] = 'Realm T2'

	result:
		if @Message is not null
			throw 60000, @Message, 0
go

commit;
