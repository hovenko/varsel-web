CREATE TABLE forecast_feed (
    id              INTEGER         NOT NULL    auto_increment,
    profile         INTEGER         NOT NULL,
    latitude        DOUBLE          NOT NULL,
    longitude       DOUBLE          NOT NULL,
    name            VARCHAR(50),
    processed       DATETIME,
    registered      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    accessed        DATETIME,
    xmlcontent      TEXT,
    PRIMARY KEY (id),
    FOREIGN KEY (profile) REFERENCES profile(id)
) ENGINE InnoDB;
