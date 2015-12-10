DROP TABLE IF EXISTS user_role;
CREATE TABLE user_role (
	user_id int unsigned not null default 0,
	role_id int unsigned not null default 0,

	primary key (user_id, role_id)
) DEFAULT CHARSET=utf8;
