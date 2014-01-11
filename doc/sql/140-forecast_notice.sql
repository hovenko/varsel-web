CREATE TABLE forecast_notice (
    id              INTEGER         NOT NULL    auto_increment,
    profile         INTEGER         NOT NULL,
    latitude        DOUBLE          NOT NULL,
    longitude       DOUBLE          NOT NULL,
    address         VARCHAR(50),
    forecasttime    DATETIME        NOT NULL,
    forecast        INTEGER,
    processed       DATETIME,
    finished        BOOLEAN         NOT NULL DEFAULT 0,
    registered      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (profile) REFERENCES profile(id),
    FOREIGN KEY (forecast) REFERENCES forecast(id)
) ENGINE InnoDB;
