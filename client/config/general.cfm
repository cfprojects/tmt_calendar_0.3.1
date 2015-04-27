<?xml version="1.0" encoding="utf-8"?>
<cfsilent>
	<cfprocessingdirective pageencoding="utf-8" />
	<!-- Database (used by DataMngr and potentially other components) -->
	<param name="dsn" description="ColdFusion datasource">calendar</param>
	<param name="database" description="Type of database used, either MSSQL or MYSQL">MSSQL</param>
	<param name="dsnUsername" description="Database username">tmt</param>
	<param name="dsnPassword" description="Database password">tmt</param>
	<!-- Language related settings -->
	<param name="langDefault" description="Default language">en</param>
	<param name="langList" description="Comma-delimited list of allowed languages">de,en,fr,it</param>
	<!-- User messages for admin -->
	<param name="deleteRecordMSG">Record deleted</param>
	<param name="updateRecordMSG">Record updated</param>
	<!-- Miscellaneous -->
	<param name="csvSeparator" description="Separator used by CSV files">,</param>
</cfsilent>