+++
title = "How to use multiple shared in-memory SQLite databases in Python"
date = "2021-02-16"
author = "Ricardo Ander-Egg Aguilar"
categories = ["databases", "python", "sqlite"]
tags = ["python", "sqlite", "memory", "shared", "database"]
+++

This works only in the same Python process, you can't share an in-memory SQLite database between processes in this way.

```python
import sqlite3

# NOTE: you need to use uri=True

# 3 connections to the same in-memory database (DB1 / memdb1)
DB1_1 = sqlite3.connect("file:memdb1?mode=memory&cache=shared", uri=True)
DB1_2 = sqlite3.connect("file:memdb1?mode=memory&cache=shared", uri=True)
DB1_3 = sqlite3.connect("file:memdb1?mode=memory&cache=shared", uri=True)

# 2 connections to a *new* in-memory database (DB2 / memdb2)
DB2_1 = sqlite3.connect("file:memdb2?mode=memory&cache=shared", uri=True)
DB2_2 = sqlite3.connect("file:memdb2?mode=memory&cache=shared", uri=True)

# create a table in both DBs
# DB1
DB1_1.execute("create table if not exists dict(key text, value text)")

# DB2
DB2_1.execute("create table if not exists dict(key text, value text)")

# insert some values in both DBs with *one* of the connections
with DB1_1:
    DB1_1.execute("insert into dict values ('asdas', 'foobar')")

with DB2_1:
    DB2_1.execute("insert into dict values ('barasd', 'barfoo')")

# check that all the connections for a database have the same data
# DB1
assert DB1_1.execute("select * from dict").fetchall() == [("asdas", "foobar")]
assert DB1_2.execute("select * from dict").fetchall() == [("asdas", "foobar")]
assert DB1_3.execute("select * from dict").fetchall() == [("asdas", "foobar")]

# DB2
assert DB2_1.execute("select * from dict").fetchall() == [("barasd", "barfoo")]
assert DB2_2.execute("select * from dict").fetchall() == [("barasd", "barfoo")]
```


