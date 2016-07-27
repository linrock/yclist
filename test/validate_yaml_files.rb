companies = YamlLoader.sorted_all_company_rows

companies.each do |company|
  unless company.valid?
    puts "#{company.name} is invalid"
    exit 1
  end
end
