## TODO

* Create database and set permissions for user
  GRANT ALL TO ALL TABLES...

1. Edit hosts.ini
2. Edit vars.yml
3. Edit host_vars/*
4. Edit group_vars/*

ansible-playbook -i hosts.ini --ask-pass setup.yml
ansible-playbook -i hosts.ini [-l development] provision.yml

* "-l" to limit to a certain group (ie: 'development' group or a specific server)
* "--tags ruby" to limit to tagged tasks
