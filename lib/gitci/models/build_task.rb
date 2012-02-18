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
  field :runtime_error, :type => String
  field :runtime_backtrace, :type => Array

  field :running, :type => Boolean, :default => false
  field :finished_at, :type => Time
  field :commit_id, :type => String

  field :exit_code, :type => Integer, :default => -1

  belongs_to :repository
  belongs_to :script

  before_create :check_command

  validates_presence_of :repository

  def has_command?
    self.command.present?
  end

  def perform!
    begin
      self.running = true
      self.save(:validate => false)

      if has_command?
        fetch_repository
        run_script
      else
        fetch_repository
      end
    rescue => e
      self.runtime_error = e.message
      self.runtime_backtrace = e.backtrace
      self.failed = true
    ensure
      self.running = false
    end

    self.performed = true
    self.save
  end

  protected
  def fetch_repository
    Dir.chdir(Gitci.config.repositories_path) do
      system("git clone --depth=1 '#{repository.uri}' '#{repository.normalized_name}'")
    end

    in_repo do
      reset_head

      if File.exist?("mongoid_ext.gemspec")
        Open4::popen4("bundle install --deployment") do |pid, stdin, stdout, stderr|
          repository.bundle_output = stdout.read
          repository.has_gemfile = true
          repository.save!
        end
      end
    end
  end

  def run_script
    in_repo do
      status = Open4::popen4(self.command) do |pid, stdin, stdout, stderr|
        self.stdout = stdout.read
        self.stderr = stderr.read
        self.finished_at = Time.now
        self.commit_id = `git log --oneline -1`
      end

      self.exit_code = status.to_i
      if self.exit_code != 0
        self.failed = true
      end

      begin
        old_name = File.expand_path("./coverage")
        new_name = File.expand_path("../../../../public/#{self.repository.normalized_name}-coverage", __FILE__)
        if File.exist?("coverage") && !File.exist?(new_name)
          self.repository.has_coverage = true
          self.repository.coverage_path = "/#{self.repository.normalized_name}-coverage/index.html"
          File.symlink(old_name, new_name)

          self.repository.save(:validate => false)
        end
      rescue => e
        puts e.message
        puts e.backtrace.join("\n\t")
      end

      self.save!
    end
  end

  def in_repo(&block)
    Dir.chdir(self.repository.path) do
      with_clear_env do
        block.call
      end
    end
  end

  def with_clear_env(&block)
    allowed_vars = Set.new(%w[
      rvm_bin_path
      rvm_clang_flag
      rvm_verbose_flag
      rvm_path
      rvm_debug_flag
      rvm_prefix
      rvm_gemdir_flag
      rvm_version
      rvm_reload_flag
    ])
    old_vals = {}
    ENV.each do |k, v|
      if k =~ /rvm_/ && !allowed_vars.include?(k)
        old_vals[k] = v
        ENV[k] = nil
      end
    end

    ENV.delete('BUNDLE_GEMFILE')
    ENV.delete('GEM_HOME')

    block.call

    old_vals.each do |k, v|
      ENV[k] = v
    end
  end

  def reset_head
    ref = self.git_ref.present? ? self.git_ref : "origin/master"
    system("git fetch origin; git reset --hard '#{ref}'")
  end

  def check_command
    if self.command.nil? && self.script_id.present?
      self.command = self.script.command
    end
  end
end