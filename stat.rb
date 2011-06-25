require 'mongoid'

class Stat
  include Mongoid::Document

  field :region
  field :total_calls, :type => Integer
end
