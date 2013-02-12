ALTER TABLE peta ADD COLUMN thumbnail_video_id VARCHAR(30) NOT NULL DEFAULT '' COMMENT "サムネイルで表示するvideo id" AFTER video_count;
