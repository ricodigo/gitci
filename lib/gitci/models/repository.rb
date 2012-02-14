class Repository
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :uri, :type => String
  field :ssh_key, :type => String

  field :fetched_at, :type => Time
  field :fail_on_fetch, :type => Boolean, :default => false
  field :key_added, :type => Boolean, :default => false

  field :bundle_output, :type => String
  field :has_gemfile, :type => Boolean, :default => false

  validates_presence_of :uri, :name
  has_many :scripts

  def normalized_name
    name.parameterize("-")
  end

  def fetch!
    BuildTask.create!(:repository => self)
  end

  def path
    "#{Gitci.config.repositories_path}/#{normalized_name}"
  end
end
