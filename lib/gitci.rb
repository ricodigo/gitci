$:.unshift File.expand_path("..", __FILE__)

require 'bundler/setup'

Bundler.require

require 'sinatra/namespace'

require 'gitci/config'
require 'gitci/helpers'
require 'gitci/models'
require 'gitci/app'

module Gitci
  def self.app
    Gitci::App
  end
end
