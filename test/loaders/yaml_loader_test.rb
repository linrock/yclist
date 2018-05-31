require 'test_helper'

class YamlLoaderTest < ActiveSupport::TestCase
  test 'all companies in YAML files have valid data' do
    companies = YamlLoader.new.sorted_all_company_rows
    invalid_companies = []

    companies.each do |company|
      invalid_companies << company unless company.valid?
    end

    if invalid_companies.present?
      invalid_companies.each do |company|
        puts "#{company.name} is invalid"
      end
    end

    assert invalid_companies.empty?
  end
end
