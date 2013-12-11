after 'deploy:finalize_update', 'unicorn:compile_config'

namespace :unicorn do
  task :start, roles: :app do
    run "cd #{current_path} && RAILS_ENV=production " + \
        "bundle exec unicorn_rails -c #{current_path}/config/unicorn.rb -D"
  end

  task :stop, roles: :app do
    run "kill `cat #{current_path}/tmp/pids/unicorn.pid`"
  end

  task :restart, roles: :app do
    run "kill -USR2 `cat #{current_path}/tmp/pids/unicorn.pid`"
  end

  task :compile_config do
    roles[:app].each do |server|
      template  = ERB.new File.read 'config/unicorn.rb.erb'
      put template.result(binding), "#{release_path}/config/unicorn.rb", hosts: server.host
    end
  end
end
