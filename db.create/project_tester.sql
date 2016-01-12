DROP TABLE IF EXISTS project_tester;
CREATE TABLE project_tester (
  id int unsigned not null auto_increment,
  project_id int unsigned not null default 0,
  tester_id int unsigned not null default 0,
  wistia_video_hashed_id varchar(32) not null default '',
  index_file varchar(64) not null default '',
  tags_file varchar(64) not null default '',
  created_on int unsigned not null default 0,

  primary key (id),
  unique key (project_id, tester_id)
);
