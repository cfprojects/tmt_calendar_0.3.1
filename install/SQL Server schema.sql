SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[calendar_skins](
	[skin_id] [int] IDENTITY(1,1) NOT NULL,
	[skin_name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_calendar_skins] PRIMARY KEY CLUSTERED 
(
	[skin_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON


GO
CREATE TABLE [dbo].[languages](
	[lang_abbrev] [char](2) NOT NULL,
	[lang_name] [nvarchar](30) NOT NULL,
	[lang_order] [int] NOT NULL,
 CONSTRAINT [PK_languages] PRIMARY KEY CLUSTERED 
(
	[lang_abbrev] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[calendar_categories_metadata](
	[cat_id] [int] IDENTITY(1,1) NOT NULL,
	[cat_sort_order] [int] NOT NULL,
 CONSTRAINT [PK_calendar_categories_metadata] PRIMARY KEY CLUSTERED 
(
	[cat_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON

GO
CREATE TABLE [dbo].[calendar_metadata](
	[event_id] [int] IDENTITY(1,1) NOT NULL,
	[skin_id] [int] NOT NULL,
	[cat_id] [int] NOT NULL,
	[event_start_date] [datetime] NOT NULL,
	[event_end_date] [datetime] NOT NULL,
	[event_publish_start] [datetime] NULL,
	[event_publish_end] [datetime] NULL,
	[event_start_time] [char](5) NULL,
	[event_end_time] [char](5) NULL,
 CONSTRAINT [PK_calendar_metadata] PRIMARY KEY CLUSTERED 
(
	[event_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_calendar_metadata_cat_id] ON [dbo].[calendar_metadata] 
(
	[cat_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_calendar_metadata_skin_id] ON [dbo].[calendar_metadata] 
(
	[skin_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON

GO
CREATE TABLE [dbo].[calendar_events](
	[event_id] [int] NOT NULL,
	[lang_abbrev] [char](2) NOT NULL,
	[event_title] [nvarchar](50) NOT NULL,
	[event_description] [nvarchar](max) NULL,
	[event_location] [nvarchar](50) NULL,
 CONSTRAINT [PK_calendar_events] PRIMARY KEY CLUSTERED 
(
	[event_id] ASC,
	[lang_abbrev] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_calendar_events_event_id] ON [dbo].[calendar_events] 
(
	[event_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_calendar_events_lang_abbrev] ON [dbo].[calendar_events] 
(
	[lang_abbrev] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[calendar_categories](
	[cat_id] [int] NOT NULL,
	[lang_abbrev] [char](2) NOT NULL,
	[cat_name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_calendar_categories] PRIMARY KEY CLUSTERED 
(
	[cat_id] ASC,
	[lang_abbrev] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_calendar_categories_cat_id] ON [dbo].[calendar_categories] 
(
	[cat_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_calendar_categories_lang_abbrev] ON [dbo].[calendar_categories] 
(
	[lang_abbrev] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[calendar_images](
	[img_id] [int] IDENTITY(1,1) NOT NULL,
	[event_id] [int] NOT NULL,
	[lang_abbrev] [char](2) NOT NULL,
	[img_filename] [nvarchar](100) NOT NULL,
	[img_description] [nvarchar](100) NULL,
 CONSTRAINT [PK_calendar_images] PRIMARY KEY CLUSTERED 
(
	[img_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_calendar_images_event_id] ON [dbo].[calendar_images] 
(
	[event_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_calendar_images_lang_abbrev] ON [dbo].[calendar_images] 
(
	[lang_abbrev] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[calendar_attachments](
	[attach_id] [int] IDENTITY(1,1) NOT NULL,
	[event_id] [int] NOT NULL,
	[lang_abbrev] [char](2) NOT NULL,
	[attach_filename] [nvarchar](100) NOT NULL,
	[attach_description] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_calendar_attachments] PRIMARY KEY CLUSTERED 
(
	[attach_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_calendar_attachments_event_id] ON [dbo].[calendar_attachments] 
(
	[event_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_calendar_attachments_lang_abbrev] ON [dbo].[calendar_attachments] 
(
	[lang_abbrev] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO



CREATE VIEW [dbo].[calendar_metadata_view]
AS
SELECT     m.event_id, m.skin_id, m.cat_id, m.event_start_date, m.event_end_date, CONVERT(char(10), m.event_start_date, 120) AS start_date_formatted, 
                      event_publish_start, event_publish_end, event_start_time, event_end_time, CONVERT(char(10), m.event_end_date, 120) AS end_date_formatted, 
                      (CASE WHEN event_publish_start IS NULL THEN 1 WHEN event_publish_start <= GETDATE() THEN 1 WHEN event_publish_start > GETDATE() 
                      THEN 0 WHEN event_publish_end < GETDATE() THEN 0 END) AS is_visible,
                          (SELECT     STUFF
                                                       ((SELECT     ', ' + event_title
                                                           FROM         calendar_events n
                                                           WHERE     n.event_id = m.event_id FOR XML PATH('')), 1, 2, '')) AS titles
FROM         dbo.calendar_metadata m
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[calendar_categories_view]
AS
SELECT     dbo.calendar_categories_metadata.cat_sort_order, dbo.calendar_categories_metadata.cat_id, dbo.calendar_categories.lang_abbrev, 
                      dbo.calendar_categories.cat_name
FROM         dbo.calendar_categories_metadata LEFT OUTER JOIN
                      dbo.calendar_categories ON dbo.calendar_categories_metadata.cat_id = dbo.calendar_categories.cat_id
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[calendar_meta_categories_view]
AS

SELECT     

m.cat_id,
m.cat_sort_order, 
   
                          (SELECT     STUFF
                                                       ((SELECT     ', ' + cat_name
                                                           FROM         calendar_categories n
                                                           WHERE     n.cat_id = m.cat_id FOR XML PATH('')), 1, 2, '')) AS names
FROM        dbo.calendar_categories_metadata m
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[calendar_list_view]
AS
SELECT     dbo.calendar_metadata_view.event_id, dbo.calendar_metadata_view.cat_id, dbo.calendar_metadata_view.event_start_date, 
                      dbo.calendar_metadata_view.event_end_date, dbo.calendar_metadata_view.is_visible, dbo.calendar_events.lang_abbrev, 
                      dbo.calendar_events.event_title, dbo.calendar_skins.skin_name, dbo.calendar_metadata_view.event_start_time, 
                      dbo.calendar_metadata_view.event_end_time
FROM         dbo.calendar_metadata_view INNER JOIN
                      dbo.calendar_events ON dbo.calendar_metadata_view.event_id = dbo.calendar_events.event_id INNER JOIN
                      dbo.calendar_skins ON dbo.calendar_metadata_view.skin_id = dbo.calendar_skins.skin_id
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[calendar_details_view]
AS
SELECT     dbo.calendar_list_view.event_id, dbo.calendar_list_view.event_start_date, dbo.calendar_list_view.event_end_date, 
                      dbo.calendar_list_view.event_title, dbo.calendar_list_view.skin_name, dbo.calendar_events.event_description, dbo.calendar_events.event_location, 
                      dbo.calendar_list_view.lang_abbrev, dbo.calendar_categories.cat_id, dbo.calendar_categories.cat_name, dbo.calendar_list_view.event_start_time, 
                      dbo.calendar_list_view.event_end_time
FROM         dbo.calendar_list_view INNER JOIN
                      dbo.calendar_events ON dbo.calendar_list_view.event_id = dbo.calendar_events.event_id AND 
                      dbo.calendar_list_view.lang_abbrev = dbo.calendar_events.lang_abbrev LEFT OUTER JOIN
                      dbo.calendar_categories ON dbo.calendar_list_view.cat_id = dbo.calendar_categories.cat_id AND 
                      dbo.calendar_list_view.lang_abbrev = dbo.calendar_categories.lang_abbrev
GO

ALTER TABLE [dbo].[calendar_attachments]  WITH CHECK ADD  CONSTRAINT [FK_calendar_attachments_calendar_events] FOREIGN KEY([event_id], [lang_abbrev])
REFERENCES [dbo].[calendar_events] ([event_id], [lang_abbrev])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calendar_attachments] CHECK CONSTRAINT [FK_calendar_attachments_calendar_events]
GO
ALTER TABLE [dbo].[calendar_categories]  WITH CHECK ADD  CONSTRAINT [FK_calendar_categories_calendar_categories_metadata] FOREIGN KEY([cat_id])
REFERENCES [dbo].[calendar_categories_metadata] ([cat_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calendar_categories] CHECK CONSTRAINT [FK_calendar_categories_calendar_categories_metadata]
GO
ALTER TABLE [dbo].[calendar_categories]  WITH CHECK ADD  CONSTRAINT [FK_calendar_categories_languages] FOREIGN KEY([lang_abbrev])
REFERENCES [dbo].[languages] ([lang_abbrev])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calendar_categories] CHECK CONSTRAINT [FK_calendar_categories_languages]
GO
ALTER TABLE [dbo].[calendar_events]  WITH CHECK ADD  CONSTRAINT [FK_calendar_events_calendar_metadata] FOREIGN KEY([event_id])
REFERENCES [dbo].[calendar_metadata] ([event_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calendar_events] CHECK CONSTRAINT [FK_calendar_events_calendar_metadata]
GO
ALTER TABLE [dbo].[calendar_events]  WITH CHECK ADD  CONSTRAINT [FK_calendar_events_languages] FOREIGN KEY([lang_abbrev])
REFERENCES [dbo].[languages] ([lang_abbrev])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calendar_events] CHECK CONSTRAINT [FK_calendar_events_languages]
GO
ALTER TABLE [dbo].[calendar_images]  WITH CHECK ADD  CONSTRAINT [FK_calendar_images_calendar_events] FOREIGN KEY([event_id], [lang_abbrev])
REFERENCES [dbo].[calendar_events] ([event_id], [lang_abbrev])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calendar_images] CHECK CONSTRAINT [FK_calendar_images_calendar_events]
GO
ALTER TABLE [dbo].[calendar_metadata]  WITH CHECK ADD  CONSTRAINT [FK_calendar_metadata_calendar_categories_metadata] FOREIGN KEY([cat_id])
REFERENCES [dbo].[calendar_categories_metadata] ([cat_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calendar_metadata] CHECK CONSTRAINT [FK_calendar_metadata_calendar_categories_metadata]
GO
ALTER TABLE [dbo].[calendar_metadata]  WITH CHECK ADD  CONSTRAINT [FK_calendar_metadata_calendar_skins] FOREIGN KEY([skin_id])
REFERENCES [dbo].[calendar_skins] ([skin_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calendar_metadata] CHECK CONSTRAINT [FK_calendar_metadata_calendar_skins]

GO