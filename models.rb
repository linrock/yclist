require 'dm-core'
require 'dm-migrations'
require 'dm-paperclip'

APP_ROOT = '/home/rakshasa/code/new/yc-list'

DataMapper.setup(:default, "sqlite3:data.sqlite")

class Company
  include DataMapper::Resource
  include Paperclip::Resource

  property  :id,            Serial
  property  :name,          String, :unique => true, :required => true
  property  :title,         String
  property  :url,           String
  property  :dead,          Boolean
  property  :exited,        Boolean
  property  :alexa,         Integer
  property  :pagerank,      Integer
  property  :date_updated,  DateTime

  has_attached_file :snapshot,
    :styles => { :medium => "300x300>", :thumb => "100x100>" }
  has_attached_file :favicon,
    :styles => { :thumb => "16x16>" },
    :url => "/#{name}/favicon.:extension",
    :path => "#{APP_ROOT}/public/favicons/:attachment/:id/:style"
end

DataMapper.finalize
# DataMapper.auto_migrate!
