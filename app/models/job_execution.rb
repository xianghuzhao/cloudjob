class JobExecution
  include Mongoid::Document
  include Mongoid::Timestamps

  field :cycle, type: Integer
  field :status, type: String

  field :stdout, type: String
  field :stderr, type: String

  belongs_to :job

  belongs_to :host
end
