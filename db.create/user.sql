DROP TABLE IF EXISTS user;
CREATE TABLE user (
	id int unsigned not null auto_increment primary key,
  user_type tinyint unsigned not null default 0,

	email varchar(64) not null default '',
	
	password char(32) not null default '',
	salt varchar(16) not null default '',

	first_name varchar(32) not null default '',
	last_name varchar(32) not null default '',

	email_confirmed tinyint unsigned not null default 0,

	status char(1) not null default '',

	root_access tinyint unsigned not null default 0,

	created_on int unsigned not null default 0,
	updated_on int unsigned not null default 0,

	unique key (email),
  key (user_type)
) DEFAULT CHARSET=utf8;
