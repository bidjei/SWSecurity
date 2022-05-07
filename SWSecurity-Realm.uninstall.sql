
drop security policy if exists [SWSecurity].[ViewSecurityPolicy];
drop security policy if exists [SWSecurity].[RealmViewPolicy];
drop function if exists [SWSecurity].[InRealmViewFilter];
drop function if exists [SWSecurity].[InRealmView];
drop function if exists [SWSecurity].[CurrentRealmId];
drop procedure if exists [SWSecurity].[ApplyRealmSecurity];
drop procedure if exists [SWSecurity].[CreateTriggerForRealmTransactionAfterInsert];
drop procedure if exists [SWSecurity].[AddToRealmViewPolicy];
drop table if exists [SWSecurity].[RealmTransactions];
drop table if exists [SWSecurity].[Realms];
drop procedure if exists [SWSecurity].[CreateSecurityTransactionColumn];
