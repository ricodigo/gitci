class Repository
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :uri, :type => String
  field :ssh_key, :type => String

  field :fetched_at, :type => Time
  field :fail_on_fetch, :type => Boolean, :default => false
  field :key_added, :type => Boolean, :default => false

  validates_presence_of :uri, :name
end