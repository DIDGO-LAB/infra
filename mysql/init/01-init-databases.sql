CREATE DATABASE IF NOT EXISTS user_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS training_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS report_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'user_app'@'%' IDENTIFIED BY 'userpassword';
CREATE USER IF NOT EXISTS 'training_app'@'%' IDENTIFIED BY 'trainingpassword';
CREATE USER IF NOT EXISTS 'report_app'@'%' IDENTIFIED BY 'reportpassword';

GRANT ALL PRIVILEGES ON user_db.* TO 'user_app'@'%';
GRANT ALL PRIVILEGES ON training_db.* TO 'training_app'@'%';
GRANT ALL PRIVILEGES ON report_db.* TO 'report_app'@'%';

FLUSH PRIVILEGES;
