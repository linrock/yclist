module Deployer

  REMOTE_HOST = "rails@yclist.com"
  REMOTE_PATH = "/home/rails/yclist/public"

  def self.deploy!
    puts "Deploying assets and html to production..."
    `rsync -avzP #{Rails.root.join("public").to_s}/ #{REMOTE_HOST}:#{REMOTE_PATH}`
    commands = [
      "cd #{REMOTE_PATH}",
      "mv exported.html index.html",
      "mv exported.html.gz index.html.gz"
    ]
    `ssh #{REMOTE_HOST} "#{commands.join(" ; ")}"`
  end

end
