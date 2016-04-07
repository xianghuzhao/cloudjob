require 'grape'
require 'mongoid'

require_relative 'app/apis/job'
require_relative 'app/apis/host'
require_relative 'app/apis/job_pool'

ROOT_PATH = File.expand_path('..', __FILE__)

Mongoid.load! "#{ROOT_PATH}/config/mongoid.yml", :development

class API < Grape::API
  mount JobAPI
  mount HostAPI
  mount JobPoolAPI
end

run API
