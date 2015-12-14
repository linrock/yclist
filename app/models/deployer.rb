module Deployer

  def self.deploy!
    remote_host = Remote.deploy_host
    remote_path = Remote.deploy_path
    puts "Deploying assets and html to production..."
    `rsync -avzP #{Rails.root.join("public").to_s}/ #{remote_host}:#{remote_path}`
    commands = [
      "cd #{remote_path}",
      "mv exported.html index.html",
      "mv exported.html.gz index.html.gz"
    ]
    `ssh #{remote_host} "#{commands.join(" ; ")}"`
  end

end
