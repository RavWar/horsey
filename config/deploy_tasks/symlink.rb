after 'deploy:finalize_update', 'app:symlink'

namespace :app do
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end
