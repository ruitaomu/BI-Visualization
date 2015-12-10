DROP TABLE IF EXISTS customer;
CREATE TABLE customer (
  id int unsigned not null auto_increment,

  name varchar(128) not null default '',
  contact_name varchar(128) not null default '',
  contact_email varchar(128) not null default '',

  created_on int unsigned not null default 0,
  updated_on int unsigned not null default 0,

  primary key (id)
) DEFAULT CHARSET=utf8;
