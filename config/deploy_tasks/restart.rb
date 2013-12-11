after 'deploy:restart', 'deploy:cleanup'

namespace :deploy do
  task :restart, roles: :app, except: { no_release: true } do
    unicorn.restart
  end
end
