DROP TABLE IF EXISTS role;
CREATE TABLE role (
	id int unsigned not null auto_increment primary key,

	name varchar(32) not null default '',
	description text,
	
	star_permission tinyint unsigned not null default 0,

	created_on int unsigned not null default 0,
	updated_on int unsigned not null default 0
) DEFAULT CHARSET=utf8;
