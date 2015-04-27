<cfprocessingdirective pageencoding="utf-8">
<cfimport taglib="../../custom_tags/admin/layout/" prefix="layout">
<cfimport taglib="../../custom_tags/" prefix="tmt">
<cfimport taglib="../../custom_tags/tmt_tabs/" prefix="tmt">
<cfparam name="url.task" default="insert">

<layout:body title="Event insert/update" hideMenu="true" isDialog="true">

<script type="text/javascript">

function deleteRecord(formNode, id, lang){
	var controllerUrl = "../controller_calendar.cfm?task=deleteLocal&id=" + id + "&lang_abbrev=" + lang;
	tmt.net.httpRequest({url: controllerUrl, loadCallback: function(){
		var fields = [formNode.elements["event_title"], formNode.elements["event_location"], formNode.elements["event_description"]];
		tmt.form.clearFields(fields);
		tmt.form.displayMessage(formNode, "Record deleted");
		jQuery("." + lang).hide();
	}});
}

function dataEditCallback(){
	var formNode = this.response.contextData.domNode;
	var lang = formNode.elements["lang_abbrev"].value;
	// Show/hide GUI
	if(formNode.elements["event_title"].value == ""){
		jQuery("." + lang).hide();
	}
	else{
		jQuery("." + lang).show();
	}
	// Display message in a box
	tmt.form.displayMessage(formNode, this.response.responseText);
}

</script>

<!--- If update, fetch data, else use empty record to populate form --->
<cfif url.task EQ "update">
	<cfset inputFilter = {event_id = url.id}>
	<cfset record = request.calendarObj.getMeta(inputFilter)>
<cfelse>
	<cfset record = QueryNew("event_id,skin_id,cat_id,event_start_date,event_end_date,event_publish_start,event_publish_end,event_start_time,event_end_time")>
</cfif>

<cfset categories = request.calendarObj.getCategories()>
<cfset skins = request.calendarObj.getSkins()>

<!--- Link to CSS containing skins's rules --->
<cfoutput><link href="#REQUEST.pathToRoot#custom_tags/tmt_calendar/css/skins.css" type="text/css" rel="stylesheet"  /></cfoutput>
<script type="text/javascript">
tmt.validator.patterns.hhmm = new RegExp("^\\d\\d:\\d\\d$");

function previewSkin(){
	var selectNode = tmt.get("skin_id");
	var skinName = selectNode.options[selectNode.selectedIndex].text;
	tmt.get("skinPreview").className = skinName;
}

// Open image insert dialog in modalframe
function showImageInsert(eventId, lang){
	var frameUrl = "../dialogs/event_image.cfm?task=Insert&event_id=" + eventId + "&lang=" + lang;
	tmt.jquery.modalframe.open(frameUrl, {title: "Insert new image", height: 200, width: 400});
}

// Open attachment insert dialog in modalframe
function showAttachInsert(eventId, lang){
	var frameUrl = "../dialogs/event_attachment.cfm?task=Insert&event_id=" + eventId + "&lang=" + lang;
	tmt.jquery.modalframe.open(frameUrl, {title: "Insert new attachment", height: 200, width: 400});
}

tmt.addEvent(window, "load", previewSkin);
</script>

