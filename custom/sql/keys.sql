ALTER TABLE abp_blpu ADD PRIMARY KEY (uprn);
ALTER TABLE abp_classification ADD PRIMARY KEY (class_key);
ALTER TABLE abp_crossref ADD PRIMARY KEY (xref_key);
ALTER TABLE abp_delivery_point ADD PRIMARY KEY (udprn);
ALTER TABLE abp_lpi ADD PRIMARY KEY (lpi_key);
ALTER TABLE abp_organisation ADD PRIMARY KEY (org_key);
ALTER TABLE abp_street ADD PRIMARY KEY (usrn);
ALTER TABLE abp_street_descriptor ADD PRIMARY KEY (usrn, language);
ALTER TABLE abp_successor ADD PRIMARY KEY (succ_key);
