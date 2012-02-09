class Script
  include Mongoid::Document
  include Mongoid::Timestamps

  field :command, :type => String

  belongs_to :repository

  has_many :build_tasks
end
