root = "/var/www/hellotoken-rails/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "#{root}/tmp/unicorn.hellotoken-rails.sock"
worker_processes 4
timeout 30

# from http://vladigleba.com/blog/2014/03/05/deploying-rails-apps-part-1-securing-the-server/
# CREATE PERMISSIONS
# groupadd deployers, adduser bob —ingroup deployers
# %deployers      ALL=(ALL) ALL --- in /etc/sudoers
# sudo chgrp deployers /var, sudo chmod g+w /var (and /var/www/ for each)
# ssh git@github.com (permission denied error OK; just need to add to authorized sites)

# symlink below correctly in /etc/init.d/unicorn and /etc/nginx/sites-enabled
# NGINX SCRIPT
# goes in /etc/nginx/sites-enabled(available)/hellotoken
# upstream unicorn {
#   server unix:/var/www/hellotoken-rails/current/tmp/unicorn.hellotoken-rails.sock fail_timeout=0;
# }

# server {
#         listen  0.0.0.0:80 default deferred;
#         root /var/www/hellotoken-rails/current/public;
#         server_name _;
#         #location / {
#         #        try_files $uri/index.html $uri.html $uri @unicorn;
#         #       proxy_read_timeout 300;
#         #}

#         location ^~ /assets/ {
#                 gzip_static on;
#                 expires max;
#                 add_header Cache-Control public;
#         }

#         try_files $uri/index.html $uri @unicorn;
#         location ~* ^.+\.(jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|txt|tar|mid|midi|wav|bmp|rtf|mp3|flv|mpeg|avi)$ {
#                         try_files $uri @unicorn;
#                 }

#          location @unicorn {
#                 proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#                 proxy_set_header Host $http_host;
#                 proxy_redirect off;
#                 proxy_pass http://unicorn;
#     }

#         error_page 500 502 503 504 /500.html;
#         keepalive_timeout 13;
# }

# UNICORN SCRIPT
# goes in /etc/default/unicorn
# # Change parametres below to appropriate values and set CONFIGURED to yes.
# CONFIGURED=yes

# # Default timeout until child process is killed during server upgrade,
# # it has *no* relation to option "timeout" in server's config.rb.
# TIMEOUT=60

# # Path to your web application, sh'ld be also set in server's config.rb,
# # option "working_directory". Rack's config.ru is located here.
# APP_ROOT=/var/www/hellotoken-rails/current

# # Server's config.rb, it's not a rack's config.ru
# CONFIG_RB=$APP_ROOT/config/unicorn.rb

# # Where to store PID, sh'ld be also set in server's config.rb, option "pid".
# PID=$APP_ROOT/tmp/pids/unicorn.pid
# UNICORN_OPTS="-D -c $CONFIG_RB -E production"

# AS_USER=ht-deployer

# PATH=/usr/local/rvm/rubies/ruby-2.1.3/bin:/usr/local/rvm/rubies/ruby-2.0.0-p353/bin:/usr/local/rvm/gems/ruby-2.0.0-p353/bin:/home/unicorn/.rvm/bin:/usr/local/sbin:/usr/bin:/bin:/sbin:$
# export GEM_HOME=/usr/local/rvm/gems/ruby-2.1.3
# export GEM_PATH=/usr/local/rvm/gems/ruby-2.1.3:/usr/local/rvm/gems/ruby-2.1.3
# DAEMON=/usr/local/rvm/gems/ruby-2.1.3/bin/unicorn

