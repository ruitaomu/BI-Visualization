DROP TABLE IF EXISTS tag;
CREATE TABLE tag (
  id bigint unsigned not null auto_increment,
  project_tester_id int unsigned not null default 0,
  project_id int unsigned not null default 0,
  tester_id int unsigned not null default 0,

  t_s int unsigned not null default 0,
  t_e int unsigned not null default 0,
  tag char(16) not null default '',
  seq char(16) not null default '',

  primary key (id),
  key (project_tester_id),
  key (project_id, tester_id, t_s, seq)
);
