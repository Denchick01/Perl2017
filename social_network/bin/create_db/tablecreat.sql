DROP DATABASE IF EXISTS Social_Network;

CREATE SCHEMA Social_Network DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;

USE Social_Network;

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `user`;
		
CREATE TABLE `user` (
  `id` INTEGER NOT NULL DEFAULT 0,
  `first_name` VARCHAR(108) NULL,
  `second_name` VARCHAR(108) NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `user_relation`;
		
CREATE TABLE `user_relation` (
  `user_id` INTEGER NOT NULL DEFAULT 0,
  `friend_id` INTEGER NOT NULL DEFAULT 0,
  INDEX user_relation_idx_friend_id (friend_id),
  PRIMARY KEY (`user_id`, `friend_id`),
  CONSTRAINT user_relation_fk_friend_id FOREIGN KEY (friend_id) REFERENCES user (id),
  CONSTRAINT user_relation_fk_user_id FOREIGN KEY (user_id) REFERENCES user (id)
);

ALTER TABLE `user` ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
ALTER TABLE `user_relation` ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
