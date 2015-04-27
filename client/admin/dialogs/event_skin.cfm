<cfprocessingdirective pageencoding="utf-8">
<cfimport taglib="../../custom_tags/admin/layout/" prefix="layout">
<cfparam name="url.task" default="insert">

<!--- If update, fetch data, else use empty record to populate form --->
<cfif url.task EQ "update">
	<cfparam name="url.id" type="integer">
	<cfset record = request.calendarObj.getSkins(url.id)>
<cfelse>
	<cfset record = QueryNew("skin_name")>
</cfif>

<layout:body hideMenu="true">
	
	<form method="post" tmt:validate="true" tmt:callback="tmt.validator.errorBoxCallback" action="../controller_calendar.cfm">
		<table>
			<cfoutput>
			<tr>
				<td>Name:</td>
				<td>
				<input name="skin_name" value="#record.skin_name#" type="text" maxlength="50" class="required" tmt:required="true" tmt:errorclass="invalid" tmt:message="Please insert a name" />
				</td>
			</tr>
			<tr>
				<td></td>
				<td><input type="submit" value="<cfoutput>#url.task#</cfoutput>" /></td>
			</tr>
			</cfoutput>
		</table>
		<cfif url.task EQ "update">
			<input name="skin_id" type="hidden" value="<cfoutput>#url.id#</cfoutput>" />
		</cfif>
		<input name="task" type="hidden" value="<cfoutput>#url.task#</cfoutput>" />
		<input name="type" type="hidden" value="skin" />
	</form>

</layout:body>