class Region
  include Mongoid::Document
  include Mongoid::Timestamps

  field :region_id, type: Integer
  field :name, type: String
  field :status, type: String

  has_many :hosts
end
