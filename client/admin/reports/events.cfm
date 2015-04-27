<cfprocessingdirective pageencoding="utf-8">
<cfimport taglib="../../custom_tags/admin/layout/" prefix="layout">
<cfimport taglib="../../custom_tags/" prefix="tmt">
<cfset categories = request.calendarObj.getCategories()>
<cfset skins = request.calendarObj.getSkins()>

<layout:body isReport="true">

<script type="text/javascript">
var XML_URL = "../controller_calendar.cfm?getxml=true&report=events";
var CSV_URL = "../controller_calendar.cfm?getcsv=true&report=events";

// Open insert dialog in modalframe
function showInsert(){
	var frameUrl = "../dialogs/event.cfm?task=Insert";
	tmt.jquery.modalframe.open(frameUrl, {title: "Insert new record", height: 580, width: 600, onClose: dsRefresh});
}

// Open update dialog in modalframe
function showUpdate(id){
	var frameUrl = "../dialogs/event.cfm?task=Update&id=" + id;
	tmt.jquery.modalframe.open(frameUrl, {title: "Update record", height: 580, width: 600, onClose: dsRefresh});
}

function deleteRecord(id){
	if(confirm("Are you sure you want to perform this operation?")){
		var url = "../controller_calendar.cfm?task=deleteMeta&id=" + id;
		tmt.net.httpRequest(url, dsRefresh);
	}
}
</script>
<script type="text/javascript" src="<cfoutput>#request.pathToRoot#</cfoutput>javascript/admin/reports.js"></script>

<div id="header">
	<form id="searchForm" onsubmit="return search(this)">
		<fieldset>
			<table>
				<tr>
					<td>Category:</td>
					<td>
					<select name="cat_id">
						<option value=""></option>
						<cfoutput query="categories">
						<option value="#categories.cat_id#">#categories.cat_name#</option>
						</cfoutput>
					</select>
					</td>
				</tr>
				<tr>
					<td>Skin:</td>
					<td>
					<select name="skin_id">
						<option value=""></option>
						<cfoutput query="skins">
						<option value="#skins.skin_id#">#skins.skin_name#</option>
						</cfoutput>
					</select>
					</td>
				</tr>
				<tr>
					<td>After:</td>
					<td>
					<input type="text" name="start_date" id="start_date" maxlength="10" class="date" />
					<tmt:datepicker id="start_date_button" inputfield="start_date" />
					</td>
				</tr>
				<tr>
					<td>Before:</td>
					<td>
					<input type="text" name="end_date" id="end_date" maxlength="10" class="date" />
					<tmt:datepicker id="end_date_button" inputfield="end_date" />
					</td>
				</tr>
				<tr>
					<td>Title:</td>
					<td><input name="title" type="text" /></td>
				</tr>
				<tr>
					<td></td>
					<td>
						<input type="reset" value="Reset" />
						<input type="submit" value="Search" />
					</td>
				</tr>
			</table>
		</fieldset>
	</form>
</div>

<div>
	<button onclick="showInsert()">Add new event</button>
</div>

<div class="reportContainer">
	<div spry:region="dsPaged dsBase">
		<div spry:state="loading" class="loader">
			<div>Loading data...</div>
			<div><cfoutput><img src="#request.pathToRoot#images/generic/loading.gif" /></cfoutput></div>
		</div>
		<table spry:state="ready" class="report">
			<caption>Events</caption>
			<thead>
			<tr>
				<th scope="col" spry:sort="start_date">Start date</th>
				<th scope="col" spry:sort="end_date">End date</th>
				<th scope="col" spry:sort="titles">Titles</th>
				<th scope="col" spry:sort="is_visible">Visible</th>
				<th scope="col"></th>
			</tr>
			</thead>
			<tbody>
				<tr spry:repeat="dsPaged" spry:even="rowEven" spry:hover="rowHover" spry:select="rowSelected">
					<td><a href="javascript:" onclick="showUpdate('{event_id}')">{start_date_formatted}</a></td>
					<td><a href="javascript:" onclick="showUpdate('{event_id}')">{end_date_formatted}</a></td>
					<td><a href="javascript:" onclick="showUpdate('{event_id}')">{titles}</a></td>
					<td><span spry:if="{is_visible} == 1">yes</span></td>
					<td><button onclick="deleteRecord('{event_id}')">Delete</button></td>
				</tr>
			</tbody>
		</table>
	</div>
	<div id="paginBar" class="paging"></div>
	<button onclick="downloadCSV()">Download as Excel</button>
</div>

</layout:body>