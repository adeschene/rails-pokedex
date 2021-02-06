class PokedexController < ApplicationController
  def index
    @pokeservice = PokeService.new
  end
end
