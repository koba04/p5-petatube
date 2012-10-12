ALTER TABLE peta CHANGE COLUMN count view_count INTEGER UNSIGNED NOT NULL DEFAULT 0 COMMENT "petaされた回数";
ALTER TABLE peta ADD COLUMN video_count INTEGER UNSIGNED NOT NULL DEFAULT 0 COMMENT "含まれている動画の数" AFTER view_count;
DROP INDEX view_count ON peta;
ALTER TABLE peta ADD INDEX view_video_count(view_count, video_count);
