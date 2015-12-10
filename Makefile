##
# Paths
CWD = .

##
# List of directories that need to be writeable
CHMOD_757_DIRS = $(CWD)/tmp/smarty/*/* $(CWD)/logs

##
# Targets

# default target:
default: chmod cfg

# set appropriate directory permissions:
chmod:
	@@chmod 757 $(CHMOD_757_DIRS)

# local configuration files:
cfg: $(CWD)/cfg/env.php $(CWD)/cfg/local.php

# database reset:
dbreset:
	@@for i in $(CWD)/db.create/*.sql; \
		do MYSQL_PWD=`bin/db info default pass` mysql -u`bin/db info default user` `bin/db info default name` < $$i; \
		done;

$(CWD)/cfg/%:
	@@echo "Copying [$(CWD)/skel/$@ -> ./$@]"
	@@cp $(CWD)/skel/$@ ./$@

# help:
help:
	@@echo ""
	@@echo "Usage: make [<target>]"
	@@echo "If no target specified, \"default\" is assumed."
	@@echo ""
	@@echo "Available targets:"
	@@echo " chmod    - set appropriate directory permissions"
	@@echo " cfg      - create required local config files, if missing"
	@@echo " help     - show this help"
	@@echo ""

.PHONY: default chmod cfg help
