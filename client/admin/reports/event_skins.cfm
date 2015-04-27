<cfprocessingdirective pageencoding="utf-8">
<cfimport taglib="../../custom_tags/admin/layout/" prefix="layout">

<layout:body isReport="true">

<script type="text/javascript">
var XML_URL = "../controller_calendar.cfm?getxml=true&report=skins";
var CSV_URL = "../controller_calendar.cfm?getcsv=true&report=skins";

// Open insert dialog in modalframe
function showInsert(){
	var frameUrl = "../dialogs/event_skin.cfm?task=Insert";
	tmt.jquery.modalframe.open(frameUrl, {title: "Insert new record", height: 200, width: 300});
}

// Open update dialog in modalframe
function showUpdate(id){
	var frameUrl = "../dialogs/event_skin.cfm?task=Update&id=" + id;
	tmt.jquery.modalframe.open(frameUrl, {title: "Update record", height: 200, width: 300});
}

function deleteRecord(id){
	if(confirm("Are you sure you want to perform this operation?")){
		var url = "../controller_calendar.cfm?task=deleteSkin&id=" + id;
		tmt.net.httpRequest(url, dsRefresh);
	}
}
</script>
<script type="text/javascript" src="<cfoutput>#request.pathToRoot#</cfoutput>javascript/admin/reports.js"></script>

<div id="header">

<div>
	<button onclick="showInsert()">Add new skin</button>
</div>

<div class="reportContainer">
	<div spry:region="dsPaged dsBase">
		<div spry:state="loading" class="loader">
			<div>Loading data...</div>
			<div><cfoutput><img src="#request.pathToRoot#images/generic/loading.gif" /></cfoutput></div>
		</div>
		<table spry:state="ready" class="report smallReport">
			<caption>Skins</caption>
			<thead>
			<tr>
				<th scope="col" spry:sort="skin_name">Name</th>
				<th scope="col"></th>
			</tr>
			</thead>
			<tbody>
				<tr spry:repeat="dsPaged" spry:even="rowEven" spry:hover="rowHover" spry:select="rowSelected">
					<td><a href="javascript:" onclick="showUpdate('{skin_id}')">{skin_name}</a></td>
					<td><button onclick="deleteRecord('{skin_id}')">Delete</button></td>
				</tr>
			</tbody>
		</table>
	</div>
	<div id="paginBar" class="paging"></div>
	<button onclick="downloadCSV()">Download as Excel</button>
</div>

</layout:body>