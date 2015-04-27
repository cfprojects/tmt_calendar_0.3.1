<cfsilent>
<!--- Ensure this file gets compiled using iso-8859-1 charset --->
<cfprocessingdirective pageencoding="iso-8859-1">
<!--- 
/**
* ColdFusion custom tag: "datepicker"
  It's a CFML wrapper build around the wonderful "DHTML Calendar" created by Mihai Bazon
  Check here for additional details and documentation: http://dynarch.com/mishoo/calendar.epl

  Since this tag is a derivative work of "DHTML Calendar", the same LGPL license must be applied. 
  You can read it here: http://www.gnu.org/licenses/lgpl
  
  We made some minor changes to "DHTML Calendar", reduced the languages supported to four (en, de, fr and it), 
  reworked some CSS file and patched the main JavaScript file in order to make it works even if the file is served using a "application/xhtml+xml" mime-type 
  
  Special thanks to Roger Locatelli 
 
  Each instance of this tag creates a date picker icon
  The date picker GUI will pop up as soon as the user clicks on the icon
  The tag requires ColdFusion Server 6.1 or more. 
* @author       Massimo Foti (massimo@massimocorner.com)
* @version      1.1, 2005-04-05
* @param        inputfield    Required. The id attribute of the target input field
* @param        id            Optional. The id attribute of the icon's <img> tag. Default to "tmt_datepicker"
* @param        class         Optional. The class attribute of the icon's <img> tag. Default to none
* @param        title         Optional. The title attribute of the icon's <img> tag. Default to "Select a Date"
* @param        alt           Optional. The alt attribute of the icon's <img> tag. Default to "Date selection widget"
* @param        css           Optional. Name of the CSS file used. Default to "gray.css"
* @param        lang          Optional. Lang used, either en, de, fr or it. Default to en
* @param        icon          Optional. Name of the .gif file used as icon. Default to "classic"
* @param        dateformat    Optional. The format string that will be used to enter the date in the input field. Default to "%Y-%m-%d" (ISO 8601)
* @param        date          Optional. Define an initial date where the calendar will be positioned to. Default to Now()
* @param        showstime     Optional. If this is set to true then the calendar will also allow time selection. Default to false
* @param        timeformat    Optional. Configure the way time is displayed either 12 or 24. Default to 24

* @param        x             Optional. Specifies the x position, relative to page’s top-left corner, where the calendar will be displayed. 
  If not passed then the position will be computed based on the "align" parameter. 
  Requires y attribute to be specified as well in order to work

* @param        y             Optional. Specifies the y position, relative to page’s top-left corner, where the calendar will be displayed. 
  If not passed then the position will be computed based on the "align" parameter. 
  Requires x attribute to be specified as well in order to work

* @param        align         Optional. Alignment of the calendar, relative to the input field. 
  Vertical alignment
  The first character in "align" can take one of the following values:
  T — completely above the reference element (bottom margin of the calendar aligned to the top margin of the element).
  t — above the element but may overlap it (bottom margin of the calendar aligned to the bottom margin of the element).
  c — the calendar displays vertically centered to the reference element. It might overlap it (that depends on the horizontal alignment).
  b — below the element but may overlap it (top margin of the calendar aligned to the top margin of the element).
  B — completely below the element (top margin of the calendar aligned to the bottom margin of the element).
  Horizontal alignment
  The second character in "align" can take one of the following values:
  L — completely to the left of the reference element (right margin of the calendar aligned to the left margin of the element).
  l — to the left of the element but may overlap it (left margin of the calendar aligned to the left margin of the element).
  c — horizontally centered to the element. Might overlap it, depending on the vertical alignment.
  r — to the right of the element but may overlap it (right margin of the calendar aligned to the right margin of the element).
  R — completely to the right of the element (left margin of the calendar aligned to the right margin of the element).
  Default to "BL"
 */
--->
<cfif thisTag.executionMode IS "end">
	<cfexit>
