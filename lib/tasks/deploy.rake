namespace :app do

namespace :deploy do

  desc "Deploy files from public to production"
  task :all do
    `rsync -avzP public/* root@asgard:/srv/http/yclist/public/`
  end

end

end
