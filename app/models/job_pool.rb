class JobPool
  include Mongoid::Document
  include Mongoid::Timestamps

  field :job_id, type: Integer
  field :host_id, type: Integer
  field :operation, type: String
end
