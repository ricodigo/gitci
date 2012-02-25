class Script
  include Mongoid::Document
  include Mongoid::Timestamps

  field :command, :type => String
  field :name, :type => String
  field :description, :type => String

  belongs_to :repository

  has_many :build_tasks, :validate => false
end
