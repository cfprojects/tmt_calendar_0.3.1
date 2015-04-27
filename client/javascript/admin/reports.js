var dsBase = new Spry.Data.XMLDataSet(XML_URL, "dataset/row", { useCache: false });
var dsPaged = new Spry.Data.PagedView(dsBase ,{pageSize: 20});
var pagesBar = tmt.spry.pagingbar.factory(dsPaged, "paginBar", {style: "pages"});

function dsRefresh(){
	dsBase.loadData();
}

function downloadCSV(){
	var controllerUrl = CSV_URL;
	var formNode = tmt.get("searchForm");
	if(formNode){
		controllerUrl += "&" + tmt.form.serializeForm(formNode);
	}
	self.location.href = controllerUrl;
	return false;
}

function search(formNode){
	var searchStr = tmt.form.serializeForm(formNode);
	var controllerUrl = XML_URL + "&" + searchStr;
	dsBase.setURL(controllerUrl);
	dsRefresh();
	return false;
}

// Close modalframe and refresh data
function frameCallback(){
	tmt.jquery.modalframe.close();
	dsRefresh();
}