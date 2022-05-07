if exists(select * from sys.triggers where [name] = 'ApplyRealmSecurityAfterInsertEntity')
	begin
		print '[Skipping] Entity Security is already installed.';
		print '[Skipping] To re-install first run view-security.uninstall.sql.';
		set noexec on;
	end;

begin transaction;
go
	create trigger [ApplyRealmSecurityAfterCreateEntityTable]
		on database after create_table as
		begin
			set nocount on

			declare @data xml = eventdata();
			declare @table sysname = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(100)');

			if exists(select * from [dbo].[xw_PortalEntities] where DatabaseTableName = @table)
				exec [SWSecurity].[ApplyRealmSecurity] 'dbo', @table, default;
		end;
go
	create trigger [dbo].[ApplyRealmSecurityAfterInsertEntity]
		on [dbo].[xw_PortalEntities] after insert as
		begin
			declare @table sysname;
			declare SecurityCursor cursor for
				select [DatabaseTableName]	from inserted;

			open SecurityCursor;
			fetch next from SecurityCursor into @table
			while @@fetch_status = 0
			begin
				if object_id('dbo.' + @table, 'U') is not null
					exec [SWSecurity].[ApplyRealmSecurity] 'dbo', @table, default;
				fetch next from SecurityCursor into @table
			end
			close SecurityCursor;
			deallocate SecurityCursor;
		end
go

commit;
set noexec off;
