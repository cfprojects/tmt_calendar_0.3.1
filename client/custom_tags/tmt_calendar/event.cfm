<cfprocessingdirective pageencoding="utf-8">
<cfimport taglib="../tmt_tabs/" prefix="tmt">
<cfparam name="url.id" default="0" type="integer">
<cfinclude template="getRelativePath.cfm">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Event details</title>
<link rel="stylesheet" type="text/css" href="css/calendar.css" />
</head>

<body>

<tmt:tabgroup id="mainTab" css="calendar.css">
	
	<tmt:tab label="#request.localObj.get("calLabelEvent")#">
		<cfset record = request.calendarObj.getEventDetail(url.id)>
		<cfoutput>
		<table>
			<tr>
				<td>#request.localObj.get("calLabelCategory")#:</td>
				<td>#record.cat_name#</td>
			</tr>
			<tr>
				<td>#request.localObj.get("calLabelTitle")#:</td>
				<td>#record.event_title#</td>
			</tr>
			<tr>
				<td>#request.localObj.get("calLabelStartDate")#:</td>
				<td>#LSDateFormat(record.event_start_date)#</td>
			</tr>
			<tr>
				<td>#request.localObj.get("calLabelEndDate")#:</td>
				<td>#LSDateFormat(record.event_end_date)#</td>
			</tr>
			<cfif record.event_start_time NEQ "">
			<tr>
				<td>#request.localObj.get("calLabelStartTime")#:</td>
				<td>#record.event_start_time#</td>
			</tr>
			</cfif>
			<cfif record.event_end_time NEQ "">
			<tr>
				<td>#request.localObj.get("calLabelEndTime")#:</td>
				<td>#record.event_end_time#</td>
			</tr>
			</cfif>
			<cfif record.event_location NEQ "">
			<tr>
				<td>#request.localObj.get("calLabelLocation")#:</td>
				<td>#record.event_location#</td>
			</tr>
			</cfif>
			<cfif record.event_description NEQ "">
			<tr>
				<td>#request.localObj.get("calLabelDescription")#:</td>
				<td>#record.event_description#</td>
			</tr>
			</cfif>
			</cfoutput>
		</table>
	</tmt:tab>
	
	<!--- Image section --->
	<cfset images = request.calendarObj.getImages(url.id)>
	<cfset imagesPath = request.pathToRoot & request.calendarObj.getImagesPath()>
	<cfif images.RecordCount NEQ 0>
	<tmt:tab label="#request.localObj.get("calLabelImages")#">
		<table>
			<!--- Display records --->
			<cfoutput query="images">
			<tr>
				<td><img src="#imagesPath##images.img_filename#" /></td>
			</tr>
			<cfif images.img_description NEQ "">
			<tr>
				<td>#images.img_description#</td>
			</tr>
			</cfif>
		</cfoutput>
		</table>
	</tmt:tab>
	</cfif>
	
	<!--- Attachments section --->
	<cfset attachments = request.calendarObj.getAttachments(url.id)>
	<cfset attachmentsPath = request.pathToRoot & request.calendarObj.getAttachmentsPath()>
	<cfif attachments.RecordCount NEQ 0>
	<tmt:tab label="#request.localObj.get("calLabelAttachments")#">
		<table>
		<!--- Display records --->
		<cfoutput query="attachments">
			<tr>
				<td><a href="#attachmentsPath##attachments.attach_filename#" target="_blank">#attachments.attach_description#</a></td>
			</tr>
		</cfoutput>
		</table>
	</tmt:tab>
	</cfif>
	
</tmt:tabgroup>

</body>
</html>