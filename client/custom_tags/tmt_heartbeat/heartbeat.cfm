<cfsilent>
<!--- Ensure this file gets compiled using iso-8859-1 charset --->
<cfprocessingdirective pageencoding="iso-8859-1">
<!--- 
/**
* ColdFusion custom tag: "heartbeat"
  This tag implements the Heartbeat pattern for Ajax: http://ajaxpatterns.org/Heartbeat
  The tag output JavaScript code that periodically perform an HTTP request to indicate the application is still loaded in the browser and the user is still active
 
  The tag requires ColdFusion Server 6.1 or more. 
  
* @author       Massimo Foti (massimo@massimocorner.com)
* @version      1.1.2, 2007-02-21
* @param        url              Optional. Address of the page on the server which will handle the request. Default to the current page
* @param        interval         Optional. The interval among HTTP requests (minutes). Default to 5
 */
--->
<cfif thisTag.executionMode IS "end">
	<cfexit>
</cfif>

<cfparam name="attributes.url" type="string" default="#cgi.script_name#?#cgi.query_string#">
<cfparam name="attributes.interval" type="numeric" default="5">

<cfinclude template="getRelativePath.cfm">

<!--- Logic --->
<cfscript>
// Paths
localPath = GetDirectoryFromPath(getRelativePath(GetBaseTemplatePath(),GetCurrentTemplatePath()));
jsPath = localPath & "tmt_net.js";
// HTML tags
headCode = '<script src="#jsPath#" type="text/javascript"></script>' & chr(13) & chr(10);
// Initialize the flag inside the request scope
if(NOT StructKeyExists(request, "tmt_heartbeat")){
	request.tmt_heartbeat = StructNew();
}
milliSeconds = attributes.interval * 60000;	
</cfscript>

<!--- Check the flag in order to insert the relevant JavaScript code directely inside the head just one time --->
<cfif NOT StructKeyExists(request.tmt_heartbeat, "headCode")>
	<cfhtmlhead text="#headCode#">
	<cfset request.tmt_heartbeat.headCode=true>
</cfif>

<!--- Inline JavaScript code --->
<cfsavecontent variable="inlineJs">
	<cfoutput>
	<script type="text/javascript">
	tmt.net.heartbeat = function(){  
		tmt.net.httpRequest("#attributes.url#", function(){});
	}
	setInterval(tmt.net.heartbeat, #milliSeconds#);
	</script>
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#inlineJs#">

</cfsilent>