<tmt:tabgroup id="mainTab" css="admin.css">
	
	<tmt:tab label="Event" title="Event details">
	<form method="post" action="../controller_calendar.cfm" tmt:validate="true" tmt:callback="tmt.validator.errorBoxCallback" <cfif url.task EQ "update">tmt:blocksubmit="false" tmt:ajaxform="true"</cfif>>
		<table>
			<tr>
				<td>Category:</td>
				<td>
				<select name="cat_id">
					<cfoutput query="categories">
					<option value="#categories.cat_id#" <cfif categories.cat_id EQ record.cat_id>selected="selected"</cfif>>#categories.cat_name#</option>
					</cfoutput>
				</select>
				</td>
			</tr>
			<tr>
				<td>Skin:</td>
				<td>
				<select name="skin_id" id="skin_id" onchange="previewSkin()">
					<cfoutput query="skins">
					<option value="#skins.skin_id#" <cfif skins.skin_id EQ record.skin_id>selected="selected"</cfif>>#skins.skin_name#</option>
					</cfoutput>
				</select>
				<a id="skinPreview" class="<cfoutput>#skins.skin_name#</cfoutput>">Skin Preview</a>
				</td>
			</tr>
			<cfoutput>
			<tr>
				<td>Start date:</td>
				<td>
				<input type="text" name="event_start_date" id="event_start_date" value="#Left(record.event_start_date, 10)#" maxlength="10" tmt:required="true" tmt:errorclass="invalid" tmt:message="Please select a start date (YYYY-MM-DD format)" class="required date" />
				<tmt:datepicker id="event_start_date_button" inputfield="event_start_date" />
				</td>
			</tr>
			<tr>
				<td>End date:</td>
				<td>
				<input type="text" name="event_end_date" id="event_end_date" value="#Left(record.event_end_date, 10)#" maxlength="10" tmt:required="true" tmt:greater="event_start_date" tmt:errorclass="invalid" tmt:message="Please select an end date (YYYY-MM-DD format). End date must be greater/equal than start date" class="required date" />
				<tmt:datepicker id="event_end_date_button" inputfield="event_end_date" />
				</td>
			</tr>
			<tr>
				<td>Start publish:</td>
				<td>
				<input type="text" name="event_publish_start" id="event_publish_start" value="#Left(record.event_publish_start, 10)#" maxlength="10" tmt:errorclass="invalid" tmt:datepattern="YYYY-MM-DD" tmt:message="Publish date must use the YYYY-MM-DD format" class="date" />
				<tmt:datepicker id="event_publish_start_button" inputfield="event_publish_start" />
				</td>
			</tr>
			<tr>
				<td>End publish:</td>
				<td>
				<input type="text" name="event_publish_end" id="event_publish_end" value="#Left(record.event_publish_end, 10)#" maxlength="10" tmt:greater="event_publish_start" tmt:errorclass="invalid" tmt:datepattern="YYYY-MM-DD" tmt:message="Publish date must use the YYYY-MM-DD format. End date must be greater/equal than start date" class="date" />
				<tmt:datepicker id="event_publish_end_button" inputfield="event_publish_end" />
				</td>
			</tr>
			<tr>
				<td>Start time: (hh:mm)</td>
				<td><input type="text" name="event_start_time" value="#record.event_start_time#" maxlength="5" tmt:errorclass="invalid" tmt:pattern="hhmm" tmt:message="Start time must use the hh:mm format" class="date" /></td>
			</tr>
			<tr>
				<td>End time: (hh:mm)</td>
				<td><input type="text" name="event_end_time" value="#record.event_end_time#" maxlength="5" tmt:errorclass="invalid" tmt:pattern="hhmm" tmt:message="End time must use the hh:mm format" class="date" /></td>
			</tr>
			<tr>
				<td></td>
				<td><input type="submit" value="#url.task#" /></td>
			</tr>
			</cfoutput>
		</table>
		<cfif url.task EQ "update">
			<input name="event_id" type="hidden" value="<cfoutput>#url.id#</cfoutput>" />
		</cfif>
		<input name="task" type="hidden" value="<cfoutput>#url.task#</cfoutput>" />
		<input name="type" type="hidden" value="eventMetadata" />
	</form>
	</tmt:tab>
	
	<cfif url.task EQ "update">
		<cfset languages = request.calendarObj.getLanguages()>
		<cfloop query="languages">
			
			<cfset record = request.calendarObj.getLocal(url.id, languages.lang_abbrev)>
			<cfset cssClass = languages.lang_abbrev>
			<cfif record.RecordCount EQ 0>
				<cfset cssClass &= " hidden">
			</cfif>
			
			<tmt:tab label="#languages.lang_name#" title="#languages.lang_name#">
			<cfoutput>
			<fieldset>
			<legend>Data</legend>
			<form method="post" action="../controller_calendar.cfm" id="#languages.lang_name#" tmt:validate="true" tmt:callback="tmt.validator.errorBoxCallback" tmt:blocksubmit="false" tmt:ajaxform="true" tmt:ajaxoncomplete="dataEditCallback">
				<table>
					<tr>
						<td>Title:</td>
						<td><input type="text" name="event_title" value="#record.event_title#" maxlength="50" tmt:required="true" tmt:errorclass="invalid" tmt:message="Please select a title" class="required long" /></td>
					</tr>
					<tr>
						<td>Location:</td>
						<td><input type="text" name="event_location" value="#record.event_location#" class="long" /></td>
					</tr>
					<tr>
						<td>Description:</td>
						<td>
						<textarea name="event_description">#record.event_description#</textarea>
						</td>
					</tr>
					<tr>
						<td></td>
						<td>
							<button onclick="deleteRecord(this.form, '#url.id#', '#languages.lang_abbrev#'); return false">Delete</button>
							<input type="submit" value="#url.task#" />
						</td>
					</tr>
				</table>
				<input name="event_id" type="hidden" value="#url.id#" />
				<input name="task" type="hidden" value="edit" />
				<input name="type" type="hidden" value="event" />
				<input name="lang_abbrev" type="hidden" value="#languages.lang_abbrev#" />
			</form>
			</fieldset>
			</cfoutput>
			<cfoutput><fieldset class="#cssClass#"></cfoutput>
			<legend>Images</legend>
			<!--- Images section --->
			<table>
				<tr>
					<td><cfoutput><div><button onclick="showImageInsert(#url.id#, '#languages.lang_abbrev#')">Add image</button></div></cfoutput></td>
				</tr>
				<!--- Display records --->
				<cfset images = request.calendarObj.getLocalImages(url.id, languages.lang_abbrev)>
				<cfset imagesPath = request.pathToRoot & request.calendarObj.getImagesPath()>
				<cfoutput query="images">
				<tr>
					<td>
					<form method="post" action="../controller_calendar.cfm">
						<input name="img_id" type="hidden" value="#images.img_id#" />
						<input name="task" type="hidden" value="deleteImage" />
						<input name="type" type="hidden" value="event" />
						<input value="Delete Image" type="submit" />
					</form>
					</td>
					<td><img src="#imagesPath##images.img_filename#" /></td>
				</tr>
				<tr>
					<td></td>
					<td>#images.img_description#</td>
				</tr>
			</cfoutput>
			</table>
			</fieldset>
			
			<cfoutput><fieldset class="#cssClass#"></cfoutput>
			<legend>Attachments</legend>
			<!--- Attachments section --->
			<table>
				<tr>
					<td><cfoutput><div><button onclick="showAttachInsert(#url.id#, '#languages.lang_abbrev#')">Add attachment</button></div></cfoutput></td>
				</tr>
			<cfset attachments = request.calendarObj.getLocalAttachments(url.id, languages.lang_abbrev)>
			<cfset attachmentsPath = request.pathToRoot & request.calendarObj.getAttachmentsPath()>
			<!--- Display records --->
			<cfoutput query="attachments">
				<tr>
					<td>
					<form method="post" action="../controller_calendar.cfm">
						<input name="attach_id" type="hidden" value="#attachments.attach_id#" />
						<input name="task" type="hidden" value="deleteAttachment" />
						<input name="type" type="hidden" value="event" />
						<input value="Delete attachment" type="submit" />
					</form>
					</td>
					<td><a href="#attachmentsPath##attachments.attach_filename#" target="_blank">#attachments.attach_description#</a></td>
				</tr>
			</cfoutput>
			</table>
			
			</tmt:tab>
		</cfloop>
	</cfif>
	
</tmt:tabgroup>

</layout:body>