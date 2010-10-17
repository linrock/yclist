require 'sinatra/base'

class YC < Sinatra::Base
  get '/' do
    'hello world'
  end

  get '/:name' do

  end
end

YC.run!
