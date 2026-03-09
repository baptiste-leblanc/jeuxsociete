require "sinatra"
require "json"

set :bind, "0.0.0.0"
set :port, ENV["PORT"] || 4567

def load_games
  file_path = File.join(__dir__, "data", "games.json")

  if File.exist?(file_path)
    JSON.parse(File.read(file_path), symbolize_names: true)
  else
    puts "ERREUR : Fichier non trouvé ici : #{file_path}"
    []
  end
end

get "/" do
  @page_css = "index"

  all_games = load_games
  games = all_games

  if params[:query] && !params[:query].empty?
    query = params[:query].downcase
    games = games.select do |game|
      game[:name].downcase.include?(query)
    end
  end

  if params[:category] && !params[:category].empty?
    games = games.select do |game|
      game[:categories].include?(params[:category])
    end
  end

  @games = games.sort_by { |game| game[:name].downcase }

  @categories = all_games
                .flat_map { |g| g[:categories] }
                .uniq
                .sort

  erb :index
end

get "/mentions-legales" do
  @page_css = "legal"
  erb :"pages/mentions_legales"
end

get "/politique-confidentialite" do
  @page_css = "legal"
  erb :"pages/politique_confidentialite"
end

get "/cookies" do
  @page_css = "legal"
  erb :"pages/cookies"
end

get "/affiliation" do
  @page_css = "legal"
  erb :"pages/affiliation"
end

get "/top_selection" do
  @page_css = "top"
  @title = "Top 5 des meilleurs jeux | Avis Jeux"
  @description = "Découvrez notre sélection des 5 meilleurs jeux de société."
  erb :"top_selection"
end

get "/a_propos" do
  @page_css = "about"
  @title = "À propos | Avis Jeux"
  @description = "Découvrez pourquoi Avis Jeux a été créé et qui se cache derrière tout ces avis."
  erb :a_propos
end

get "/prochains_tests" do
  @page_css = "upcoming"
  @title = "Prochains tests | Avis Jeux"
  @description = "Les prochains jeux de société qui seront testés sur Avis Jeux."
  erb :prochains_tests
end

get "/games/:slug" do
  @page_css = "show"

  @game = load_games.find { |g| g[:slug] == params[:slug] }
  halt 404 unless @game
  @title = "#{@game[:name]} : Avis, Règles & Test Complet | Avis Jeux"
  @description = "Découvrez notre avis complet sur #{@game[:name]} : règles, durée, nombre de joueurs et conseils d'achat."

  erb :show
end
