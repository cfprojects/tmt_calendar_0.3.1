<cfprocessingdirective pageencoding="utf-8">
<cfimport taglib="../custom_tags/layout/" prefix="layout">
<cfimport taglib="../custom_tags/tmt_calendar" prefix="tmt">
<layout:body>

	<layout:langbar />
	
	<tmt:calendar calendarObj="#request.calendarObj#" modalframebase="#request.pathToRoot#javascript/">

</layout:body>