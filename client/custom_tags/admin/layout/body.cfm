<cfprocessingdirective pageencoding="utf-8">

<cfimport taglib="../../tmt_heartbeat/" prefix="tmt">

<cfparam name="attributes.title" default="Admin - #request.localObj.get("pageTitle")#">
<cfparam name="attributes.isReport" default="false" type="boolean">
<cfparam name="attributes.useModalFrame" default="true" type="boolean">
<cfparam name="attributes.hideMenu" default="false" type="boolean">

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
<link type="text/css" rel="stylesheet" href="#request.pathToRoot#css/admin.css" />
<link type="text/css" rel="stylesheet" href="#request.pathToRoot#css/form.css" />
<link type="text/css" rel="stylesheet" href="#request.pathToRoot#css/menubar_silver.css" />
<script type="text/javascript" src="#request.pathToRoot#javascript/SpryMenuBar.js"></script>
<!--- TMT Validator and Ajaxform includes --->
<script type="text/javascript" src="#request.pathToRoot#javascript/tmt_core.js"></script>
<script type="text/javascript" src="#request.pathToRoot#javascript/tmt_net.js"></script>
<script type="text/javascript" src="#request.pathToRoot#javascript/tmt_form.js"></script>
<script type="text/javascript" src="#request.pathToRoot#javascript/tmt_validator.js"></script>
<script type="text/javascript" src="#request.pathToRoot#javascript/tmt_ajaxform.js"></script>
<cfif attributes.isReport>
	<script type="text/javascript" src="#request.pathToRoot#javascript/xpath.js"></script>
	<script type="text/javascript" src="#request.pathToRoot#javascript/SpryData.js"></script>
	<script type="text/javascript" src="#request.pathToRoot#javascript/SpryPagedView.js"></script>
	<script type="text/javascript" src="#request.pathToRoot#javascript/tmt_spry_pagingbar.js"></script>
<cfelse>
	<script type="text/javascript" src="#request.pathToRoot#javascript/admin/dialogs.js"></script>
</cfif>
<cfif attributes.useModalFrame>
	<link type="text/css" rel="stylesheet" href="#request.pathToRoot#javascript/jquery-ui-theme.css" />
	<script type="text/javascript" src="#request.pathToRoot#javascript/jquery.js"></script>
	<script type="text/javascript" src="#request.pathToRoot#javascript/jquery-ui-modalframe.js"></script>
	<script type="text/javascript" src="#request.pathToRoot#javascript/tmt_jquery_modalframe.js"></script>
</cfif>
</cfoutput>
</head>
<body>
<tmt:heartbeat />
<div id="container">
	<cfif NOT StructKeyExists(url, "excel") AND (attributes.hideMenu EQ false)>
		<div id="menu">
		<cfinclude template="menu.cfm">
		</div>
	</cfif>
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