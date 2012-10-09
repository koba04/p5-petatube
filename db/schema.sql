CREATE TABLE IF NOT EXISTS peta (
    id          INTEGER UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
    digest      INTEGER UNSIGNED    NOT NULL COMMENT "URL検索用ハッシュ(murmurhash)",
    url         TEXT                NOT NULL COMMENT "petaされたURL",
    title       VARCHAR(255)        NOT NULL DEFAULT '' COMMENT "ページタイトル",
    count       INTEGER UNSIGNED    NOT NULL DEFAULT 0 COMMENT "petaされた回数",
    created_at  DATETIME            NOT NULL,
    updated_at  TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX url_digest(digest),
    INDEX view_count(count)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
