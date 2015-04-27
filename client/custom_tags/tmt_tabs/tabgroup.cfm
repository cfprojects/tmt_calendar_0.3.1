<cfsetting enablecfoutputonly="yes">

<!--- Ensure this file gets compiled using iso-8859-1 charset --->
<cfprocessingdirective pageencoding="iso-8859-1">
<!--- 
/**
* ColdFusion custom tag: "tabgroup"
  Must be used as a container for the "tab" tags.
  Display a minimalist, CSS based, DHTML tab GUI. 
  The output is fully XHTML complainant and works fine if served using an XHTML mime-type.
  The tag requires ColdFusion Server 6.1 or more. 
  The tab has been tested with IE 5+ (Win), Mozilla 1.x and Safari 1.x
* Copyright © 2005-2008 Massimocorner.com 
* @author       Massimo Foti (massimo@massimocorner.com)
* @version      3.0, 2008-05-21
* @param        css          Optional. The name of CSS file. Default to "system.css"
* @param        class        Optional. The class attribute of the <div> tag. Default to "tmtTabGroup"
* @param        id           Optional. The id attribute of the <div> tag. Default to none
* @param        selectedtab  Optional. The index of the tab that will be selected after loading the page. Default to 1
* @param        includefiles Optional. Set it to false if the tag should not include JavaScript/CSS, 
                             and prefer to control yourself the way .js and .css files are included in the page. Default to true
* @param        form         Optional. Set this to true if you want to enable integration with TMT Validator. Default to false
* @param        formcallback Optional. Specify the name of a custom JavaScript function that will handle error notification.
                             By default JavaScript alert boxes are used. You can also use the built-in tmt.validator.multiSectionBoxCallback.
                             Requires form="true". Default to false
* @param        width        Optional. The width in pixel of menu. 
                             It's better practice to avoid using this attribute and define dimensions inside the CSS file instead.
                             Default to none
*/
--->
<cfif thisTag.executionMode IS "start">
	<cfinclude template="getRelativePath.cfm">
	<cfparam name="attributes.css" type="string" default="system.css">
	<cfparam name="attributes.class" type="string" default="tmtTabGroup">
	<cfparam name="attributes.id" type="string" default="tabs">
	<cfparam name="attributes.width" type="numeric" default="0">
	<cfparam name="attributes.includefiles" type="boolean" default="true">
	<cfparam name="attributes.form" type="boolean" default="false">
	<cfparam name="attributes.formcallback" type="string" default="">
	<cfparam name="attributes.selectedtab" type="numeric" default="1">
	<!--- Here we store all data from child tags --->
	<cfparam name="thisTag.tabsData" default="#arrayNew(1)#">
	
	<cfscript>
	// Initialize the struct that contains info about the tag
	if(NOT StructKeyExists(request, "tmt_tab")){
		request.tmt_tab = StructNew();
		request.tmt_tab.externalFiles = false;
		request.tmt_tab.validatorFiles = false;
	}
	// External JS and CSS
	localPath = GetDirectoryFromPath(getRelativePath(GetBaseTemplatePath(), GetCurrentTemplatePath()));
	includeStr = "";
	if(attributes.includefiles EQ true){
		if(request.tmt_tab.externalFiles EQ false){
			includeStr = includeStr & '<link rel="stylesheet" type="text/css" href="#localPath#css/#attributes.css#" />' & chr(13) & chr(10);
			includeStr = includeStr & '<script type="text/javascript" src="#localPath#tmt_core.js"></script>' & chr(13) & chr(10);
			includeStr = includeStr & '<script type="text/javascript" src="#localPath#tmt_css.js"></script>' & chr(13) & chr(10);
			includeStr = includeStr & '<script type="text/javascript" src="#localPath#tmt_tabs.js"></script>' & chr(13) & chr(10);
			request.tmt_tab.externalFiles = true;
		}
		if(attributes.form EQ true){
			if(request.tmt_tab.validatorFiles EQ false){
				includeStr = includeStr & '<script type="text/javascript" src="#localPath#tmt_form.js"></script>' & chr(13) & chr(10);
				includeStr = includeStr & '<script type="text/javascript" src="#localPath#tmt_validator.js"></script>' & chr(13) & chr(10);
				request.tmt_tab.validatorFiles = true;
			}
		}
	}
	</cfscript>
	<!--- Ensure CSS file is there --->
	<cfif NOT FileExists(ExpandPath("#localPath#css/#attributes.css#"))>
		<cfthrow message="tabgroup: unable to locate CSS file at #localPath#css/#attributes.css#" type="tabgroup">
	</cfif>
	<!--- Link to external files directely inside the head --->
	<cfif includeStr NEQ "">
		<cfhtmlhead text="#includeStr#">
	</cfif>
</cfif>

<cfif thisTag.executionMode IS "end">

	<cfscript>
	// HTML attributes
	classStr = "";
	idStr = "";
	styleStr = "";
	if(attributes.class NEQ ""){
		classStr = ' class="#attributes.class#"';
	}
	if(attributes.id NEQ ""){
		idStr = ' id="#attributes.id#"';
	}
	if(attributes.width NEQ 0){
		styleStr = ' style="width: #attributes.width#px;"';
	}
	</cfscript>

	<!--- Ensure selectedtab is in range --->
	<cfif (attributes.selectedtab GT arrayLen(thisTag.tabsData)) OR (attributes.selectedtab LT 1)>
		<cfthrow message="tabgroup: selectedtab attribute is out of range" type="tabgroup">
	</cfif>
	
	<cfoutput>
	<div#classStr##idStr# tmt:tabgroup="true" <cfif attributes.form EQ true>tmt:tabform="true"</cfif> <cfif attributes.formcallback NEQ "">tmt:tabformcallback="#attributes.formcallback#"</cfif>>
		<div class="tmtTabs">
		<!--- Print tabs from child tags --->
		<cfloop index="i" from="1" to="#arrayLen(thisTag.tabsData)#">
			<cfscript>
			classStr = "";
			idStr = "";
			titleStr = "";
			if(thisTag.tabsData[i].class NEQ ""){
				if(i EQ attributes.selectedtab){
					// This tab should be visible by default
					classStr = ' class="tmtTabSelected #thisTag.tabsData[i].class#"';
				}
				else{
					classStr = ' class="#thisTag.tabsData[i].class#"';
				}
			}
			if(thisTag.tabsData[i].id NEQ ""){
				idStr = ' id="#thisTag.tabsData[i].id#"';
			}
			if(thisTag.tabsData[i].title NEQ ""){
				titleStr = ' title="#thisTag.tabsData[i].title#"';
			}
			</cfscript>
			<a href="javascript:;" #classStr##idStr##titleStr#>#thisTag.tabsData[i].label#</a>
		
		</cfloop>
		</div>
		<div class="tmtPanelGroup"#styleStr#>
			<!--- Print panels from child tags --->
			<cfloop index="i" from="1" to="#arrayLen(thisTag.tabsData)#">
				<!--- First panel should be visible by default --->
				<cfif i EQ attributes.selectedtab>
					<div class="tmtPanel" tmt:tabpanel="true" style="display:block;">
					#thisTag.tabsData[i].panelContent#
					</div>
				<cfelse>
					<div class="tmtPanel" tmt:tabpanel="true">
					#thisTag.tabsData[i].panelContent#
					</div>
				</cfif>
			</cfloop>
		</div>
	</div>
	</cfoutput>
	
</cfif>
<cfsetting enablecfoutputonly="false">