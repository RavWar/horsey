require 'bundler/capistrano'
require 'capistrano/ext/multistage'

set :application, :horsey
set :branch, :master
set :god_shell, '/bin/bash'
set :rails_env, 'production'
set :repository, "git@gitlab.studio.molinos.ru:#{application}.git"
set :scm, :git
set :use_sudo, false
set :deploy_via, :remote_cache
set :normalize_asset_timestamps, false

ssh_options[:forward_agent] = true
ssh_options[:paranoid] = false

set :assets_dir, %w(public/system)

set :stages, %w(production)
set :default_stage, 'production'

set(:logs_dir)   { "#{current_path}/log" }
set(:pids_dir)   { "#{current_path}/tmp/pids" }
set(:config_dir) { "#{current_path}/config" }

after 'deploy:restart', 'deploy:cleanup'
