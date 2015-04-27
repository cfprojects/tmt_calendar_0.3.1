<cfcomponent output="false" hint="User object">

	<cfprocessingdirective pageencoding="iso-8859-1">
	<cfscript>
	variables.rootPath = "";
	variables.lang = "";
	// Store helper cfcs as instance variables
	variables.fileObj = "";
	variables.configObj = "";
	variables.localObj = "";
	</cfscript>
	
	<cffunction name="init" access="public" output="false" returntype="tmt_user" hint="Pseudo-constructor">
		<cfargument name="fileObj" hint="An instance of tmt_file_io.cfc">
		<cfargument name="configObj" required="yes" hint="An instance of tmt_config.cfc storing application config">
		<cfargument name="localObj" required="yes" hint="An instance of tmt_config.cfc to store localized strings">
		<cfargument name="rootPath" type="string" required="yes" hint="Application's root absolute path">
		<cfscript>
		variables.fileObj = arguments.fileObj;
		variables.configObj = arguments.configObj;
		variables.localObj = arguments.localObj;
		variables.rootPath = arguments.rootPath;
		initLocal(arguments.configObj.get("langDefault"));
		initLanguage();
		</cfscript>
		<cfreturn this>
	</cffunction>
	
	<!--- Getters/setters --->
	
	<cffunction name="getLanguage" access="public" output="false" returntype="string">
		<cfreturn variables.lang>
	</cffunction>
	
	<cffunction name="getLocalObj" access="public" output="false">
		<cfreturn variables.localObj>
	</cffunction>
	
	<cffunction name="setUserLocale" access="public" output="false" returntype="void">
		<cfset SetLocale(variables.localObj.get("cfLocale"))>
	</cffunction>
	
	<cffunction name="setLanguage" access="public" output="false" returntype="void">
		<cfargument name="language" type="string" required="yes">
		<!--- Accept only allowed languages --->
		<cfif ListFind(variables.configObj.get("langList"), arguments.language) NEQ 0>
			<!--- Persist choice inside cookie --->
			<cfcookie name="lang" value="#arguments.language#" expires="never">
			<cfset variables.lang = arguments.language>
			<cfset initLocal(arguments.language)>
			<cfset setUserLocale()>
		</cfif>
	</cffunction>
	
	<!--- Utility/private methods --->
	
	<cffunction name="initLocal" access="private" output="false" returntype="void" hint="Inizialize localized CFC">
		<cfargument name="lang" type="string" required="yes" hint="Language abbreviation">
		<cfscript>
		var langFile = "#variables.rootPath#config/local_#arguments.lang#.cfm";
		variables.localObj = variables.localObj.init(variables.fileObj, langFile);
		</cfscript>
	</cffunction>
	
	<cffunction name="initLanguage" access="private" output="false" returntype="void" hint="Inizialize user's language">
		<!--- If no cookie is set yet, try to guess a good default --->
		<cfset var default = getBrowserLang(variables.configObj.get("langList"), variables.configObj.get("langDefault"))>
		<cfparam name="cookie.lang" default="#default#">
		<cfset setLanguage(default)>
	</cffunction>
	
	<cffunction name="getBrowserLang" access="private" output="false" returntype="string" hint="Check the HTTP request to see if the browser accept one of the allowed languages">
		<cfargument name="langList" type="string" required="yes" hint="List of allowed languages">
		<cfargument name="defaultLang" type="string" required="yes" hint="Default language">
		<cfset var i = "">
		<cfset var returnLang = arguments.defaultLang>
		<cfloop index="i" list="#arguments.langList#">
			<cfif ListFind(cgi.http_accept_language, i, ",-;")>
				<cfset returnLang = i>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfreturn returnLang>
	</cffunction>

</cfcomponent>