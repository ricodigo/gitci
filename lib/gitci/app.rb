module Gitci
  class App < Sinatra::Base
    include Gitci::Helpers::Global

    if Gitci.config.enable_auth
      use Rack::Auth::Basic, "Restricted Area" do |username, password|
        [username, password] == [Gitci.config.username, Gitci.config.password]
      end
    end

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
      @repositories = Repository.all.order(:created_at.desc)

      haml :'welcome/index.html'
    end

    get '/repositories' do
      @repositories = Repository.all.order(:created_at.desc)
      haml :'repositories/index.html'
    end

    get '/repositories/:id' do
      @repository = Repository.find(params[:id])

      haml :'repositories/show.html'
    end

    post '/repositories' do
      @repository = Repository.new(params[:repository])

      @repository.save!
      redirect "/repositories/#{@repository.id}"
    end
  end
end

