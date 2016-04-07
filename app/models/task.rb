class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  field :task_id, type: Integer
  field :status, type: String
  field :execute, type: String

  has_many :jobs
end
