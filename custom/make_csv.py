#!/usr/bin/env python3

from connection import conn

cursor = conn.cursor()

with open('./sql/export.sql', 'r') as fsql:
    sql = fsql.read()

with open('output.csv', 'w') as fcsv:
    cursor.copy_expert("COPY ({0}) TO STDOUT WITH CSV".format(sql), fcsv)

conn.close()
