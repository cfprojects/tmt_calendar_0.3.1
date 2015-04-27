<cfprocessingdirective pageencoding="utf-8">
<cfimport taglib="../../custom_tags/admin/layout/" prefix="layout">
<cfimport taglib="../../custom_tags/tmt_tabs/" prefix="tmt">
<cfparam name="url.task" default="insert">

<!--- If update, fetch data, else use empty record to populate form --->
<cfif url.task EQ "update">
	<cfparam name="url.id" type="integer">
	<cfset record = request.calendarObj.getMetaCategory(url.id)>
<cfelse>
	<cfset record = QueryNew("cat_sort_order")>
</cfif>

<layout:body hideMenu="true">

<script type="text/javascript">
function deleteRecord(formNode, id, lang){
	var controllerUrl = "../controller_calendar.cfm?task=deleteLocalCategory&id=" + id + "&lang_abbrev=" + lang;
	tmt.net.httpRequest({url: controllerUrl, loadCallback: function(){
		var fields = [formNode.elements["cat_name"]];
		tmt.form.clearFields(fields);
		tmt.form.displayMessage(formNode, "Record deleted");
	}});
}
</script>

<tmt:tabgroup id="mainTab" css="admin.css">
	
	<tmt:tab label="Category" title="Category details">
	<form method="post" action="../controller_calendar.cfm" tmt:validate="true" tmt:callback="tmt.validator.errorBoxCallback" <cfif url.task EQ "update">tmt:blocksubmit="false" tmt:ajaxform="true"</cfif>>
		<table>
			<cfoutput>
			<tr>
				<td>Sort order:</td>
				<td>
				<input name="cat_sort_order" value="#record.cat_sort_order#" type="text" maxlength="2" class="required" tmt:required="true" tmt:pattern="positiveinteger" tmt:errorclass="invalid" tmt:message="Please insert a an integer" />
				</td>
			</tr>
			<tr>
				<td></td>
				<td><input type="submit" value="<cfoutput>#url.task#</cfoutput>" /></td>
			</tr>
			</cfoutput>
		</table>
		<cfif url.task EQ "update">
			<input name="cat_id" type="hidden" value="<cfoutput>#url.id#</cfoutput>" />
		</cfif>
		<input name="task" type="hidden" value="<cfoutput>#url.task#</cfoutput>" />
		<input name="type" type="hidden" value="metaCategory" />
	</form>
	</tmt:tab>
	
	<cfif url.task EQ "update">
		<cfset languages = request.calendarObj.getLanguages()>
		<cfloop query="languages">
			
			<cfset record = request.calendarObj.getCategory(url.id, languages.lang_abbrev)>
			<tmt:tab label="#languages.lang_name#" title="#languages.lang_name#">
			<cfoutput>
			<form method="post" action="../controller_calendar.cfm" id="#languages.lang_name#" tmt:validate="true" tmt:callback="tmt.validator.errorBoxCallback" tmt:blocksubmit="false" tmt:ajaxform="true">
				<table>
					<tr>
						<td>Localized name:</td>
						<td><input type="text" name="cat_name" value="#record.cat_name#" maxlength="50" tmt:required="true" tmt:errorclass="invalid" tmt:message="Please insert a name" class="required" /></td>
					<tr>
						<td></td>
						<td>
							<button onclick="deleteRecord(this.form, '#url.id#', '#languages.lang_abbrev#'); return false">Delete</button>
							<input type="submit" value="#url.task#" />
						</td>
					</tr>
				</table>
				<input name="cat_id" type="hidden" value="#url.id#" />
				<input name="task" type="hidden" value="edit" />
				<input name="type" type="hidden" value="category" />
				<input name="lang_abbrev" type="hidden" value="#languages.lang_abbrev#" />
			</form>
			</cfoutput>
			</tmt:tab>
		</cfloop>
	</cfif>
	
</tmt:tabgroup>

</layout:body>