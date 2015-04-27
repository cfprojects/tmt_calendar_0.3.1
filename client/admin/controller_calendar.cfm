<cfprocessingdirective pageencoding="utf-8">
<cfsetting showdebugoutput="false">

<!--- Reports --->
<cfif StructKeyExists(url, "report")>

	<cfif url.report EQ "events">
		<cfset reportData = request.calendarObj.getMeta(url)>
	</cfif>
	<cfif url.report EQ "categories">
		<cfset reportData = request.calendarObj.getMetaCategory()>
	</cfif>
	<cfif url.report EQ "skins">
		<cfset reportData = request.calendarObj.getSkins()>
	</cfif>

	<cfinclude template="reports_inc.cfm">

</cfif>

<!--- POST Tasks --->

<cfif NOT StructIsEmpty(form)>

	<cfif form.type EQ "eventMetadata">
		<cfif form.task EQ "insert">
			<cfset pk = request.calendarObj.insertMeta(form)>
			<!--- Reload the dialog in "update" mode --->
			<cflocation url="dialogs/event.cfm?task=Update&id=#pk#" addtoken="no">
		</cfif>
		<cfif form.task EQ "update">
			<cfset request.calendarObj.updateMeta(form)>
			<cfoutput>#request.configObj.get("updateRecordMSG")#</cfoutput>
		</cfif>
	</cfif>
	
	<cfif form.type EQ "event">
		<cfif form.task EQ "edit">
			<cfset request.calendarObj.editEvent(form)>
			<cfoutput>#request.configObj.get("updateRecordMSG")#</cfoutput>
			<cfabort>
		</cfif>
		<cfif form.task EQ "deleteImage">
			<cfset request.calendarObj.deleteImage(form.img_id)>
		</cfif>
		<cfif form.task EQ "deleteAttachment">
			<cfset request.calendarObj.deleteAttachment(form.attach_id)>
		</cfif>
		<!--- Close the modalFrame --->
		<script type="text/javascript">
		if(parent){
			parent.frameCallback();
		}
		</script>
	</cfif>
	
	<cfif form.type EQ "eventImage">
		<cfif form.task EQ "insert">
			<!--- Upload, resize and insert inside db --->
			<cfset request.calendarObj.insertImage(form)>
		</cfif>
		<!--- Close the modalFrame (if any) --->
		<script type="text/javascript">
		if(parent){
			parent.tmt.jquery.modalframe.refreshOpener();
			parent.tmt.jquery.modalframe.close();
		}
		</script>
	</cfif>	
	
	<cfif form.type EQ "eventAttachment">
		<cfif form.task EQ "insert">
			<cfset request.calendarObj.insertAttachment(form)>
		</cfif>
		<!--- Close the modalFrame (if any) --->
		<script type="text/javascript">
		if(parent){
			parent.tmt.jquery.modalframe.refreshOpener();
			parent.tmt.jquery.modalframe.close();
		}
		</script>
	</cfif>
	
	<cfif form.type EQ "metaCategory">
		<cfif form.task EQ "insert">
			<cfset pk = request.calendarObj.insertMetaCategory(form)>
			<!--- Reload the dialog in "update" mode --->
			<cflocation url="dialogs/event_category.cfm?task=Update&id=#pk#" addtoken="no">
		</cfif>
		<cfif form.task EQ "update">
			<cfset request.calendarObj.updateMetaCategory(form)>
			<cfoutput>#request.configObj.get("updateRecordMSG")#</cfoutput>
		</cfif>
	</cfif>
	
	<cfif form.type EQ "category">
		<cfif form.task EQ "edit">
			<cfset request.calendarObj.editCategory(form)>
			<cfoutput>#request.configObj.get("updateRecordMSG")#</cfoutput>
		</cfif>
	</cfif>
	
	<cfif form.type EQ "skin">
		<cfif form.task EQ "insert">
			<cfset request.calendarObj.insertSkin(form)>
		</cfif>
		<cfif form.task EQ "update">
			<cfset request.calendarObj.updateSkin(form)>
		</cfif>
		<!--- Close the modalFrame --->
		<script type="text/javascript">
		if(parent){
			parent.frameCallback();
		}
		</script>
	</cfif>
	
</cfif>

<!--- GET Tasks --->
<cfif StructKeyExists(url, "task")>
	
	<cfif url.task EQ "deleteMeta">
		<cfset request.calendarObj.deleteMeta(url.id)>
	</cfif>
	
	<cfif url.task EQ "deleteLocal">
		<cfset request.calendarObj.deleteLocal(url.id, url.lang_abbrev)>
	</cfif>
	
	<cfif url.task EQ "deleteCategory">
		<cfset request.calendarObj.deleteCategory(url.id)>
	</cfif>
	
	<cfif url.task EQ "deleteLocalCategory">
		<cfset request.calendarObj.deleteLocalCategory(url.id, url.lang_abbrev)>
	</cfif>
	
	<cfif url.task EQ "deleteSkin">
		<cfset request.calendarObj.deleteSkin(url.id)>
	</cfif>
	
</cfif>