raise ArgumentError, "you should define RACK_ENV" if ENV['RACK_ENV'].nil? || ENV['RACK_ENV'].empty?

require 'bundler'
APP_ROOT = Bundler.root.to_s
ruby_version = ENV['RUBY_VERSION']

launcher = "cd #{APP_ROOT}; rvm #{ruby_version} exec bundle exec"
env "PATH", ENV["PATH"]
env "RACK_ENV", ENV['RACK_ENV']
set :output, "#{APP_ROOT}/log/crontab.log"

puts "Setting up cront tasks on #{ENV['RACK_ENV']}..."

every 2.minutes do
  command "#{launcher} ruby bin/gitci-builder"
end
