DROP DATABASE IF EXISTS Web_notes;

CREATE SCHEMA Web_notes DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;

USE Web_notes;

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `users`;
		
CREATE TABLE `users` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `login` VARCHAR(15) NOT NULL DEFAULT '',
  `password` CHAR(32) NOT NULL DEFAULT '',
  `user_name` VARCHAR(15) NOT NULL DEFAULT '',
  `salt` CHAR(12) NOT NULL DEFAULT '',
  UNIQUE INDEX  users_idx_login (login),
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `notes`;
		
CREATE TABLE `notes` (
  `id` BIGINT NOT NULL DEFAULT 0,
  `creator_id` INTEGER NOT NULL DEFAULT 0,
  `note_text` TEXT(500) NOT NULL DEFAULT '',
  `create_time` TIMESTAMP NOT NULL DEFAULT 0,
  `title` VARCHAR(255),
  INDEX  notes_idx_create_time (create_time), 
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `user_links_to_notes`;
		
CREATE TABLE `user_links_to_notes` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `note_id` BIGINT NOT NULL DEFAULT 0,
  `user_id` INTEGER NOT NULL DEFAULT 0,
  INDEX user_links_to_notes_idx_note_id (note_id),
  INDEX user_links_to_notes_idx_user_id (user_id),
  PRIMARY KEY (`id`)
);


DROP TABLE IF EXISTS `note_files`;
		
CREATE TABLE `note_files` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `note_id` BIGINT NOT NULL DEFAULT 0,
  `file_name` VARCHAR(108) NOT NULL DEFAULT '',
  `file_path` VARCHAR(255) NOT NULL DEFAULT '',
  `file_type` VARCHAR(108) NOT NULL DEFAULT '',
  INDEX note_files_idx_note_id (note_id),
  PRIMARY KEY (`id`)
);


ALTER TABLE `notes` ADD FOREIGN KEY (creator_id) REFERENCES `users` (`id`);
ALTER TABLE `user_links_to_notes` ADD FOREIGN KEY (note_id) REFERENCES `notes` (`id`);
ALTER TABLE `user_links_to_notes` ADD FOREIGN KEY (user_id) REFERENCES `users` (`id`);
ALTER TABLE `note_files` ADD FOREIGN KEY (note_id) REFERENCES `notes` (`id`);


ALTER TABLE `users` ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
ALTER TABLE `notes` ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
ALTER TABLE `user_links_to_notes` ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
ALTER TABLE `note_files` ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

