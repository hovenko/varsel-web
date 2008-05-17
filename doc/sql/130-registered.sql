CREATE TABLE registered (
    id          INTEGER(11)     NOT NULL,
    email       VARCHAR(50)     NOT NULL,
    registered  TIMESTAMP       NOT NULL DEFAULT current_timestamp(),
    code        VARCHAR(50)     NOT NULL,
    verified    BOOLEAN         NOT NULL DEFAULT 0,
    UNIQUE INDEX (code),
    UNIQUE INDEX (email),
    INDEX (verified),
    PRIMARY KEY (id),
    FOREIGN KEY (id) REFERENCES profile(id)
) ENGINE InnoDB;
