class PokeService
  include HTTParty
  
  BASE_URI = "https://pokeapi.co/api/v2/pokemon/"

  # Get list of pokemon using offset and limit, extract and return useful info in a hash
  def get_pokemon_list(offset, limit)
    response   = HTTParty.get(BASE_URI + "?offset=" + offset.to_s + "&limit=" + limit.to_s).to_s
    parsed     = JSON.parse(response, {symbolize_names: true})
    
    # Get offset and limit values from 'next' and 'previous' urls
    next_query = get_query_params(parsed[:next])
    prev_query = get_query_params(parsed[:previous])
    
    # Extract 'id's from urls and add to list entries
    with_ids   = parsed[:results].map { |x|
      x[:id]   = x[:url].partition("pokemon/").last.partition("/").first
      x[:name] = x[:name].capitalize # Also capitalize pokemon names
    }

    # Return a new hash with only the relevant info for the pokemon list page
    return {
      :prev => prev_query,
      :next => next_query,
      :list => parsed[:results]
    }
  end

  # Get pokemon info for 'id', extract and return useful info in a hash
  def get_pokemon(id)
    response    = HTTParty.get(BASE_URI + id).to_s
    parsed      = JSON.parse(response, {symbolize_names: true})

    pokename    = parsed[:name].capitalize # Capitalize pokemon name
    pokenumber  = "#%03d" % parsed[:id] # Turn '3' into '#003', '59' into '#059', etc.
    
    # Extract out the 'official artwork' png for the pokemon
    pokesprite  = parsed[:sprites][:other][:"official-artwork"][:front_default]
    
    # Extract out the actual type names and capitalize them
    poketypes   = parsed[:types].map { |v| v[:type][:name].capitalize }
    pokeheight  = format_info(parsed[:height], "height")
    pokeweight  = format_info(parsed[:weight], "weight")

    # TODO: Add abilities parsed[:abilities].each[:ability][:name] and gsub '-',' ' and capitalize, then list in view
    # Maybe same for held items?

    # Return a new hash with only the relevent info for the pokemon
    return {
      :name   => pokename,
      :num    => pokenumber,
      :sprite => pokesprite,
      :types  => poketypes,
      :height => pokeheight,
      :weight => pokeweight
    }
  end

  private
    def get_query_params(url)
      # Get '40&limit=20' from 'https://pokeapi.co/api/v2/pokemon/?offset=40&limit=20'
      trimmed = url.to_s.partition("=").last
      
      # Get '40' from '40&limit=20'
      offset  = trimmed.to_s.partition("&").first
      
      # Get '20' from '40&limit=20'
      limit   = trimmed.to_s.partition("=").last

      return {
        :offset => offset,
        :limit  => limit
      }
    end

    def format_info(raw, type)
      case type
      when "weight"
        converted = raw / 4.536 # Formula hectograms => lbs
        # Round to whole number unless very lightweight pokemon
        rounded   = converted < 1 ? converted.round(1) : converted.round()
        formatted = rounded.to_s.concat(" lbs") # Tack 'lbs' onto value
      when "height"
        converted = raw * 3.937 # Formula decimeters => inches
        feet      = converted.round() / 12
        inches    = converted.round() % 12
        formatted = ""
        unless feet == 0
          formatted.concat("#{feet.to_s}\'")
        end
        unless inches == 0
          formatted.concat("#{inches.to_s}\"")
        end
      end

      return formatted
    end
end