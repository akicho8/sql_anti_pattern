#!/bin/sh
mysql -u root -e "
DROP DATABASE IF EXISTS __test__;
CREATE DATABASE __test__;
USE __test__;

CREATE TABLE users (
 id INTEGER AUTO_INCREMENT NOT NULL,
 created_at DATETIME,
 PRIMARY KEY (id, created_at) # パーティションで使う created_at を PK に含めないとエラーになる
);

ALTER TABLE users PARTITION BY HASH (YEAR(created_at)) PARTITIONS 3;
EXPLAIN PARTITIONS SELECT * FROM users;
"
