<?xml version="1.0" encoding="utf-8"?>
<cfsilent>
	<cfprocessingdirective pageencoding="utf-8" />
	<!-- Database -->
	<param name="dsn" description="ColdFusion datasource">calendar</param>
	<param name="database" description="Type of database used, either MSSQL or MYSQL">MSSQL</param>
	<param name="dsnUsername" description="Database username">tmt</param>
	<param name="dsnPassword" description="Database password">tmt</param>
	<!-- Paths -->
	<param name="attachmentsPath" description="Path to attachments folder (from application's root)">calendar/attachments/</param>
	<param name="imagesPath" description="Path to images folder (from application's root)">calendar/images/</param>
	<!-- Attachments/Images -->
	<param name="imagesMaxSize" description="Maximum file upload size allowed for images(kb)">3000</param>
	<param name="imagesMaxWidth" description="Image width (px)">300</param>
	<param name="attachmentsMaxSize" description="Maximum file upload size allowed for attchments (kb)">10000</param>
	<param name="attachmentsMimeTypes" description="Comma-delimited list of allowed mime types for attachments">*/*</param>
	<!-- Table/view names -->
	<param name="languagesTable">languages</param>
	<param name="skinsTable">calendar_skins</param>
	<param name="attachmentsTable">calendar_attachments</param>
	<param name="imagesTable">calendar_images</param>
	<param name="metadataTable">calendar_metadata</param>
	<param name="eventsTable">calendar_events</param>
	<param name="categoriesMetadataTable">calendar_categories_metadata</param>
	<param name="categoriesTable">calendar_categories</param>
	<param name="metaCategoriesView">calendar_meta_categories_view</param>
	<param name="categoriesView">calendar_categories_view</param>
	<param name="metadataView">calendar_metadata_view</param>
	<param name="detailsView">calendar_details_view</param>
	<param name="listView">calendar_list_view</param>
</cfsilent>