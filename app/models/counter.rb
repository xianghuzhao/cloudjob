class Counter
  include Mongoid::Document
  field :name, type: String
  field :seq, type: Integer, default: 0

  class << self
    def next_sequence(name)
      exists_seq?(name) || create_seq(name)
      Counter.where(name: name).find_one_and_update({'$inc' => {seq: 1}}, upsert: true, return_document: :before)[:seq]
    end

    def exists_seq?(name)
      Counter.where(name: name).exists?
    end

    def create_seq(name)
      Counter.create!(name: name, seq: 0)
    end
  end
end
