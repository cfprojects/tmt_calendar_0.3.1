<cfprocessingdirective pageencoding="utf-8">
<cfparam name="attributes.title" default="#request.localObj.get("pageTitle")#">
<cfparam name="attributes.isForm" default="false" type="boolean">

<cfif thisTag.executionMode IS "start">
<!--- 
Custom tags that are application-specific, like this, don't need to preserve encapsulation, because they will not be reused, 
so they are free to use the caller or request scope. 
 --->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<cfoutput>
<title>#attributes.title#</title>
<link type="text/css" rel="stylesheet" href="#request.pathToRoot#css/base.css" media="screen" />
<link type="text/css" rel="stylesheet" href="#request.pathToRoot#css/form.css" />
<cfif attributes.isForm>
	<!--- validator's includes --->
	<script type="text/javascript" src="#request.pathToRoot#javascript/tmt_core.js"></script>
	<script type="text/javascript" src="#request.pathToRoot#javascript/tmt_net.js"></script>
	<script type="text/javascript" src="#request.pathToRoot#javascript/tmt_form.js"></script>
	<script type="text/javascript" src="#request.pathToRoot#javascript/tmt_validator.js"></script>
</cfif>
</cfoutput>
</head>
<body>

<div id="container">
	<div id="navBar">
		<cfoutput>
		<a href="http://tmt_calendar.riaforge.org/">RIAForge</a> |
		<a href="#request.pathToRoot#">Home</a> |
		<a href="#request.pathToRoot#calendar/">Calendar</a> |
		<a href="#request.pathToRoot#admin/reports/events.cfm">Admin</a>
		</cfoutput>
	</div>
	<div id="content">
</cfif>
<!--- Close page --->
<cfif thisTag.executionMode IS "end">
	</div>
	<div id="footer"></div>
</div>
</body>
</html>
</cfif>