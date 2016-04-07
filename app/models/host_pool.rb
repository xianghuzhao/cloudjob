class HostPool
  include Mongoid::Document
  include Mongoid::Timestamps

  field :region_id, type: Integer
  field :host_id, type: Integer
  field :operation, type: String
end
