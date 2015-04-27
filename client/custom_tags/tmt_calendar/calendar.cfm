<cfprocessingdirective pageencoding="utf-8">

<cfparam name="attributes.calendarObj">
<cfparam name="attributes.start_year" default="#Year(Now())#" type="integer">
<cfparam name="attributes.start_month" default="#Month(Now())#" type="range" min="1" max="12">
<cfparam name="attributes.cat_id" default="">
<cfparam name="attributes.backlink" default="&lt;&lt;">
<cfparam name="attributes.forwardlink" default="&gt;&gt;">
<cfparam name="attributes.includefiles" type="boolean" default="true">
<cfparam name="attributes.modalframebase" default="#request.pathToRoot#javascript/">
<cfparam name="attributes.modalframewidth" default="370" type="integer">
<cfparam name="attributes.modalframeheight" default="400" type="integer">

<cfif thisTag.executionMode IS "end">
	<cfexit>
</cfif>

<!--- Include UDFs --->
<cfinclude template="getRelativePath.cfm">
<cfinclude template="utilities.cfm">

<cfscript>
// Querystring overwrites attributes
if(StructKeyExists(url, "start_year") AND IsNumeric(url.start_year)){
	attributes.start_year = url.start_year;
}
if(StructKeyExists(url, "start_month") AND IsNumeric(url.start_month)){
	attributes.start_month = url.start_month;
}
if(StructKeyExists(url, "cat_id") AND IsNumeric(url.cat_id)){
	attributes.cat_id = url.cat_id;
}
// Figure out the relative path to dependant files
dependantPath = GetDirectoryFromPath(getRelativePath(GetBaseTemplatePath(), GetCurrentTemplatePath()));
includeStr = "";
if(attributes.includefiles EQ true){
	includeStr &= '' & chr(13) & chr(10);
	includeStr &= '<link rel="stylesheet" type="text/css" href="#dependantPath#css/calendar.css" />' & chr(13) & chr(10);
	includeStr &= '<link rel="stylesheet" type="text/css" href="#dependantPath#css/skins.css" />' & chr(13) & chr(10);
	includeStr &= '<link rel="stylesheet" type="text/css" href="#attributes.modalframebase#jquery-ui-theme.css" />' & chr(13) & chr(10);
	includeStr &= '<script type="text/javascript" src="#attributes.modalframebase#jquery.js"></script>' & chr(13) & chr(10);
	includeStr &= '<script type="text/javascript" src="#attributes.modalframebase#jquery-ui-modalframe.js"></script>' & chr(13) & chr(10);
	includeStr &= '<script type="text/javascript" src="#attributes.modalframebase#tmt_jquery_modalframe.js"></script>' & chr(13) & chr(10);
}
// Calculate starting dates
startDate = CreateDate(attributes.start_year, attributes.start_month, 1);
endDate = DateAdd("d", -1, DateAdd("m", 1, startDate));
startDateDigit = DayOfWeek(startDate);
// Get event's data from the CFC
searchCriteria = {is_visible = true, start_date = startDate, end_date = endDate, cat_id = attributes.cat_id};
events = attributes.calendarObj.getEvents(searchCriteria);
</cfscript>

<!--- Link to external files directly inside the head --->
<cfif includeStr NEQ "">
	<cfhtmlhead text="#includeStr#">
</cfif>

<cfoutput>

<script type="text/javascript">
if (typeof(tmt) == "undefined"){
	tmt = {};
}
tmt.calendar = {};

// Open details dialog in modalframe
tmt.calendar.showDetails = function(id, title){
	var frameUrl = "#dependantPath#event.cfm?id=" + id;
	tmt.jquery.modalframe.open(frameUrl, {title: title, height: #attributes.modalframeheight#, width: #attributes.modalframewidth#});
}
</script>

<div class="tmtCal">

	<table class="tmtCalTable">
	<!--- Print header --->
	#tableHeaderHTML(startDate)#
	<!--- Keep writing empty cells until we find the first sunday --->
	<cfif startDateDigit NEQ 1>
			<tr>
		<cfloop index="h" from="1" to="#DayOfWeek(startDate)-1#">
			<td class="tmtCalEmptyCell">&nbsp;</td>
		</cfloop>
	</cfif>
	<!--- 
	Loop over the dates. We start with the current row, keep printing until we reach the end of the month
	--->
	<cfset currentDate = startDate>
	<cfset closeTableRow = false>
	<cfloop index="i" from="1" to="#DaysInMonth(startDate)#">
		<!--- As soon as we hit a sunday, add another row --->
		<cfif DayOfWeek(currentDate) EQ 1>
			<tr>
		</cfif>
		<td class="tmtCalDayCell">
			<!--- Print the day --->
			<div class="tmtCalDay">#Day(currentDate)#</div>
			<!--- Get's events for this day (if any) --->
			<cfset todayEvents = extractEvent(events, currentDate)>
			<!--- Print links to events --->
			<cfoutput>#eventHTML(todayEvents)#</cfoutput>
		</td>
		<!--- If we reached the last day of the month, keep writing empty cells --->
		<cfif i EQ DaysInMonth(startDate)>
			<cfloop index="h" from="1" to="#7-DayOfWeek(currentDate)#">
				<td class="tmtCalEmptyCell">&nbsp;</td>
				<cfset closeTableRow = true>
			</cfloop>
		</cfif>
		<!--- If it's saturday, close the row --->
		<cfif DayOfWeek(currentDate) EQ 7>
			</tr>
		</cfif>
		<cfset currentDate = DateAdd("d", i, startDate)>
	</cfloop>
		<cfif closeTableRow EQ true>
			</tr>
		</cfif>
	</table>
	
	<!--- Start navbar --->
	
	<div class="tmtCalNavbar">
	<form action="#cgi.script_name#">
	<table>
		<tr>
			<td class="tmtCalNavbarBack">#backLinkHTML(startDate, attributes.backlink)#</td>
			<td class="tmtCalMenuCell">
			#monthMenuHTML(attributes.start_month)#
			#yearMenuHTML(attributes.start_year)#
			#categoryMenuHTML(attributes.calendarObj.getCategories())#
			</td>
			<td class="tmtCalNavbarBackForward">#forwardLinkHTML(startDate, attributes.forwardlink)#</td>
		</tr>
	</table>
	</form>
	</div>
	
	<!--- End navbar --->

</div>

</cfoutput>