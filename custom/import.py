#!/usr/bin/env python3

import argparse
from connection import conn

parser = argparse.ArgumentParser()
parser.add_argument('path', help='path to RecordSplitter output')
args = parser.parse_args()

cursor = conn.cursor()


imports = [
    "COPY abp_blpu FROM '{}/ID21_BLPU_Records.csv' DELIMITER ',' CSV HEADER;",
    "COPY abp_delivery_point FROM '{}/ID28_DPA_Records.csv' DELIMITER ',' CSV HEADER;",
    "COPY abp_lpi FROM '{}/ID24_LPI_Records.csv' DELIMITER ',' CSV HEADER;",
    "COPY abp_crossref FROM '{}/ID23_XREF_Records.csv' DELIMITER ',' CSV HEADER;",
    "COPY abp_classification FROM '{}/ID32_Class_Records.csv' DELIMITER ',' CSV HEADER;",
    "COPY abp_street FROM '{}/ID11_Street_Records.csv' DELIMITER ',' CSV HEADER;",
    "COPY abp_street_descriptor FROM '{}/ID15_StreetDesc_Records.csv' DELIMITER ',' CSV HEADER;",
    "COPY abp_organisation FROM '{}/ID31_Org_Records.csv' DELIMITER ',' CSV HEADER;",
    "COPY abp_successor FROM '{}/ID30_Successor_Records.csv' DELIMITER ',' CSV HEADER;",
]

print('importing data..')
for statement in imports:
    print(statement.format(args.path))
    cursor.execute(statement.format(args.path))
    conn.commit()


print('creating keys..')
with open('./sql/keys.sql', 'r') as fsql:
    sql = fsql.read()
cursor.execute(sql)
conn.commit()


print('creating constraints..')
with open('./sql/constraints.sql', 'r') as fsql:
    sql = fsql.read()
cursor.execute(sql)
conn.commit()


conn.close()
print('..done')
