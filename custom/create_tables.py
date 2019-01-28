#!/usr/bin/env python3

from connection import conn

cursor = conn.cursor()

with open('./sql/create_tables.sql', 'r') as fsql:
    sql = fsql.read()

cursor.execute(sql)
conn.commit()

conn.close()
