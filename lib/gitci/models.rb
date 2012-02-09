this = File.dirname(__FILE__)
Dir[File.join(this, 'models', '**', '*.rb')].each do |file_path|
  require file_path
end
