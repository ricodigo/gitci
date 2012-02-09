module Gitci
  class App < Sinatra::Base
    include Gitci::Helpers::Global

    set :logging, true
    set :public_folder, File.expand_path("../../../public", __FILE__)
    set :views, File.expand_path("../../../lib/gitci/views", __FILE__)
    set :haml, :layout => :'layouts/application.html'

    configure :production do
    end

    configure :development do
      set :show_exceptions, true
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    before do
    end

    get '/' do
      haml :'welcome/index.html'
    end

    get '/repositories' do
      'nothing yet'
    end

    post '/repositories' do
      @repository = Repository.new(params[:repository])

      @repository.save!
      redirect '/repositories'
    end
  end
end

