class Company < ActiveRecord::Base
  has_many :page_ranks
  has_many :alexa_ranks
end
