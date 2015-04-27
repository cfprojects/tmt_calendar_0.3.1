<cfcomponent output="no" hint="Base CFC for TMT Calendar. You can extend it as you see fit">

	<cfprocessingdirective pageencoding="iso-8859-1">
	
	<cfscript>
	variables.rootPath = "";
	// Database settings
	variables.dsn = "";
	variables.dsnPassword = "";
	variables.dsnUsername = "";
	// Attachments settings
	variables.attachmentsPath = "";
	variables.attachmentsAbsolutePath = "";
	variables.attachmentsMaxSize = "";
	variables.attachmentsMimeTypes = "";
	// Images settings
	variables.imagesPath = "";
	variables.imagesAbsolutePath = "";
	variables.imagesMaxSize = "";
	variables.imagesMaxWidth = "";
	// Store helper cfcs as an instance variables
	variables.fileObj = "";
	variables.imgObj = "";	
	variables.dbObj = "";
	variables.configObj = "";
	variables.userObj = "";
	</cfscript>
	
	<cffunction name="init" access="public" output="no" hint="Pseudo-constructor, it ensure settings are properly loaded inside the CFC">
		<cfargument name="fileObj" required="yes" hint="An instance of tmt_file_io.cfc">
		<cfargument name="imgObj" required="yes" hint="An instance of tmt_img_utils.cfc">
		<cfargument name="dbObj" required="yes" hint="DataMgr object">
		<cfargument name="configObj" required="yes" hint="Configuration object">
		<cfargument name="userObj" required="yes" hint="An instance of tmt_user.cfc">
		<cfargument name="rootPath" type="string" required="yes" hint="Application's root absolute path">
		<cfscript>
		variables.fileObj = arguments.fileObj;
		variables.imgObj = arguments.imgObj;
		variables.dbObj = arguments.dbObj;
		variables.configObj = arguments.configObj;
		variables.userObj = arguments.userObj;
		variables.rootPath = arguments.rootPath;
		variables.dsn = variables.configObj.get("dsn");
		variables.dsnPassword = variables.configObj.get("dsnPassword");
		variables.dsnUsername = variables.configObj.get("dsnUsername");
		variables.attachmentsPath = variables.configObj.get("attachmentsPath");
		variables.attachmentsAbsolutePath = arguments.rootPath & Replace(variables.configObj.get("attachmentsPath"), "\", "/", "all");
		variables.attachmentsMaxSize = variables.configObj.get("attachmentsMaxSize");
		variables.attachmentsMimeTypes = variables.configObj.get("attachmentsMimeTypes");
		variables.imagesPath = variables.configObj.get("imagesPath");
		variables.imagesAbsolutePath = arguments.rootPath & Replace(variables.configObj.get("imagesPath"), "\", "/", "all");
		variables.imagesMaxSize = variables.configObj.get("imagesMaxSize");
		variables.imagesMaxWidth = variables.configObj.get("imagesMaxWidth");
		</cfscript>
		<cfreturn this>
	</cffunction>
	
	<!--- DB gateways --->
	
	<cffunction name="getLanguages" access="public" returntype="query" output="no">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT lang_abbrev, lang_name
		FROM #variables.configObj.get("languagesTable")#
		ORDER BY lang_order
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
	
	<cffunction name="getCategories" access="public" returntype="query" output="no" hint="Return categories info">
		<cfargument name="id" type="numeric" required="yes" default="0" hint="PK">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT cat_id, cat_name, cat_sort_order
		FROM #variables.configObj.get("categoriesView")#
		WHERE lang_abbrev = <cfqueryparam value="#variables.userObj.getLanguage()#" cfsqltype="cf_sql_char">
		OR lang_abbrev IS NULL
		ORDER BY cat_sort_order
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
	
	<cffunction name="getSkins" access="public" returntype="query" output="no" hint="Return skin info">
		<cfargument name="id" type="numeric" required="yes" default="0" hint="PK">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT skin_id, skin_name
		FROM #variables.configObj.get("skinsTable")#
		<cfif arguments.id NEQ 0>
			WHERE skin_id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
		</cfif>
		ORDER BY skin_name
		</cfquery>
		<cfreturn retQuery>
	</cffunction>	
	
	<cffunction name="getEvents" access="public" output="false" returntype="array" hint="Return calendar's data as an array of structures double nested array">
		<cfargument name="searchCriteria" type="struct" required="yes" default="#StructNew()#" hint="Structure containing search criteria">
		<cfreturn QueryToArrayOfStructures(getEventsList(arguments.searchCriteria))>
	</cffunction>
	
	<cffunction name="getEventDetail" access="public" returntype="query" output="no" hint="Return a specific record">
		<cfargument name="id" type="numeric" required="yes" hint="PK">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT *
		FROM #variables.configObj.get("detailsView")#
		WHERE event_id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
		AND lang_abbrev = <cfqueryparam value="#variables.userObj.getLanguage()#" cfsqltype="cf_sql_char">
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
	
	<cffunction name="getEventsList" access="public" returntype="query" output="no" hint="Return events info">
		<cfargument name="input" type="struct" required="yes" hint="Structure containing input data, typically form or url scope">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT *
		FROM #variables.configObj.get("listView")#
		WHERE lang_abbrev = <cfqueryparam value="#variables.userObj.getLanguage()#" cfsqltype="cf_sql_char">
		<cfif StructKeyexists(arguments.input, "cat_id") AND (arguments.input.cat_id NEQ "")>
			AND cat_id = <cfqueryparam value="#arguments.input.cat_id#" cfsqltype="cf_sql_integer">
		</cfif>
		<cfif StructKeyexists(arguments.input, "start_date") AND (arguments.input.start_date NEQ "")>
			AND (
				event_start_date >= <cfqueryparam value="#arguments.input.start_date#" cfsqltype="cf_sql_date">
				OR
				event_end_date >= <cfqueryparam value="#arguments.input.start_date#" cfsqltype="cf_sql_date">
				)
		</cfif>
		<cfif StructKeyexists(arguments.input, "end_date") AND (arguments.input.end_date NEQ "")>
			AND (
				event_end_date <= <cfqueryparam value="#arguments.input.end_date#" cfsqltype="cf_sql_date">
				OR
				event_start_date <= <cfqueryparam value="#arguments.input.end_date#" cfsqltype="cf_sql_date">
			)
		</cfif>
		<cfif StructKeyexists(arguments.input, "is_visible")>
			AND is_visible = 1
		</cfif>
		ORDER BY event_start_date
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
		
	<cffunction name="getAttachments" access="public" returntype="query" output="no" hint="Return attachments records">
		<cfargument name="event_id" type="numeric" required="yes" hint="FK">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT *
		FROM #variables.configObj.get("attachmentsTable")#
		WHERE event_id = <cfqueryparam value="#arguments.event_id#" cfsqltype="cf_sql_integer">
		AND lang_abbrev = <cfqueryparam value="#variables.userObj.getLanguage()#" cfsqltype="cf_sql_char">
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
	
	<cffunction name="getImages" access="public" returntype="query" output="no" hint="Return picture record/s">
		<cfargument name="event_id" type="numeric" required="yes" hint="FK">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT *
		FROM #variables.configObj.get("imagesTable")#
		WHERE event_id = <cfqueryparam value="#arguments.event_id#" cfsqltype="cf_sql_integer">
		AND lang_abbrev = <cfqueryparam value="#variables.userObj.getLanguage()#" cfsqltype="cf_sql_char">
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
	
	<!--- Getters --->

	<cffunction name="getAttachmentsPath" access="public" returntype="string" output="no">
		<cfreturn variables.attachmentsPath>
	</cffunction>
	
	<cffunction name="getImagesPath" access="public" returntype="string" output="no">
		<cfreturn variables.imagesPath>
	</cffunction>
	
	<cffunction name="getMaxImagesSize" access="public" returntype="numeric" output="no">
		<cfreturn variables.imagesMaxSize>
	</cffunction>
	
	<cffunction name="getMaxAttachmentsSize" access="public" returntype="numeric" output="no">
		<cfreturn variables.attachmentsMaxSize>
	</cffunction>
	
	<!--- Metadata CRUD --->
	
	<cffunction name="deleteMeta" access="public" returntype="void" output="no" hint="Delete an existing record">
		<cfargument name="event_id" type="numeric" required="yes" hint="PK">
		<cfset variables.dbObj.deleteRecord(variables.configObj.get("metadataTable"), arguments)>
	</cffunction>
	
	<cffunction name="getMeta" access="public" returntype="query" output="no">
		<cfargument name="input" type="struct" required="yes" hint="Structure containing input data, typically form or url scope">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT *
		FROM #variables.configObj.get("metadataView")#
		WHERE 0 = 0
		<cfif StructKeyexists(arguments.input, "event_id") AND (arguments.input.event_id NEQ "")>
			AND event_id = <cfqueryparam value="#arguments.input.event_id#" cfsqltype="cf_sql_integer">
		</cfif>
		<cfif StructKeyexists(arguments.input, "cat_id") AND (arguments.input.cat_id NEQ "")>
			AND cat_id = <cfqueryparam value="#arguments.input.cat_id#" cfsqltype="cf_sql_integer">
		</cfif>
		<cfif StructKeyexists(arguments.input, "skin_id") AND (arguments.input.skin_id NEQ "")>
			AND skin_id = <cfqueryparam value="#arguments.input.skin_id#" cfsqltype="cf_sql_integer">
		</cfif>
		<cfif StructKeyexists(arguments.input, "title") AND (arguments.input.title NEQ "")>
			AND titles LIKE <cfqueryparam value="%#arguments.input.title#%" cfsqltype="cf_sql_varchar">
		</cfif>
		<cfif StructKeyexists(arguments.input, "start_date") AND (arguments.input.start_date NEQ "")>
			AND (
				event_start_date >= <cfqueryparam value="#arguments.input.start_date#" cfsqltype="cf_sql_date">
				OR
				event_end_date >= <cfqueryparam value="#arguments.input.start_date#" cfsqltype="cf_sql_date">
				)
		</cfif>
		<cfif StructKeyexists(arguments.input, "end_date") AND (arguments.input.end_date NEQ "")>
			AND (
				event_end_date <= <cfqueryparam value="#arguments.input.end_date#" cfsqltype="cf_sql_date">
				OR
				event_start_date <= <cfqueryparam value="#arguments.input.end_date#" cfsqltype="cf_sql_date">
			)
		</cfif>
		ORDER BY event_start_date
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
	
	<cffunction name="insertMeta" access="public" returntype="numeric" output="no" hint="Insert new record">
		<cfargument name="input" type="struct" required="yes" hint="Structure containing input data, typically form or url scope">
		<cfreturn variables.dbObj.insertRecord(variables.configObj.get("metadataTable"), arguments.input)>
	</cffunction>	
	
	<cffunction name="updateMeta" access="public" returntype="void" output="no" hint="Update an existing record">
		<cfargument name="input" type="struct" required="yes" hint="Structure containing input data, typically form or url scope">
		<cfset variables.dbObj.updateRecord(variables.configObj.get("metadataTable"), arguments.input)>
	</cffunction>
	
	<!--- Events CRUD --->
	
	<cffunction name="deleteLocal" access="public" returntype="void" output="no" hint="Delete an existing record">
		<cfargument name="event_id" type="numeric" required="yes" hint="PK">
		<cfargument name="lang_abbrev" type="string" required="yes" hint="PK">
		<cfset variables.dbObj.deleteRecord(variables.configObj.get("eventsTable"), arguments)>
	</cffunction>
	
	<cffunction name="editEvent" access="public" returntype="void" output="no" hint="Insert/Update record">
		<cfargument name="input" type="struct" required="yes" hint="Structure containing input data, typically form or url scope">
		<cfset variables.dbObj.saveRecord(variables.configObj.get("eventsTable"), arguments.input)>
	</cffunction>
	
	<cffunction name="getLocal" access="public" returntype="query" output="no">
		<cfargument name="id" type="numeric" required="yes" hint="PK">
		<cfargument name="lang_abbrev" type="string" required="yes" hint="PK">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT *
		FROM #variables.configObj.get("eventsTable")#
		WHERE event_id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
		AND lang_abbrev = <cfqueryparam value="#arguments.lang_abbrev#" cfsqltype="cf_sql_char">
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
	
	<!--- Images CRUD --->
	
	<cffunction name="deleteImage" access="public" returntype="void" output="no" hint="Delete an existing record">
		<cfargument name="img_id" type="numeric" required="yes" hint="PK">
		<cfset var fileQuery = getImage(arguments.img_id)>
		<cfset var filePath = variables.imagesAbsolutePath & fileQuery.img_filename>
		<cfset variables.dbObj.deleteRecord(variables.configObj.get("imagesTable"), arguments)>
		<cfset variables.fileObj.deleteFile(filePath)>
	</cffunction>
	
	<cffunction name="getLocalImages" access="public" returntype="query" output="no">
		<cfargument name="event_id" type="numeric" required="yes" hint="FK">
		<cfargument name="lang_abbrev" type="string" required="yes" hint="PK">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT *
		FROM #variables.configObj.get("imagesTable")#
		WHERE event_id = <cfqueryparam value="#arguments.event_id#" cfsqltype="cf_sql_integer">
		AND lang_abbrev = <cfqueryparam value="#arguments.lang_abbrev#" cfsqltype="cf_sql_char">
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
	
	<cffunction name="getImage" access="private" returntype="query" output="no" hint="Return a single record">
		<cfargument name="id" type="numeric" required="yes" hint="PK">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT *
		FROM #variables.configObj.get("imagesTable")#
		WHERE img_id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
	
	<cffunction name="insertImage" access="public" returntype="void" output="no" hint="Insert new record">
		<cfargument name="input" type="struct" required="yes" hint="Structure containing input data, typically form or url scope">
		<cfset uploadImage()>
		<cfset variables.dbObj.insertRecord(variables.configObj.get("imagesTable"), arguments.input)>
	</cffunction>
	
	<cffunction name="uploadImage" access="private" returntype="void" output="no" hint="Upload image and resize">
		<cfset variables.imgObj.uploadResample("img_filename", variables.imagesAbsolutePath, variables.imagesMaxSize, variables.imagesMaxWidth)>
	</cffunction>
	
	<!--- Attachments CRUD --->
	
	<cffunction name="deleteAttachment" access="public" returntype="void" output="no" hint="Delete an existing record">
		<cfargument name="attach_id" type="numeric" required="yes" hint="PK">
		<cfset var fileQuery = getAttachment(arguments.attach_id)>
		<cfset var filePath = variables.attachmentsAbsolutePath & fileQuery.attach_filename>
		<cfset variables.dbObj.deleteRecord(variables.configObj.get("attachmentsTable"), arguments)>
		<cfset variables.fileObj.deleteFile(filePath)>
	</cffunction>
	
	<cffunction name="getAttachment" access="private" returntype="query" output="no" hint="Return a single record">
		<cfargument name="id" type="numeric" required="yes" hint="PK">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT *
		FROM #variables.configObj.get("attachmentsTable")#
		WHERE attach_id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
	
	<cffunction name="getLocalAttachments" access="public" returntype="query" output="no" hint="Return picture record/s">
		<cfargument name="event_id" type="numeric" required="yes" hint="FK">
		<cfargument name="lang_abbrev" type="string" required="yes" hint="PK">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT *
		FROM #variables.configObj.get("attachmentsTable")#
		WHERE event_id = <cfqueryparam value="#arguments.event_id#" cfsqltype="cf_sql_integer">
		AND lang_abbrev = <cfqueryparam value="#arguments.lang_abbrev#" cfsqltype="cf_sql_char">
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
	
	<cffunction name="insertAttachment" access="public" returntype="void" output="no" hint="Insert new record">
		<cfargument name="input" type="struct" required="yes" hint="Structure containing input data, typically form or url scope">
		<cfset uploadAttachment()>
		<cfset variables.dbObj.insertRecord(variables.configObj.get("attachmentsTable"), arguments.input)>
	</cffunction>
	
	<cffunction name="uploadAttachment" access="private" returntype="void" output="no" hint="Upload an attachment file">
		<cfset variables.fileObj.uploadFile("attach_filename", variables.attachmentsAbsolutePath, variables.attachmentsMaxSize, variables.attachmentsMimeTypes)>
	</cffunction>
	
	<!--- Meta Categories CRUD --->
	
	<cffunction name="deleteCategory" access="public" returntype="void" output="no" hint="Update an existing record">
		<cfargument name="cat_id" type="numeric" required="yes" hint="PK">
		<cfset variables.dbObj.deleteRecord(variables.configObj.get("categoriesMetadataTable"), arguments)>
	</cffunction>
	
	<cffunction name="getMetaCategory" access="public" returntype="query" output="no" hint="Update an existing record">
		<cfargument name="id" type="numeric" required="no" default="0" hint="PK">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT *
		FROM #variables.configObj.get("metaCategoriesView")#
		<cfif arguments.id NEQ 0>
			WHERE cat_id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
		</cfif>
		</cfquery>
		<cfreturn retQuery>
	</cffunction>
	
	<cffunction name="insertMetaCategory" access="public" returntype="numeric" output="no" hint="Insert new record">
		<cfargument name="input" type="struct" required="yes" hint="Structure containing input data, typically form or url scope">
		<cfreturn variables.dbObj.insertRecord(variables.configObj.get("categoriesMetadataTable"), arguments.input)>
	</cffunction>
	
	<cffunction name="updateMetaCategory" access="public" returntype="void" output="no" hint="Update an existing record">
		<cfargument name="input" type="struct" required="yes" hint="Structure containing input data, typically form or url scope">
		<cfset variables.dbObj.updateRecord(variables.configObj.get("categoriesMetadataTable"), arguments.input)>
	</cffunction>
	
	<!--- Categories CRUD --->
	
	<cffunction name="deleteLocalCategory" access="public" returntype="void" output="no" hint="Update an existing record">
		<cfargument name="cat_id" type="numeric" required="yes" hint="PK">
		<cfargument name="lang_abbrev" type="string" required="yes" hint="PK">
		<cfset variables.dbObj.deleteRecord(variables.configObj.get("categoriesTable"), arguments)>
	</cffunction>
	
	<cffunction name="editCategory" access="public" returntype="void" output="no" hint="Insert/Update record">
		<cfargument name="input" type="struct" required="yes" hint="Structure containing input data, typically form or url scope">
		<cfset variables.dbObj.saveRecord(variables.configObj.get("categoriesTable"), arguments.input)>
	</cffunction>
	
	<cffunction name="getCategory" access="public" returntype="query" output="no">
		<cfargument name="id" type="numeric" required="yes" hint="PK">
		<cfargument name="lang_abbrev" type="string" required="yes" hint="PK">
		<cfset var retQuery = "">
		<cfquery name="retQuery" datasource="#variables.dsn#" password="#variables.dsnPassword#" username="#variables.dsnUsername#">
		SELECT *
		FROM #variables.configObj.get("categoriesTable")#
		WHERE cat_id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
		AND lang_abbrev = <cfqueryparam value="#arguments.lang_abbrev#" cfsqltype="cf_sql_char">
		</cfquery>
		<cfreturn retQuery>
	</cffunction>

	<!--- Skins CRUD --->
	
	<cffunction name="deleteSkin" access="public" returntype="void" output="no" hint="Update an existing record">
		<cfargument name="skin_id" type="numeric" required="yes" hint="PK">
		<cfset variables.dbObj.deleteRecord(variables.configObj.get("skinsTable"), arguments)>
	</cffunction>
	
	<cffunction name="insertSkin" access="public" returntype="void" output="no" hint="Insert new record">
		<cfargument name="input" type="struct" required="yes" hint="Structure containing input data, typically form or url scope">
		<cfset variables.dbObj.insertRecord(variables.configObj.get("skinsTable"), arguments.input)>
	</cffunction>
	
	<cffunction name="updateSkin" access="public" returntype="void" output="no" hint="Update an existing record">
		<cfargument name="input" type="struct" required="yes" hint="Structure containing input data, typically form or url scope">
		<cfset variables.dbObj.updateRecord(variables.configObj.get("skinsTable"), arguments.input)>
	</cffunction>
	
	<!--- Utilities --->
	
	<cfscript>
	/**
	* Converts a query object into an array of structures.
	* 
	* @param query      The query to be transformed 
	* @return This function returns a structure. 
	* @author Nathan Dintenfass (nathan@changemedia.com) 
	* @version 1, September 27, 2001 
	*/
	function QueryToArrayOfStructures(theQuery){
		var theArray = arraynew(1);
		var cols = ListtoArray(theQuery.columnlist);
		var row = 1;
		var thisRow = "";
		var col = 1;
		for(row = 1; row LTE theQuery.recordcount; row = row + 1){
			thisRow = structnew();
			for(col = 1; col LTE arraylen(cols); col = col + 1){
				thisRow[cols[col]] = theQuery[cols[col]][row];
			}
			arrayAppend(theArray,duplicate(thisRow));
		}
		return(theArray);
	}
	</cfscript>

</cfcomponent>