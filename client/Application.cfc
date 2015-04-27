<cfcomponent output="false">

	<!--- Application specific --->
	<cfset this.name = GetCurrentTemplatePath()>
	<cfset this.errorEmail = "user@yourdomain.com">
	<cfset this.smtpServer = "smtp.yourdomain.com">
	<cfset this.smtpUsername = "username">
	<cfset this.smtpPassword = "password">
	<!--- Generic/reusable settings --->
	<cfset this.isDev = false>
	<cfif cgi.server_name EQ "localhost" OR (cgi.server_name EQ "127.0.0.1")>
		<cfset this.isDev = true>
	</cfif>
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = CreateTimeSpan(0, 0, 20, 0)>
	<cfset this.loginStorage = "session">
	<cfset this.mappings["/cfc"] = "#GetDirectoryFromPath(GetCurrentTemplatePath())#components"> 
	
	<!--- Force encoding (don't trust default) --->
	<cfprocessingdirective pageencoding="utf-8">
	<cfcontent type="text/html; charset=utf-8">
	<cfset SetEncoding("url", "utf-8")>
	<cfset SetEncoding("form", "utf-8")>
	
	<cffunction name="onApplicationStart" returntype="boolean" output="false">
		<cfset var appRoot = GetDirectoryFromPath(GetCurrentTemplatePath())>
		<!--- Application singletons --->
		<cfset application.fileObj = CreateObject("component", "cfc.lib.tmt_file_io").init("utf-8")>
		<cfset application.imgObj = CreateObject("component", "cfc.lib.tmt_img_utils").init(application.fileObj)>
		<cfset application.spryObj = CreateObject("component", "cfc.lib.tmt_spry")>
		<cfset application.configObj = CreateObject("component", "cfc.lib.tmt_config").init(application.fileObj, "#appRoot#config/general.cfm")>
		<cfset application.csvObj = CreateObject("component", "cfc.lib.tmt_csv").init(application.configObj.get("csvSeparator"))>
		<!--- DataMgr --->
		<cfinvoke component="cfc.lib.DataMgr.DataMgr" method="init" returnvariable="application.dbObj">
			<cfinvokeargument name="datasource" value="#application.configObj.get("dsn")#">
			<cfinvokeargument name="database" value="#application.configObj.get("database")#">
			<cfinvokeargument name="username" value="#application.configObj.get("dsnUsername")#">
			<cfinvokeargument name="password" value="#application.configObj.get("dsnPassword")#">
		</cfinvoke>		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="onSessionStart" returntype="void" output="false">
		<cfset var appRoot = GetDirectoryFromPath(GetCurrentTemplatePath())>
		<cfset var localObj = CreateObject("component", "cfc.lib.tmt_config")>
		<!--- Session singletons --->
		<cfset session.userObj = CreateObject("component", "cfc.tmt_user").init(application.fileObj, application.configObj, localObj, appRoot)>
		<!--- Calendar singleton --->
		<cfset calendarConfigFile = "#appRoot#config/calendar.cfm">
		<cfset calendarConfigObj = CreateObject("component", "cfc.lib.tmt_config").init(application.fileObj, calendarConfigFile)>		
		<cfset session.calendarObj = CreateObject("component", "cfc.tmt_calendar.calendar").init(application.fileObj, application.imgObj, application.dbObj, calendarConfigObj, session.userObj, appRoot)>		
	</cffunction>
	
	<cffunction name="onSessionEnd" returntype="void" output="false">
		<cfargument name="sessionScope" required="true">
		<cfargument name="applicationScope" required="true">
		<!---
		Remember:
		1) Here you cannot reference the Application scope directly (use arguments.applicationScope instead)
		2) Here you cannot access the Request scope
		3) Sessions do not end, and the onSessionEnd method is not called when an application ends
		--->
	</cffunction>
	
	<cffunction name="onRequestStart" returntype="void" output="false">
		<cfargument name="targetPage" type="string" required="true">
		<cfset var appRoot = GetDirectoryFromPath(GetCurrentTemplatePath())>
		<cfset var requestedUrl = "#arguments.targetPage#?#cgi.query_string#">
		<cfset killBrowserCache()>
		<cfset sanitizePOST()>
		<cfif StructKeyExists(url, "init")>
			<cfset reloadApplication()>
		</cfif>
		<cfif StructKeyExists(url, "logout")>
			<cfset onSessionStart()>
		</cfif>
		<cfif structKeyExists(url, "lang")>
			<cfset switchLanguage(url.lang)>
		</cfif>
		<!--- Pointers to singletons --->
		<cfset request.fileObj = application.fileObj>
		<cfset request.imgObj = application.imgObj>
		<cfset request.spryObj = application.spryObj>
		<cfset request.csvObj = application.csvObj>
		<cfset request.configObj = application.configObj>
		<cfset request.dbObj = application.dbObj>
		<cfset request.calendarObj = session.calendarObj>
		<cfset request.userObj = session.userObj>
		<cfset request.localObj = session.userObj.getLocalObj()>
		<!--- Set locale --->
		<cfset request.userObj.setUserLocale()>
		<!--- Figure out relative path from the current template to the app's root --->
		<cfset request.appRoot = appRoot>
		<cfset request.pathToRoot = request.fileObj.getRelativePath(GetBaseTemplatePath(), request.appRoot)>
		<cfset request.currentPage = GetFileFromPath(GetBaseTemplatePath())>
		<!--- Generic variables --->
		<cfset request.lang = session.userObj.getLanguage()>
		<cfset request.appName = this.name>
	</cffunction>
	
	<cffunction name="onError" returntype="void" output="false">
		<cfargument name="exception" required="true">
		<cfargument name="eventname" type="string" required="true">
		<cfset var errorDetail = "">
		<cfheader statuscode="500">
		<cfsavecontent variable="errorDetail">
			<cfdump label="Error info" var="#arguments#">
			<cfdump label="CGI scope" var="#cgi#">
			<cfdump label="URL scope" var="#url#">
			<cfdump label="FORM scope" var="#form#">
		</cfsavecontent>
		<!--- In Dev just print info on screen, else, send error notification --->
		<cfif this.isDev>
			<cfoutput>#errorDetail#</cfoutput>
		<cfelse>
			<cfset notifyError(errorDetail)>
			<cfinclude template="errors/index.cfm">
		</cfif>
		<cfabort>
	</cffunction>
	
	<!--- Helpers/Utilities --->
	
	<cffunction name="reloadApplication" returntype="void" output="false" hint="Restart the application">
		<cfset onApplicationStart()>
	</cffunction>
	
	<cffunction name="switchLanguage" returntype="void" output="false">
		<cfargument name="lang" type="string" required="true">
		<cflock timeout="5" type="exclusive" scope="session">
			<cfset session.userObj.setLanguage(arguments.lang)>
		</cflock>
	</cffunction>
	
	<cffunction name="killBrowserCache" returntype="void" output="false" hint="Cache killers HTTP headers">
		<cfheader name="Pragma" value="no-cache">
		<cfheader name="Cache-Control" value="no-cache, no-store, proxy-revalidate, must-revalidate">
		<cfheader name="Expires" value="#DateFormat(DateAdd('d',-1, now()),'ddd, dd mmm yyyy')# #TimeFormat(now(),'HH:mm:ss')# GMT">
	</cffunction>
	
	<cffunction name="notifyError" returntype="void" output="false">
		<cfargument name="errorData" type="string" required="true">
		<cfmail server="#this.smtpServer#" username="#this.smtpUsername#" password="#this.smtpPassword#" to="#this.errorEmail#" from="#this.errorEmail#" subject="Error on #this.name#" type="html">
		#arguments.errorData#
		</cfmail>
	</cffunction>
	
	<!--- Input sanitizers --->
	
	<cffunction name="sanitizePOST" returntype="void" output="false" hint="Sanitize and clean up data coming from POST requests">
		<cfset var i = "">
		<cfloop collection="#form#" item="i">
			<!--- Trim form values --->
			<cfset StructUpdate(form, i, Trim(form[i]))>
			<!--- Clean up Word's special chars --->
			<cfset StructUpdate(form, i, demoronizer(form[i]))>
		</cfloop>
	</cffunction>
	
	<cffunction name="demoronizer" output="false" returntype="string" hint="Replace MS Word's non-ISO characters with plausible substitutes">
		<cfargument name="text" type="string" required="yes">
		<cfscript>
		var retText = "";
		retText = Replace(arguments.text, Chr(128), "¤", "all");
		retText = Replace(retText, Chr(130), ",", "all");
		retText = Replace(retText, Chr(132), ",,", "all");
		retText = Replace(retText, Chr(133), "...", "all");
		retText = Replace(retText, Chr(136), "^", "all");
		retText = Replace(retText, Chr(145), "'", "all");
		retText = Replace(retText, Chr(146), "'", "all");
		retText = Replace(retText, Chr(147), """", "all");
		retText = Replace(retText, Chr(148), """", "all");
		retText = Replace(retText, Chr(149), "*", "all");
		retText = Replace(retText, Chr(150), "-", "all");
		retText = Replace(retText, Chr(151), "--", "all");
		retText = Replace(retText, Chr(152), "~", "all");
		return text;
		</cfscript>
	</cffunction>

</cfcomponent>