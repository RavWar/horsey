after 'deploy:update_code', 'deploy:symlink'

namespace :deploy do
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end
