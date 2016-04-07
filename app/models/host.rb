class Host
  include Mongoid::Document
  include Mongoid::Timestamps

  field :host_id, type: Integer
  field :cpu_core, type: Integer, default: 1
  field :status, type: String
  field :id_in_region, type: String

  has_one :job_execution

  belongs_to :region
end
