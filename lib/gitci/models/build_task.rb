# this is created by post-receive hook or via API
class BuildTask
  include Mongoid::Document
  include Mongoid::Timestamps

  field :command, :type => String
  field :failed, :type => Boolean, :default => false
  field :performed, :type => Boolean, :default => false
  field :output, :type => String

  belongs_to :repository
  belongs_to :script

  validates_presence_of :repository

  def has_command?
    self.command.present?
  end

  def perform!
    if has_command?
      fetch_repository
      run_script
    else
      fetch_repository
    end
  end

  protected
  def fetch_repository
  end

  def run_script
  end
end