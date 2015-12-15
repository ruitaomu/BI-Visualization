DROP TABLE IF EXISTS project;
CREATE TABLE project (
  id int unsigned not null auto_increment,

  title varchar(128) not null default '',
  description text,
  customer_id int unsigned not null default 0,
  game_type_id int unsigned not null default 0,
  game_version varchar(8) not null default '',
  game_hardware_id int unsigned not null default 0,

  num_testers int unsigned not null default 0,

  created_on int unsigned not null default 0,
  updated_on int unsigned not null default 0,

  primary key (id)
) DEFAULT CHARSET=utf8;
