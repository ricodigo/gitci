module Gitci
  class App < Sinatra::Base
    include Gitci::Helpers::Global

    set :logging, true

    configure :production do
    end

    configure :development do
      set :show_exceptions, true
    end

    before do
    end

    get '/' do
      'woot'
    end
  end
end

