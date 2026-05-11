#!/bin/sh
set -eu

mysql --default-character-set=utf8mb4 -uroot -p"${MYSQL_ROOT_PASSWORD}" <<SQL
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS user_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS training_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

FLUSH PRIVILEGES;
SQL
