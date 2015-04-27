/*
MySQL Data Transfer
Source Host: localhost
Source Database: calendar
Target Host: localhost
Target Database: calendar
Date: 2/26/2009 11:02:47 AM
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for calendar_attachments
-- ----------------------------
DROP TABLE IF EXISTS `calendar_attachments`;
CREATE TABLE `calendar_attachments` (
  `attach_id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) NOT NULL,
  `lang_abbrev` char(2) NOT NULL,
  `attach_filename` varchar(100) NOT NULL,
  `attach_description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`attach_id`),
  UNIQUE KEY `PK_calendar_attachments` (`attach_id`),
  KEY `FK_calendar_attachments` (`event_id`,`lang_abbrev`),
  KEY `IX_calendar_attachments_event_id` (`event_id`),
  KEY `IX_calendar_attachments_lang_abbrev` (`lang_abbrev`),
  CONSTRAINT `FK_calendar_attachments` FOREIGN KEY (`event_id`, `lang_abbrev`) REFERENCES `calendar_events` (`event_id`, `lang_abbrev`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for calendar_categories
-- ----------------------------
DROP TABLE IF EXISTS `calendar_categories`;
CREATE TABLE `calendar_categories` (
  `cat_id` int(11) NOT NULL,
  `lang_abbrev` char(2) NOT NULL,
  `cat_name` varchar(20) NOT NULL,
  PRIMARY KEY (`cat_id`,`lang_abbrev`),
  UNIQUE KEY `PK_calendar_categories` (`cat_id`,`lang_abbrev`),
  KEY `IX_calendar_categories_cat_id` (`cat_id`),
  KEY `IX_calendar_categories_lang_abbrev` (`lang_abbrev`),
  CONSTRAINT `FK_calendar_categories_cat_id` FOREIGN KEY (`cat_id`) REFERENCES `calendar_categories_metadata` (`cat_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for calendar_categories_metadata
-- ----------------------------
DROP TABLE IF EXISTS `calendar_categories_metadata`;
CREATE TABLE `calendar_categories_metadata` (
  `cat_id` int(11) NOT NULL AUTO_INCREMENT,
  `cat_sort_order` int(11) NOT NULL,
  PRIMARY KEY (`cat_id`),
  UNIQUE KEY `PK_calendar_categories_metadata` (`cat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for calendar_events
-- ----------------------------
DROP TABLE IF EXISTS `calendar_events`;
CREATE TABLE `calendar_events` (
  `event_id` int(11) NOT NULL,
  `lang_abbrev` char(2) NOT NULL,
  `event_title` varchar(50) NOT NULL,
  `event_description` varchar(500) DEFAULT NULL,
  `event_location` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`event_id`,`lang_abbrev`),
  UNIQUE KEY `PK_calendar_events` (`event_id`,`lang_abbrev`),
  KEY `IX_calendar_events_event_id` (`event_id`),
  KEY `IX_calendar_events_lang_abbrev` (`lang_abbrev`),
  CONSTRAINT `FK_calendar_events_event_id` FOREIGN KEY (`event_id`) REFERENCES `calendar_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_calendar_events_lang_abbrev` FOREIGN KEY (`lang_abbrev`) REFERENCES `languages` (`lang_abbrev`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for calendar_images
-- ----------------------------
DROP TABLE IF EXISTS `calendar_images`;
CREATE TABLE `calendar_images` (
  `img_id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) NOT NULL,
  `lang_abbrev` char(2) NOT NULL,
  `img_filename` varchar(100) NOT NULL,
  `img_description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`img_id`),
  UNIQUE KEY `PK_calendar_images` (`img_id`),
  KEY `IX_calendar_images` (`event_id`,`lang_abbrev`),
  KEY `IX_calendar_images_event_id` (`event_id`),
  KEY `IX_calendar_images_lang_abbrev` (`lang_abbrev`),
  CONSTRAINT `FK_calendar_images_event_id` FOREIGN KEY (`event_id`, `lang_abbrev`) REFERENCES `calendar_events` (`event_id`, `lang_abbrev`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for calendar_metadata
-- ----------------------------
DROP TABLE IF EXISTS `calendar_metadata`;
CREATE TABLE `calendar_metadata` (
  `event_id` int(11) NOT NULL AUTO_INCREMENT,
  `skin_id` int(11) NOT NULL,
  `cat_id` int(11) NOT NULL,
  `event_start_date` date NOT NULL,
  `event_end_date` date NOT NULL,
  `event_publish_start` date DEFAULT NULL,
  `event_publish_end` date DEFAULT NULL,
  `event_start_time` char(5) DEFAULT NULL,
  `event_end_time` char(5) DEFAULT NULL,
  PRIMARY KEY (`event_id`),
  UNIQUE KEY `PK_calendar_metadata` (`event_id`),
  KEY `IX_calendar_metadata_cat_id` (`cat_id`),
  KEY `IX_calendar_metadata_skin_id` (`skin_id`),
  CONSTRAINT `FK_calendar_metadata_cat_id` FOREIGN KEY (`cat_id`) REFERENCES `calendar_categories_metadata` (`cat_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_calendar_metadata_skin_id` FOREIGN KEY (`skin_id`) REFERENCES `calendar_skins` (`skin_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for calendar_skins
-- ----------------------------
DROP TABLE IF EXISTS `calendar_skins`;
CREATE TABLE `calendar_skins` (
  `skin_id` int(11) NOT NULL AUTO_INCREMENT,
  `skin_name` varchar(50) NOT NULL,
  PRIMARY KEY (`skin_id`),
  UNIQUE KEY `PK_calendar_skins` (`skin_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for languages
-- ----------------------------
DROP TABLE IF EXISTS `languages`;
CREATE TABLE `languages` (
  `lang_abbrev` char(2) NOT NULL,
  `lang_name` varchar(30) NOT NULL,
  `lang_order` int(11) NOT NULL,
  PRIMARY KEY (`lang_abbrev`),
  UNIQUE KEY `PK_languages` (`lang_abbrev`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- View structure for calendar_meta_categories_view
-- ----------------------------
DROP VIEW IF EXISTS `calendar_meta_categories_view`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `calendar_meta_categories_view` AS select `m`.`cat_id` AS `cat_id`,`m`.`cat_sort_order` AS `cat_sort_order`,(select `n`.`cat_name` AS `cat_name` from (`calendar_categories` `n` join `languages` `l`) where ((`n`.`lang_abbrev` = `l`.`lang_abbrev`) and (`n`.`cat_id` = `m`.`cat_id`)) order by `l`.`lang_order` limit 1) AS `names` from `calendar_categories_metadata` `m`;

-- ----------------------------
-- View structure for calendar_metadata_view
-- ----------------------------
DROP VIEW IF EXISTS `calendar_metadata_view`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `calendar_metadata_view` AS select `m`.`event_id` AS `event_id`,`m`.`skin_id` AS `skin_id`,`m`.`cat_id` AS `cat_id`,date_format(`m`.`event_start_date`,'%Y-%m-%d') AS `event_start_date`,date_format(`m`.`event_end_date`,'%Y-%m-%d') AS `event_end_date`,date_format(`m`.`event_publish_start`,'%Y-%m-%d') AS `event_publish_start`,date_format(`m`.`event_publish_end`,'%Y-%m-%d') AS `event_publish_end`,`m`.`event_start_time` AS `event_start_time`,`m`.`event_end_time` AS `event_end_time`,date_format(`m`.`event_start_date`,'%Y-%m-%d') AS `start_date_formatted`,date_format(`m`.`event_end_date`,'%Y-%m-%d') AS `end_date_formatted`,(case when isnull(`m`.`event_publish_start`) then 1 when (`m`.`event_publish_start` <= curdate()) then 1 when (`m`.`event_publish_start` > curdate()) then 0 when (`m`.`event_publish_end` < curdate()) then 0 end) AS `is_visible`,(select `n`.`event_title` AS `event_title` from (`calendar_events` `n` join `languages` `l`) where ((`n`.`lang_abbrev` = `l`.`lang_abbrev`) and (`n`.`event_id` = `m`.`event_id`)) order by `l`.`lang_order` limit 1) AS `titles` from `calendar_metadata` `m`;

-- ----------------------------
-- View structure for calendar_categories_view
-- ----------------------------
DROP VIEW IF EXISTS `calendar_categories_view`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `calendar_categories_view` AS select `calendar_categories_metadata`.`cat_sort_order` AS `cat_sort_order`,`calendar_categories_metadata`.`cat_id` AS `cat_id`,`calendar_categories`.`lang_abbrev` AS `lang_abbrev`,`calendar_categories`.`cat_name` AS `cat_name` from (`calendar_categories_metadata` left join `calendar_categories` on((`calendar_categories_metadata`.`cat_id` = `calendar_categories`.`cat_id`)));

-- ----------------------------
-- View structure for calendar_list_view
-- ----------------------------
DROP VIEW IF EXISTS `calendar_list_view`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `calendar_list_view` AS select `calendar_metadata_view`.`event_id` AS `event_id`,`calendar_metadata_view`.`cat_id` AS `cat_id`,`calendar_metadata_view`.`event_start_date` AS `event_start_date`,`calendar_metadata_view`.`event_end_date` AS `event_end_date`,`calendar_metadata_view`.`is_visible` AS `is_visible`,`calendar_events`.`lang_abbrev` AS `lang_abbrev`,`calendar_events`.`event_title` AS `event_title`,`calendar_skins`.`skin_name` AS `skin_name`,`calendar_metadata_view`.`event_start_time` AS `event_start_time`,`calendar_metadata_view`.`event_end_time` AS `event_end_time` from ((`calendar_metadata_view` join `calendar_events` on((`calendar_metadata_view`.`event_id` = `calendar_events`.`event_id`))) join `calendar_skins` on((`calendar_metadata_view`.`skin_id` = `calendar_skins`.`skin_id`)));

-- ----------------------------
-- View structure for calendar_details_view
-- ----------------------------
DROP VIEW IF EXISTS `calendar_details_view`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `calendar_details_view` AS select `calendar_list_view`.`event_id` AS `event_id`,`calendar_list_view`.`event_start_date` AS `event_start_date`,`calendar_list_view`.`event_end_date` AS `event_end_date`,`calendar_list_view`.`event_title` AS `event_title`,`calendar_list_view`.`skin_name` AS `skin_name`,`calendar_events`.`event_description` AS `event_description`,`calendar_events`.`event_location` AS `event_location`,`calendar_list_view`.`lang_abbrev` AS `lang_abbrev`,`calendar_categories`.`cat_id` AS `cat_id`,`calendar_categories`.`cat_name` AS `cat_name`,`calendar_list_view`.`event_start_time` AS `event_start_time`,`calendar_list_view`.`event_end_time` AS `event_end_time` from ((`calendar_list_view` join `calendar_events` on(((`calendar_list_view`.`event_id` = `calendar_events`.`event_id`) and (`calendar_list_view`.`lang_abbrev` = `calendar_events`.`lang_abbrev`)))) left join `calendar_categories` on(((`calendar_list_view`.`cat_id` = `calendar_categories`.`cat_id`) and (`calendar_list_view`.`lang_abbrev` = `calendar_categories`.`lang_abbrev`))));