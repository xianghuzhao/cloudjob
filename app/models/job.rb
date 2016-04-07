require_relative 'job_execution'

class Job
  include Mongoid::Document
  include Mongoid::Timestamps

  field :job_id, type: Integer
  field :status, type: String
  field :name, type: String
  field :exe_name, type: String

#  belongs_to :tasks
  has_many :job_executions
end
