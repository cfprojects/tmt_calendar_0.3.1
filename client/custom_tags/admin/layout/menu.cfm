<cfprocessingdirective pageencoding="utf-8">
<cfoutput>
<ul id="MenuBar" class="MenuBarHorizontal">
	<li><a href="#request.pathToRoot#admin">Admin</a></li>
	<li><a class="MenuBarItemSubmenu">Calendar</a>
		<ul>
			<li><a href="#request.pathToRoot#admin/reports/events.cfm">Events</a></li>
			<li><a href="#request.pathToRoot#admin/reports/event_categories.cfm">Categories</a></li>
			<li><a href="#request.pathToRoot#admin/reports/event_skins.cfm">Skins</a></li>
		</ul>
	</li>
	<li><a href="#request.pathToRoot#" title="Go to public website">Website</a></li>
</ul>
</cfoutput>

<script type="text/javascript">
<!--
var MenuBar = new Spry.Widget.MenuBar("MenuBar");
//-->
</script>