class BuildTask
  include Mongoid::Document
  include Mongoid::Timestamps

  field :script, :type => String
  field :failed, :type => Boolean, :default => false
  field :output, :type => String

  belongs_to :repository

  validates_presence_of :script
end