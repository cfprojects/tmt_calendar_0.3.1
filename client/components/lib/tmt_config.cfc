<cfcomponent output="false" hint="Stateful component that stores configuration and GUI settings">

	<cfprocessingdirective pageencoding="iso-8859-1">
	<cfset variables.fileObj = "">
	<cfset variables.filePath = "">
	<cfset variables.xmlDOM = "">
	
	<cffunction name="init" access="public" output="false" returntype="tmt_config" hint="Pseudo-constructor">
		<cfargument name="fileObj" hint="An instance of tmt_file_io.cfc">
		<cfargument name="filePath" type="string" hint="Absolute path to the XML file storing strings">
		<cfset variables.fileObj = arguments.fileObj>
		<cfset variables.filePath = arguments.filePath>
		<cfset loadXML()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="get" access="public" output="false" returntype="string" hint="Returns the value associated with the specified key">
		<cfargument name="key" type="string" required="yes" hint="The Key whose associated value is to be returned">
		<cfargument name="throw" type="boolean" required="no" default="false" hint="Set this to true if you want to throw an exception for a missing key">
		<cfset var prefValue = "">
		<cfset var xpathStr = "//param[@name='#arguments.key#']/">
		<cfset var nodeList = "">
		<cfset nodeList = XmlSearch(variables.xmlDOM, xpathStr)>
		<!--- The string is missing from XML --->
		<cfif ArrayLen(nodeList) EQ 0>
			<cfif arguments.throw>
				<!--- The value is missing and we don't want to try any further. Throw an exception --->
				<cfthrow message="tmt_config.cfc: The string #arguments.key# is not available inside current configuration file" type="tmt_config">
			<cfelse>
				<!--- Try again, just reload the XML first --->
				<cfset loadXML()>
				<cfreturn get(arguments.key, true)>
			</cfif>
		</cfif>
		<!--- There should be only one XML element for the data (unless the XML is messed up) --->
		<cfif ArrayLen(nodeList) NEQ 1>
			<cfthrow message="tmt_config.cfc: Error reading configuration file (key = #arguments.key#). Data may be duplicated or redundant" type="tmt_config">
		</cfif>
		<!--- Return the data (as string) --->
		<cfreturn nodeList[1].XmlText>
	</cffunction>
	
	<cffunction name="loadXML" access="private" output="false" hint="Load the XML nodes in memory, as instance data">
		<cftry>
			<!--- Load the XML data inside instance variable --->
			<cfset variables.xmlDOM = variables.fileObj.readFile(variables.filePath)>
			<cfcatch type="any">
				<!--- Catch any issue related to XML parsing --->
				<cfthrow message="tmt_config.cfc: Unable to load XML data. File #variables.filePath# may be missing, corrupted or not well-formed" type="tmt_config" detail="#cfcatch.detail#">
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>