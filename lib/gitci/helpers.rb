this = File.dirname(__FILE__)
Dir[File.join(this, 'helpers', '**', '*.rb')].each do |file_path|
  require file_path
end
