DROP TABLE IF EXISTS role_permission;
CREATE TABLE role_permission (
	role_id int unsigned not null default 0,
	permission varchar(32) not null default '',

	primary key (role_id, permission)
) DEFAULT CHARSET=utf8;
