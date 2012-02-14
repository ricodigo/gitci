# this is created by post-receive hook or via API
class BuildTask
  include Mongoid::Document
  include Mongoid::Timestamps

  field :command, :type => String
  field :failed, :type => Boolean, :default => false
  field :performed, :type => Boolean, :default => false
  field :stdout, :type => String
  field :stderr, :type => String

  field :git_ref, :type => String

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

#     self.set(:performed, true)
  end

  protected
  def fetch_repository
    Dir.chdir(Gitci.config.repositories_path) do
      system("git clone --depth=1 '#{repository.uri}' '#{repository.normalized_name}'")
    end

    in_repo do
      if File.exist?("Gemfile")
        Open3.popen3("bundle install --deployment") do |stdin, stdout, stderr|
          puts ">>>>>>> #{stderr.read}"
          puts ">>>>>>> #{stdout.read}"
          repository.bundle_output = stdout.read
          repository.has_gemfile = true
          repository.save!
        end
      end
    end
  end

  def run_script
    in_repo do
      reset_head
      Open3.popen3(self.command) do |pid, stdin, stdout, stderr|
        self.stdout = stdout.read
        self.stderr = stderr.read

        self.save!
      end
    end
  end

  def in_repo(&block)
    Dir.chdir(self.repository.path) do
#       reset_head(self.git_ref||"origin/master")
      block.call
    end
  end

  def reset_head(ref)
    system("git fetch origin; git reset --hard '#{ref}'")
  end
end