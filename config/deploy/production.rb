server 'host01.molinos.ru', :app, :web, :db, primary: true
set :user, :velogame
set :user_home_dir, "/home/#{user}"
set :keep_releases, 3
set :unicorn_worker_processes, 1
set :deploy_to, "#{user_home_dir}/production"
