<cfprocessingdirective pageencoding="utf-8">
<cfimport taglib="custom_tags/layout/" prefix="layout">

<layout:body>
	<layout:langbar />
	<h3><cfoutput>#request.localObj.get("welcome")#</cfoutput></h3>
</layout:body>