$:.unshift File.expand_path("..", __FILE__)

require 'bundler/setup'

Bundler.require

require 'open3'
require 'timeout'
require 'sinatra/namespace'
require 'sinatra/contrib'

require 'gitci/config'
require 'gitci/helpers'
require 'gitci/models'
require 'gitci/app'

module Gitci
  def self.app
    Gitci::App
  end
end
