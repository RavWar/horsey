after 'deploy:commands', 'deploy:cleanup'

namespace :deploy do
  task :restart, roles: :app, except: { no_release: true } do
    unicorn.restart
  end

  task :start, roles: :app, except: { no_release: true } do
    unicorn.start
  end

  task :stop, roles: :app, except: { no_release: true } do
    unicorn.stop
  end
end
