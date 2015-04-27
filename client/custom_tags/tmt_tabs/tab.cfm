<cfsilent>
<!--- Ensure this file gets compiled using iso-8859-1 charset --->
<cfprocessingdirective pageencoding="iso-8859-1">
<!--- 
/**
* ColdFusion custom tag: "tab"
  Must be contained inside "tabgroup".
  Each instance of this tag creates a tab and its panel.
  The tag requires ColdFusion Server 6.1 or more. 
* Copyright © 2005-2008 Massimocorner.com 
* @author       Massimo Foti (massimo@massimocorner.com)
* @version      3.0, 2008-05-21
* @param        label         Optional. Text for the tab's label. Default to "Tab"
* @param        class         Optional. The class attribute of the <a> tag. Default to "tmtTab"
* @param        id            Optional. The id attribute of the <a> tag. Default to none
* @param        title         Optional. The title attribute of the <a> tag. Default to none
 */
--->
<cfif thisTag.executionMode IS "end">
	<!--- Be sure the tag is properly nested --->
	<cftry>
		<!--- Look for the parent tag --->
		<cfset ancestorTag=GetBaseTagData("cf_tabgroup")>
		<cfcatch type="any">
			<cfthrow message="Tag tab must be contained inside a tabgroup tags" type="tab">
		</cfcatch>
	</cftry>
	<cfassociate baseTag="cf_tabgroup" dataCollection="tabsData">
	<cfparam name="attributes.label" type="string" default="Tab">
	<cfparam name="attributes.class" type="string" default="tmtTab">
	<cfparam name="attributes.id" type="string" default="">
	<cfparam name="attributes.title" type="string" default="">
	
	<!--- We don't want to output from this tag, output will be handled by parent tag --->
	<cfset attributes.panelContent = thisTag.generatedContent>
	<cfset thisTag.generatedContent="">

</cfif>
</cfsilent>