</cfif>
<!--- The target input field is the only required attribute --->
<cfparam name="attributes.inputfield" type="string">
<!--- XHTML tags related attributes --->
<cfparam name="attributes.id" type="string" default="tmt_datepicker">
<cfparam name="attributes.class" type="string" default="">
<cfparam name="attributes.title" type="string" default="Select a Date">
<cfparam name="attributes.alt" type="string" default="Date selection widget">
<!--- Date picker related attributes --->
<cfparam name="attributes.dateformat" type="string" default="%Y-%m-%d">
<cfparam name="attributes.date" type="date" default="#Now()#">
<cfparam name="attributes.align" type="string" default="BL">
<cfparam name="attributes.showstime" type="boolean" default="false">
<cfparam name="attributes.timeformat" type="numeric" default="24">
<!--- External files/configuration attributes --->
<cfparam name="attributes.css" type="string" default="gray.css">
<cfparam name="attributes.lang" type="string" default="en">
<cfparam name="attributes.icon" type="string" default="classic">

<cfinclude template="getRelativePath.cfm">

<!--- Logic --->
<cfscript>
// Only these four languages are allowed
if(ListFind("en,de,fr,it", attributes.lang) EQ 0){
	attributes.lang = "en";
}
// Paths
localPath = GetDirectoryFromPath(getRelativePath(GetBaseTemplatePath(),GetCurrentTemplatePath()));
cssPath = localPath & "tmt_datepicker/css/" & attributes.css;
jsPath = localPath & "tmt_datepicker/calendar.js";
jsSetUpPath = localPath & "tmt_datepicker/calendar-setup.js";
jsLangPath = localPath & "tmt_datepicker/lang/calendar-" & attributes.lang & ".js";
// HTML tags
headCode = '<script src="#jsPath#" type="text/javascript"></script>' & chr(13) & chr(10);
headCode = headCode & '<script src="#jsSetUpPath#" type="text/javascript"></script>' & chr(13) & chr(10);
headCode = headCode & '<script src="#jsLangPath#" type="text/javascript"></script>' & chr(13) & chr(10);
headCode = headCode & '<link href="#cssPath#" rel="stylesheet" type="text/css" />' & chr(13) & chr(10);

classStr = "";
if(attributes.class NEQ ""){
	classStr = ' class="#attributes.class#"';
}
positionStr = "";
if((StructKeyExists(attributes, "x")) AND (StructKeyExists(attributes, "y"))){
	positionStr = "position: new Array(#attributes.x#, #attributes.y#),";
}
// Only 12 and 24 are allowed, if it's not 12, go back to 24. We can't accept any other value anyway
if(attributes.timeformat NEQ 12){
	attributes.timeformat = 24;
}
// Initialize the flag inside the request scope
if(NOT StructKeyExists(request, "tmt_datepicker")){
	request.tmt_datepicker = StructNew();
}	
</cfscript>
<!--- Check the flag in order to insert the relevant JavaScript code directely inside the head just one time --->
<cfif NOT StructKeyExists(request.tmt_datepicker, "headCode")>
	<cfhtmlhead text="#headCode#">
	<cfset request.tmt_datepicker.headCode=true>
</cfif>
</cfsilent>
<!--- Display --->
<cfoutput>
	<img style="cursor:pointer"#classStr# src="#localPath#tmt_datepicker/icon/#attributes.icon#.gif" id="#attributes.id#" title="#attributes.title#" alt="#attributes.alt#" />
	<script type="text/javascript">
	Calendar.setup({ #positionStr#
		inputField: "#attributes.inputfield#",
		ifFormat: "#attributes.dateformat#",
		align: "#attributes.align#",
		date: new Date(#Year(attributes.date)#, #(Month(attributes.date)-1)#, #Day(attributes.date)#),
		showsTime: #attributes.showstime#,
		timeformat: #attributes.timeformat#,
		button: "#attributes.id#"
	});
	</script>
</cfoutput>