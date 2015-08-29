namespace :deploy do

  # before :deploy, "deploy:check_revision"
  after :deploy, "deploy:restart"
  after :rollback, "deploy:restart"

  desc "Makes sure local git is in sync with remote."
  task :check_revision do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} Unicorn server."
    task command do
      on roles(:app) do
        execute "/etc/init.d/unicorn #{command}"
      end
    end
  end

  desc "Invoke rake task"
  task :rake do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, ENV['task']
        end
      end
    end
  end

end