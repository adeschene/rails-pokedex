class PokemonController < ApplicationController
  def index
    @poke_list = PokeService.new.get_pokemon_list(params[:offset], params[:limit])
  end

  def show
    @pokemon = PokeService.new.get_pokemon(params[:id])
  end
end
