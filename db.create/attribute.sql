DROP TABLE IF EXISTS attribute;
CREATE TABLE attribute (
  id int unsigned not null auto_increment,
  name varchar(32) not null default '',
  value varchar(64) not null default '',
  pos tinyint unsigned not null default 0,

  created_on int unsigned not null default 0,
  deleted_on int unsigned not null default 0,

  primary key (id)
) DEFAULT CHARSET=utf8;
