<cfprocessingdirective pageencoding="utf-8">
<cfimport taglib="../../custom_tags/admin/layout/" prefix="layout">
<cfparam name="url.task" default="insert">

<layout:body title="Attachment insert" isDialog="true" hideMenu="true">
	<cfoutput>
	<form method="post" enctype="multipart/form-data" tmt:validate="true" tmt:callback="tmt.validator.errorBoxCallback" action="../controller_calendar.cfm">
		<table>
			<tr>
				<td>File (max #request.calendarObj.getMaxAttachmentsSize()# Kb):</td>
				<td><input type="file" name="attach_filename" tmt:required="true" tmt:errorclass="invalid" tmt:message="Please select an attachment" tmt:pattern="filepath" /></td>
			</tr>
			<tr>
				<td>Description:</td>
				<td>
				<input name="attach_description" type="text" maxlength="100" tmt:required="true" tmt:errorclass="invalid" tmt:message="Please enter a description" />
				</td>
			</tr>
			<tr>
				<td></td>
				<td><input type="submit" value="#url.task#" /></td>
			</tr>
		</table>
		<input name="event_id" type="hidden" value="#url.event_id#" />
		<input name="lang_abbrev" type="hidden" value="#url.lang#" />
		<input name="task" type="hidden" value="#url.task#" />
		<input name="type" type="hidden" value="eventAttachment" />
	</form>
	</cfoutput>
</layout:body>