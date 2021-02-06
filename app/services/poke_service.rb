class PokeService
  include HTTParty
  
  BASE_URI = "https://pokeapi.co/api/v2/pokemon/"

  def get_pokemon_list
    response = HTTParty.get(BASE_URI).to_s
    parsed   = JSON.parse(response, {symbolize_names: true})
    return parsed
  end

  def get_pokemon_full(name)
    response = HTTParty.get(BASE_URI + name).to_s
    parsed   = JSON.parse(response, {symbolize_names: true})
    return parsed
  end

  def get_pokemon(name)
    response    = HTTParty.get(BASE_URI + name).to_s
    parsed      = JSON.parse(response, {symbolize_names: true})

    pokename    = parsed[:name]
    pokenumber  = parsed[:id]
    pokesprites = [
      parsed[:sprites][:back_default],
      parsed[:sprites][:front_default]
    ]
    poketypes   = parsed[:types].map { |v| v[:type][:name] }
    pokeweight  = parsed[:weight]
    pokeheight  = parsed[:height]

    pokeinfo    = {
      :name    => pokename,
      :num     => pokenumber,
      :sprites => pokesprites,
      :types   => poketypes,
      :weight  => pokeweight,
      :height  => pokeheight
    }

    return pokeinfo
  end
end