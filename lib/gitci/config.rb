module Gitci
  def self.config
    @config ||= begin
      ENV['RACK_ENV'] ||= 'development'

      Mongoid.load!(File.dirname(__FILE__)+"/../../config/mongoid.yml")

      data = if File.exist?('/etc/gitci.yml')
        YAML.load_file('/etc/gitci.yml')
      else
        YAML.load_file(File.expand_path("../../../config/gitci.yml", __FILE__))
      end

      OpenStruct.new(data[ENV['RACK_ENV']])
    end
  end
end
