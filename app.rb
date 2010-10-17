require 'sinatra/base'
require './models'


class YC < Sinatra::Base
  get '/' do
    @companies = Company.all
    haml :index
  end

  get '/:name/thumb' do

  end
  
  get '/:name/snapshot' do

  end
end

YC.run!
