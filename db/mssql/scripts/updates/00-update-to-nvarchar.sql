-- Update script for managed_user explicit table
-- Need to update existing columns that have deprecated data types
ALTER TABLE [openidm].[managed_user] ALTER COLUMN expireaccount NVARCHAR(MAX);
ALTER TABLE [openidm].[managed_user] ALTER COLUMN activateaccount NVARCHAR(MAX);
ALTER TABLE [openidm].[managed_user] ALTER COLUMN kbainfo NVARCHAR(MAX);
ALTER TABLE [openidm].[managed_user] ALTER COLUMN lastsync NVARCHAR(MAX);
ALTER TABLE [openidm].[managed_user] ALTER COLUMN preferences NVARCHAR(MAX);
ALTER TABLE [openidm].[managed_user] ALTER COLUMN consentedmappings NVARCHAR(MAX);
ALTER TABLE [openidm].[managed_user] ALTER COLUMN effectiveassignments NVARCHAR(MAX);
ALTER TABLE [openidm].[managed_user] ALTER COLUMN effectiveroles NVARCHAR(MAX);
GO