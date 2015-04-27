<cfprocessingdirective pageencoding="utf-8">

<cfif thisTag.executionMode IS "end">
	<cfexit>
</cfif>

<cfinclude template="../buildQuerystring.cfm">

<div id="langBar">
	<cfoutput>
		<cfif request.lang NEQ "en">
			<a href="#request.currentPage#?#buildQuerystring("lang", "en")#" title="English">EN</a>
		<cfelse>
			<strong>EN</strong>
		</cfif>
		<cfif request.lang NEQ "fr">
			<a href="#request.currentPage#?#buildQuerystring("lang", "fr")#" title="Français">FR</a>
		<cfelse>
			<strong>FR</strong>
		</cfif>
		<cfif  request.lang NEQ "de">
		<a href="#request.currentPage#?#buildQuerystring("lang", "de")#" title="Deutsch">DE</a>
		<cfelse>
			<strong>DE</strong>
		</cfif>
		<cfif request.lang NEQ "it">
			<a href="#request.currentPage#?#buildQuerystring("lang", "it")#" title="Italiano">IT</a>
		<cfelse>
			<strong>IT</strong>
		</cfif>
	</cfoutput>
</div>