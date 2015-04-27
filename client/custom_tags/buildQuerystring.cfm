<cffunction name="buildQuerystring" output="false" returntype="string">
	<cfargument name="name" type="string" required="true">
	<cfargument name="value" type="string" required="true">
	<cfset var x = "">
	<cfset var retString = "#arguments.name#=#arguments.value#&amp;">
	<cfset var getVars = Duplicate(url)>
	<cfset StructDelete(getVars, arguments.name)>
	<cfloop collection="#getVars#" item="x">
		<cfset retString &= "#LCase(x)#=#getVars[x]#&amp;">
	</cfloop>
	<cfreturn retString>
</cffunction>