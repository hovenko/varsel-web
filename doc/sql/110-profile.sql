CREATE TABLE profile (
    id                  INTEGER(11)     NOT NULL    auto_increment,
    email               VARCHAR(50)     NOT NULL,
    firstname           VARCHAR(50)     NOT NULL,
    lastname            VARCHAR(50)     NOT NULL,
    password            VARCHAR(64)     NOT NULL,
    resetpasswordtoken  VARCHAR(12),
    UNIQUE INDEX (email),
    PRIMARY KEY (id)
) ENGINE InnoDB;
