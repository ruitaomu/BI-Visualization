DROP TABLE IF EXISTS token;
CREATE TABLE token (
	id int unsigned not null auto_increment primary key,
	user_id int unsigned not null default 0,

	purpose varchar(32) not null default '',
	
	skey char(32) not null default '',
	ip varchar(16) default NULL,

	data text default NULL,

	created_on int unsigned not null default 0,
	expires_on int unsigned not null default 0,

	key (user_id),
	unique key (skey)
) DEFAULT CHARSET=utf8;
