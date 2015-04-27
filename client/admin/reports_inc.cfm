<!--- Generate XML --->
<cfif StructKeyExists(url, "getxml")>
	<!--- Marshall the query into XML --->
	<cfset xmlStr = request.spryObj.toXML(reportData)>
	<!--- Set the correct mime-type --->
	<cfcontent type="application/xml; charset=utf-8">
	<!--- Reset the HTTP stream to avoid generating whitespace before the XML declaration --->
	<cfcontent reset="yes"><?xml version="1.0" encoding="utf-8"?>
	<cfoutput>#xmlStr#</cfoutput>
</cfif>

<!--- Generate CSV --->
<cfif StructKeyExists(url, "getcsv")>
	<!--- Marshall the query into CSV --->
	<cfset csvStr = request.csvObj.query2CSV(reportData)>
	<!--- Set the correct mime-type --->
	<cfheader name="Content-Disposition" value="attachment; filename=#url.report#.csv">
	<cfcontent type="text/csv">
	<cfoutput>#csvStr#</cfoutput>
</cfif>