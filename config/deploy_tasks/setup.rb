after 'deploy:setup', "#{application}:setup"

namespace :"#{application}" do
  desc 'Create additional directories'
  task :setup do
    run "mkdir -p #{shared_path}/config #{shared_path}/sockets #{shared_path}/tmp"
    put File.read('config/database.yml'), "#{shared_path}/config/database.yml"
  end
end
