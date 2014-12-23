server '84.52.78.90', :app, :web, :db, primary: true
set :port, 11111
set :user, :funonbus
set :user_home_dir, "/home/#{user}"
set :keep_releases, 3
set :unicorn_worker_processes, 3
set :deploy_to, "#{user_home_dir}/production"
