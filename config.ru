$:.unshift File.expand_path("../lib", __FILE__)
require 'gitci'

run Gitci.app

