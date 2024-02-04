class Scheduler

  def initialize
    older_than_one_hour_shows = Show.unscoped.older_than_one_hour
    never_updated_shows = Show.unscoped.never_updated

    # Merge the results of the two scopes
    @shows = older_than_one_hour_shows.or(never_updated_shows).index_by(&:id)
  end

  def shows_to_update
    @shows_to_update ||= find_shows_to_update
  end

  def find_shows_to_update
    url = "https://shows-remote-api.com"
    data = Faraday.get(url).body

    # Parse the JSON response
    res = JSON.parse(data, symbolize_names: true)

    res.each_with_object([]) do |show, array|
      local_show = @shows[show[:id]]
      array << show[:id] if local_show && (!local_show.last_update || local_show.quantity != show[:quantity])
    end
  end

  def schedule_show_updates
    count = shows_to_update.count
    return shows_to_update.each_with_index.map {|show, i| [show,i*15]}.to_h if count <= 240
    offset = 3600.0 / count
    shows_to_update.each_with_index.map do |show, i|
      [show,i*offset]
    end.to_h
  end
end
