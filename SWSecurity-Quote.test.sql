-- noinspection SqlSignatureForFile @ routine/"sp_set_session_context"
-- noinspection LongLineForFile

if not exists(select * from sys.triggers where [name] = 'ApplyRealmSecurityAfterInsertFormula')
	throw 50000 , 'Missing Dependency: SWSecurity.Realms', 0;

begin transaction;
	-- region [Assemble]
	insert [dbo].[xs_Formula_Master] ([Formula_Name], [Description], [Enabled], [Display_Order], [Security_Level], [Header_Quote_Tablename], [Detail_Quote_Tablename], [Group_Master_SQL_Query], [Group_Master_Source_Enabled], [Allow_Multiple_Subgroups], [Print_Exhibit_Workbook], [Print_Excel_Save_Security], [Print_Exhibit_Word_Document], [Print_Info_1], [Print_Info_2], [Print_Info_3], [Quote_Connection_String], [Source_Connection_String], [Reset_Override_Security_Level], [Custom_Info_1], [Custom_Info_2], [Custom_Info_3], [Custom_Info_4], [Custom_Info_5], [Comments], [Security_Create], [Security_Open], [Security_ReadWrite], [LastUpdated], [LastUpdateUser], [Security_Freeze], [Security_UnFreeze], [Version_From], [Version_Thru], [Header_Table_Count], [Detail_Table_Count], [UI_Parameters], [FD_Skip_AutoLoad], [Tags], [Parameters], [Formula_Type], [Group_Master_Use_Parent], [Reset_Override_Visible_Security], [Security_AddSubgr_Visible], [Security_AddSubgr_Execute], [Security_RemoveSubgr_Visible], [Security_RemoveSubgr_Execute], [Security_Undo_Visible], [Security_Undo_Execute], [Security_Freeze_Visible], [Security_UnFreeze_Visible], [Security_Save_Execute], [Security_Save_Visible], [Security_SaveAsIteration_Visible], [Security_SaveAsIteration_Execute], [Security_SaveAsQuote_Visible], [Security_SaveAsQuote_Execute], [Security_PrintTabs_Visible], [Security_PrintTabs_Execute], [Security_PrintExhibits_Visible], [Security_PrintExhibits_Execute], [Security_CalcErrLog_Visible], [Security_CalcErrLog_Execute], [Security_ViewQuoteSummary_Visible], [Security_ViewQuoteSummary_Execute], [Security_ReloadSourceData_Visible], [Security_ReloadSourceData_Execute], [Audit_Default]) VALUES
		(N'First_FM', N'First_FM', N'Y', 0, NULL, N'Save_First_FM_Header', N'Save_First_FM_Detail', NULL, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2022-05-02T13:42:38.833' AS DateTime), N'MS\afedler', NULL, NULL, CAST(N'1950-01-01T00:00:00.000' AS DateTime), CAST(N'2050-12-31T00:00:00.000' AS DateTime), 1, 1, NULL, 0, NULL, NULL, N'Formula', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'None')
	insert [dbo].[xs_Formula_Steps] ([Formula_Name], [Display_Order], [Section], [Input_Table], [Step_Name], [Caption], [Calculation], [Source_Column_Name], [Total_Calc_Category], [Total_Calc_Subgroup], [Parent_Summary_Show], [Hidden], [Save_Data], [Show_In_Print], [Alignment], [Data_Format], [Control_Type], [Control_Width], [Dropbox_List], [Varies_Category], [Varies_SubGroup], [Is_Input], [Is_Overridable], [Override_Security_Level], [Visible_Security_Level], [Custom_Info_1], [Custom_Info_2], [Custom_Info_3], [Sample_1], [Sample_2], [XML_Output], [Enabled], [Comments], [Max_Characters], [ValueListVariables], [Control_Height], [Layout], [Recalc_On_Open], [UI_Parameters], [Parameters], [Dropbox_ListSource], [Audit_Default]) VALUES
		(N'First_FM', 1, N'TopR', NULL, N'EffDate', N'Effective Date', NULL, NULL, N'NONE', N'NONE', 0, N'N', N'Y', 0, N'G', N'D', N'T', 1, NULL, 0, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1, NULL, 20, NULL, CAST(1 AS Decimal(18, 0)), NULL, 1, NULL, NULL, NULL, N'FormulaDefault')
	insert [dbo].[xs_Formula_Steps] ([Formula_Name], [Display_Order], [Section], [Input_Table], [Step_Name], [Caption], [Calculation], [Source_Column_Name], [Total_Calc_Category], [Total_Calc_Subgroup], [Parent_Summary_Show], [Hidden], [Save_Data], [Show_In_Print], [Alignment], [Data_Format], [Control_Type], [Control_Width], [Dropbox_List], [Varies_Category], [Varies_SubGroup], [Is_Input], [Is_Overridable], [Override_Security_Level], [Visible_Security_Level], [Custom_Info_1], [Custom_Info_2], [Custom_Info_3], [Sample_1], [Sample_2], [XML_Output], [Enabled], [Comments], [Max_Characters], [ValueListVariables], [Control_Height], [Layout], [Recalc_On_Open], [UI_Parameters], [Parameters], [Dropbox_ListSource], [Audit_Default]) VALUES
		(N'First_FM', 1.001, N'TopR', NULL, N'QuoteDate', N'Quote Date', NULL, NULL, N'NONE', N'NONE', 0, N'N', N'Y', 0, N'G', N'D', N'T', 1, NULL, 0, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1, NULL, 20, NULL, CAST(1 AS Decimal(18, 0)), NULL, 1, NULL, NULL, NULL, N'FormulaDefault');
	-- region [Assemble]
go
	-- region [Act]
		declare @Realm1 uniqueidentifier = newid();
		declare @Realm2 uniqueidentifier = newid();
		insert into [SWSecurity].[Realms] ([Id], [Name], [Client]) values (@Realm1, 'Realm T1', 'SWC');
		insert into [SWSecurity].[Realms] ([Id], [Name], [Client]) values (@Realm2, 'Realm T2', 'SWC');

		exec sp_set_session_context 'RealmId', @Realm1;
		exec ksi_NewQuote @UserID='Admin', @Formula_Name='First_FM',@PartitionID=-1,@NumSavePartitions=1;

		exec sp_set_session_context 'RealmId', @Realm2;
		exec ksi_NewQuote @UserID='Admin', @Formula_Name='First_FM',@PartitionID=-1,@NumSavePartitions=1;

	-- endregion [Act]
go
	-- region [Assert]
		declare @Realm1 uniqueidentifier = (select [Id] from [SWSecurity].[Realms] where [Name] = 'Realm T1');
		declare @Realm2 uniqueidentifier = (select [Id] from [SWSecurity].[Realms] where [Name] = 'Realm T2');
		declare @Count smallint;
		declare @Message varchar(120);

		exec sp_set_session_context 'RealmId', @Realm1;
		set @Count = (select count(*) from [dbo].[xs_Quote_Master]);
		if @Count <> 1
			begin
				set @Message = concat('FAILED: Ream 1|count: expected 1, got ', @Count);
				goto clean;
			end

		exec sp_set_session_context 'RealmId', @Realm2;
		set @Count = (select count(*) from [dbo].[xs_Quote_Master]);
		if @Count <> 1
			begin
				set @Message = concat('FAILED: Ream 2|count: expected 1, got ', @Count);
				goto clean;
			end

		exec sp_set_session_context 'RealmId', null;
		set @Count = (select count(*) from [dbo].[xs_Quote_Master]);
		if @Count <> 2
			begin
				set @Message = concat('FAILED: Admin-Mode|count: expected 2, got ', @Count);
				goto clean;
			end
	-- endregion [Assert]

	clean:
		drop table if exists [dbo].[Save_First_FM];
		delete from [dbo].[Xs_Quote_Master] where [Formula_Name] = 'First_FM';
		delete from [dbo].[xs_Formula_Steps] where [Formula_Name] = 'First_FM';
		delete from [dbo].[xs_Formula_Master] where [Formula_Name] = 'First_FM';
		delete from [SWSecurity].[Realms] where [Name] = 'Realm T1' or [Name] = 'Realm T2';

	result:
		if @Message is not null
			throw 60000, @Message, 0
go

commit;
