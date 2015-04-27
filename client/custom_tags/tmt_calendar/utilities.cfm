<cfprocessingdirective pageencoding="utf-8">

<cffunction name="tableHeaderHTML" returntype="string" output="no">
	<cfargument name="startDate" type="date" required="yes">
	<cfset var i = "">
	<!--- Let's use an hack, start with a day we know was sunday --->
	<cfset var firstDay = CreateDate(2000, 1, 2)>
	<cfset var htmlStr = "">
	<cfsavecontent variable="htmlStr">
		<cfoutput>
		<caption>#LSDateFormat(arguments.startDate, "mmmm yyyy")#</caption>
		<tr>
		<cfloop index="i" from="1" to="7">
			<th>#LSDateFormat(firstDay, "ddd")#</th>
			<cfset firstDay = DateAdd("d", 1, firstDay)>
		</cfloop>
		</tr>
		</cfoutput>
	</cfsavecontent>
	<cfreturn htmlStr>
</cffunction>

<cffunction name="extractEvent" returntype="array" output="no">
	<cfargument name="events" type="array" required="yes">
	<cfargument name="filterDate" type="date" required="yes">
	<cfset var i = "">
	<cfset var retArray = []>
	<cfloop index="i" from="1" to="#ArrayLen(arguments.events)#">
		<cfif (arguments.events[i].event_start_date LTE arguments.filterDate) AND (arguments.events[i].event_end_date GTE arguments.filterDate)>
			<cfset ArrayAppend(retArray, arguments.events[i])>
		</cfif>
	</cfloop>
	<cfreturn retArray>
</cffunction>

<cffunction name="eventHTML" returntype="string" output="no">
	<cfargument name="events" type="array" required="yes">
	<cfset var i = "">
	<cfset var htmlStr = "">
	<cfsavecontent variable="htmlStr">
		<cfoutput>
		<div class="tmtCalEvents">
		<cfloop index="i" from="1" to="#ArrayLen(arguments.events)#">
			<a class="tmtCalEventLink #arguments.events[i].skin_name#" title="#arguments.events[i].event_title#" href="javascript:;" onclick="tmt.calendar.showDetails(#arguments.events[i].event_id#, '#JSStringFormat(arguments.events[i].event_title)#')">#arguments.events[i].event_title#</a>
		</cfloop>
		</div>
		</cfoutput>
	</cfsavecontent>
	<cfreturn htmlStr>
</cffunction>

<!--- Navbar UDFs --->

<cfscript>
/**
* Converts a structure to a URL query string.
* 
* @param struct      Structure of key/value pairs you want converted to URL parameters 
* @param keyValueDelim      Delimiter for the keys/values. Default is the equal sign (=). 
* @param queryStrDelim      Delimiter separating url parameters. Default is the ampersand (&). 
* @return Returns a string. 
* @author Erki Esken (erki@dreamdrummer.com) 
* @version 1, December 17, 2001
* @version 1.1, December 19, 2008. Modified by Massimo Foti for XHTML compatibility. CF 8+ required
*/
function StructToQueryString(struct) {
	var qstr = "";
	var delim1 = "=";
	var delim2 = "&amp;";
	switch (ArrayLen(Arguments)) {
		case "3":
			delim2 = Arguments[3];
		case "2":
			delim1 = Arguments[2];
	}
	for (key in struct) {
		qstr &= URLEncodedFormat(LCase(key)) & delim1 & URLEncodedFormat(struct[key]) & delim2;
	}
	return qstr;
}
</cfscript>

