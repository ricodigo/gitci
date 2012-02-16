class Repository
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :uri, :type => String

  field :feed_url, :type => String
  field :last_feed_at, :type => Time

  field :fetched_at, :type => Time
  field :fail_on_fetch, :type => Boolean, :default => false

  field :bundle_output, :type => String
  field :has_gemfile, :type => Boolean, :default => false

  validates_presence_of :uri, :name
  has_many :scripts
  has_many :build_tasks

  def normalized_name
    name.parameterize("-")
  end

  def fetch!
    BuildTask.create!(:repository => self)
  end

  def path
    "#{Gitci.config.repositories_path}/#{normalized_name}"
  end

  def parse_feed
    return false if self.feed_url.blank?

    feed = Feedzirra::Feed.fetch_and_parse(self.feed_url)

    entries = feed.entries
    if entries[0].updated && entries[0].updated == entries[1].updated
      $stderr.puts "BUGGY FEED: #{self.feed_url}"
      return false
    end

    entries.each do |entry|
      entry.published = Time.parse(entry.published) if entry.published.kind_of?(String)

      if !entry.published.kind_of?(Time)
        $stderr.puts "Skipping #{entry.summary}"
        next
      end

      next if self.last_feed_at && entry.published.to_i < self.last_feed_at.to_i

      if entry.title =~ /^Committed: (\S+)/
        commit_id = $1

        self.scripts.each do |script|
          BuildTask.create!(:repository => self, :script => script, :git_ref => commit_id)
        end
      end
    end
  end

end
