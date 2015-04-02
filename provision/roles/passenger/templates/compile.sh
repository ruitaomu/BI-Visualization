#!/bin/bash
source /etc/profile.d/rbenv.sh
gem install rack --no-doc
cd /opt/passenger-5.0.5
bin/passenger-install-nginx-module --auto --prefix=/opt/nginx --auto-download --languages=ruby
