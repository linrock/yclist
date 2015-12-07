namespace :app do

namespace :deploy do

  desc "Deploy static files in /public to production"
  task :all => :environment do
    Deployer.deploy!
  end

end

end