<cffunction name="backLinkHTML" returntype="string" output="no">
	<cfargument name="startDate" type="date" required="yes">
	<cfargument name="linkText" type="string" required="yes">
	<cfscript>
	var htmlStr = "";
	var tempScope = StructCopy(url);
	var queryStr = "";
	var linkTitle = "";
	StructInsert(tempScope, "start_month", Month(DateAdd("m", -1, arguments.startDate)), true);
	if(attributes.start_month == 1){
		StructInsert(tempScope, "start_year", Year(DateAdd("y", -1, arguments.startDate)), true);
	}
	else{
		StructInsert(tempScope, "start_year", attributes.start_year, true);
	}
	queryStr = StructToQueryString(tempScope);
	linkTitle = MonthAsString(tempScope.start_month) & " " & tempScope.start_year;
	</cfscript>
	<cfsavecontent variable="htmlStr">
		<cfoutput>
		<a href="#cgi.script_name#?#queryStr#" title="#linkTitle#">#arguments.linkText#</a>
		</cfoutput>
	</cfsavecontent>
	<cfreturn htmlStr>
</cffunction>

<cffunction name="forwardLinkHTML" returntype="string" output="no">
	<cfargument name="startDate" type="date" required="yes">
	<cfargument name="linkText" type="string" required="yes">
	<cfscript>
	var htmlStr = "";
	var tempScope = StructCopy(url);
	var queryStr = "";
	var linkTitle = "";
	StructInsert(tempScope, "start_month", Month(DateAdd("m", +1, arguments.startDate)), true);
	if(attributes.start_month == 12){
		StructInsert(tempScope, "start_year", attributes.start_year +1, true);
	}
	else{
		StructInsert(tempScope, "start_year", attributes.start_year, true);
	}
	queryStr = StructToQueryString(tempScope);
	linkTitle = MonthAsString(tempScope.start_month) & " " & tempScope.start_year;
	</cfscript>
	<cfsavecontent variable="htmlStr">
		<cfoutput>
		<a href="#cgi.script_name#?#queryStr#" title="#linkTitle#">#arguments.linkText#</a>
		</cfoutput>
	</cfsavecontent>
	<cfreturn htmlStr>
</cffunction>

<cffunction name="monthMenuHTML" returntype="string" output="no">
	<cfargument name="currentMonth" type="numeric" required="yes">
	<cfset var i = "">
	<cfset var htmlStr = "">
	<cfsavecontent variable="htmlStr">
		<cfoutput>
		<select name="start_month" class="tmtCalMonthSelect" onchange="this.form.submit()">
		<cfloop index="i" from="1" to="12">
			<option value="#i#" <cfif i EQ arguments.currentMonth>selected="selected"</cfif>>#MonthAsString(i)#</option>
		</cfloop>
		</select>
		</cfoutput>
	</cfsavecontent>
	<cfreturn htmlStr>
</cffunction>

<cffunction name="yearMenuHTML" returntype="string" output="no">
	<cfargument name="currentYear" type="numeric" required="yes">
	<cfset var i = "">
	<cfset var htmlStr = "">
	<cfsavecontent variable="htmlStr">
		<cfoutput>
		<select name="start_year" class="tmtCalYearSelect" onchange="this.form.submit()">
		<cfloop index="i" from="#(arguments.currentYear -5)#" to="#(arguments.currentYear +5)#">
			<option value="#i#" <cfif i EQ arguments.currentYear>selected="selected"</cfif>>#i#</option>
		</cfloop>
		</select>
		</cfoutput>
	</cfsavecontent>
	<cfreturn htmlStr>
</cffunction>

<cffunction name="categoryMenuHTML" returntype="string" output="no">
	<cfargument name="catQuery" type="query" required="yes">
	<cfset var htmlStr = "">
	<cfsavecontent variable="htmlStr">
		<select name="cat_id" class="tmtCalCatSelect" onchange="this.form.submit()">
			<option value=""><cfoutput>#request.localObj.get("calLabelAllCategories")#</cfoutput></option>
		<cfoutput query="arguments.catQuery">
			<option value="#arguments.catQuery.cat_id#" <cfif arguments.catQuery.cat_id EQ attributes.cat_id>selected="selected"</cfif>>#arguments.catQuery.cat_name#</option>
		</cfoutput>
		</select>
	</cfsavecontent>
	<cfreturn htmlStr>
</cffunction>