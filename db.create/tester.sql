DROP TABLE IF EXISTS tester;
CREATE TABLE tester (
  id int unsigned not null auto_increment,

  first_name varchar(32) not null default '',
  last_name varchar(32) not null default '',
  dob date not null,
  gender char(1) not null default '',
  experience_id int unsigned not null default 0,

  created_on int unsigned not null default 0,
  updated_on int unsigned not null default 0,

  primary key (id)
) DEFAULT CHARSET=utf8;
