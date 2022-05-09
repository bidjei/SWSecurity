-- noinspection SqlIdentifierForFile
-- noinspection SqlResolveForFile
-- noinspection SyntaxErrorForFile

drop trigger if exists [dbo].[xs_Quote_MasterAfterInsert]; -- Made via ApplyRealmSecurity
drop trigger if exists [dbo].[ApplyRealmSecurityAfterInsertFormula];
drop trigger if exists [ApplyRealmSecurityAfterCreateFormulaTable] on database;

alter security policy [SWSecurity].[RealmViewPolicy]
   drop filter predicate on [dbo].[xs_Quote_Master];

alter table [dbo].[xs_Quote_Master] drop
	constraint if exists [xs_Quote_MasterDfSecurityId],
	constraint if exists [xs_Quote_MasterUqSecurityId],
	column if exists [SecurityId];
