if exists(select * from sys.triggers where [name] = 'ApplyRealmSecurityAfterInsertFormula')
	begin
		print '[Skipping] Quote Security is already installed.';
		print '[Skipping] To re-install first run view-security.uninstall.sql.';
		set noexec on;
	end;

begin transaction;
go
	create trigger [ApplyRealmSecurityAfterCreateFormulaTable]
		on database after create_table as
		begin
			set nocount on

			declare @data xml = eventdata();
			declare @table sysname = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(100)');

			if exists(select * from dbo.xs_Formula_Master where @table like [Header_Quote_TableName] + '%')
				exec [SWSecurity].[ApplyRealmSecurity] 'dbo', @table, default;
			else if exists(select * from dbo.xs_Formula_Master where @table like [Detail_Quote_TableName] + '%')
				exec [SWSecurity].[ApplyRealmSecurity] 'dbo', @table, default;
		end;
go
	create trigger [dbo].[ApplyRealmSecurityAfterInsertFormula]
		on [dbo].[xs_Formula_Master] after insert as
		begin
			declare @header sysname;
			declare @detail sysname;

			declare SecurityCursor cursor for
				select [Header_Quote_TableName], [Detail_Quote_TableName] from inserted;

			open SecurityCursor;
			fetch next from SecurityCursor
				into @header, @detail
			while @@fetch_status = 0
			begin
				if exists (select * from sys.tables where [name] = @header)
					exec [SWSecurity].[ApplyRealmSecurity] 'dbo', @header, default;
				if exists (select * from sys.tables where [name] = @detail)
					exec [SWSecurity].[ApplyRealmSecurity] 'dbo', @detail, default;
				fetch next from SecurityCursor
					into @header, @detail
			end
			close SecurityCursor;
			deallocate SecurityCursor;
		end
go
	exec [SWSecurity].[ApplyRealmSecurity] 'dbo', 'xs_Quote_Master', default;
go

commit;
set noexec off;
