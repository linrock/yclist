namespace :app do

  desc "Export company data to JSON"
  task :export => :environment do
    filename = "#{Date.today.strftime("%Y-%m-%d")}-companies.json"
    output = Rails.root.join("exports/#{filename}").to_s
    open(output,'w').write Company.all.to_json
    puts "Exported company data to exports/#{filename}"
  end

end
