class PokeService
  include HTTParty
  
  BASE_URI = "https://pokeapi.co/api/v2/pokemon/"

  def get_pokemon_list(offset, limit)
    response   = HTTParty.get(BASE_URI + "?offset=" + offset.to_s + "&limit=" + limit.to_s).to_s
    parsed     = JSON.parse(response, {symbolize_names: true})
    next_query = get_query_params(parsed[:next])
    prev_query = get_query_params(parsed[:previous])
    with_ids   = parsed[:results].map { |x|
      x[:id]   = x[:url].partition("pokemon/").last.partition("/").first
      x[:name] = x[:name].capitalize
    }
    return {
      :prev => prev_query,
      :next => next_query,
      :list => parsed[:results]
    }
  end

  def get_pokemon_full(id)
    response = HTTParty.get(BASE_URI + id).to_s
    parsed   = JSON.parse(response, {symbolize_names: true})
    return parsed
  end

  def get_pokemon(id)
    response    = HTTParty.get(BASE_URI + id).to_s
    parsed      = JSON.parse(response, {symbolize_names: true})

    pokename    = parsed[:name].capitalize
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

  private
    def get_query_params(url)
      trimmed = url.to_s.partition("=").last
      offset  = trimmed.to_s.partition("&").first
      limit   = trimmed.to_s.partition("=").last

      return {
        :offset => offset,
        :limit  => limit
      }
    end
end