namespace :app do

namespace :deploy do

  desc "Deploy files from public to production"
  task :all => :environment do
    puts "Syncing assets to production..."
    `rsync -avzP #{Rails.root.join("public").to_s}/ root@asgard:/srv/http/yclist/public`
    commands = [
      "cd /srv/http/yclist/public",
      "mv exported.html index.html",
      "mv exported.html.gz index.html.gz"
    ]
    `ssh root@asgard "#{commands.join(" ; ")}`
  end

end

end
