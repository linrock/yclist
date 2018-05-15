companies = YamlLoader.sorted_all_company_rows
invalid_companies = []

companies.each do |company|
  invalid_companies << company unless company.valid?
end

if invalid_companies.present?
  invalid_companies.each do |company|
    puts "#{company.name} is invalid"
  end
  exit 1
end
