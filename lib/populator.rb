module Populator

  def self.get_player_links(url)
    nodes = Nokogiri::HTML(HTTParty.get(url).body).css('tr.last')
    links = []
    nodes.each do |node|
      links << node.css('a')[0]['href'].split('\'')[1].gsub('/player', '/player/stats')
    end
    links
  end

  def self.parse_player(url)
    page = Nokogiri::HTML(HTTParty.get(url).body)

    top = page.css('.mod-page-header .mod-content')

    name = top.css('h1').text

    bio = top.css('.player-bio')

    number = bio.css('.general-info li:first-child').text.split(' ')[0].strip
    position = bio.css('.general-info li:first-child').text.split(' ')[1].strip
    team = bio.css('.general-info a').text

    age = bio.css('.player-metadata li:first-child').text.split(':')[1].split(')')[0].to_i

    if(Player.where(number: number).where(name: name).size != 0)
      player = Player.where(number: number).where(name: name)[0]
    else
      player = Player.create(name: name, position: position,
                team: team, age: age, number: number)
    end

    self.parse_seasons(page, player)

    #self.parse_seasons(page)

  end

  def self.parse_seasons(page, player)
    tables = page.css('.mod-content table')


    rushing_table = self.get_rushing_table(tables).css('tr.oddrow, tr.evenrow')
    receiving_table = self.get_receiving_table(tables).css('tr.oddrow, tr.evenrow')
    passing_table = self.get_passing_table(tables).css('tr.oddrow, tr.evenrow')



    (0..rushing_table.size-1).each do |i|
      fumbles = 0
      rush_row = rushing_table[i].css('td')
      rec_row = receiving_table[i].css('td')
      pass_row = passing_table[i].css('td')

      year = rush_row[0].text.to_i
      team = rush_row[1].css('a').text
      gp = rush_row[2].text.to_i

      rush_att = rush_row[3].text.to_i
      rush_yards = rush_row[4].text.gsub(',', '').to_i
      rush_avg = rush_row[5].text.to_f
      rush_td = rush_row[7].text.to_i
      fumbles += rush_row[10].text.to_i

      receptions = rec_row[3].text.to_i
      targets = rec_row[4].text.to_i
      rec_yards = rec_row[5].text.gsub(',', '').to_i
      rec_avg = rec_row[6].text.to_f
      rec_td = rec_row[8].text.to_i
      fumbles += rec_row[11].text.to_i

      pass_attempts = pass_row[4].text.to_i
      pass_complete = pass_row[3].text.to_i
      complete_pct  = pass_row[5].text.to_f
      pass_yards  = pass_row[6].text.gsub(',', '').to_i
      pass_avg  = pass_row[7].text.to_f
      pass_td = pass_row[8].text.to_i
      interceptions = pass_row[10].text.to_i
      fumbles += pass_row[11].text.to_i
      rating = pass_row[13].text.to_f

      total_points = (rush_yards.to_f / 10) + (rush_td.to_f * 6) +
                     (rec_yards.to_f / 10) + (rec_td.to_f * 6) +
                     (pass_yards.to_f / 25) + (pass_td.to_f * 4) -
                     (2 * fumbles)




      player_id = player.id

      Season.create(year: year, team: team, games_played: gp, rush_attempts: rush_att,
      rush_yards: rush_yards, rush_avg: rush_avg, rush_td: rush_td, receptions: receptions,
      rec_yards: rec_yards, rec_avg: rec_avg, rec_td: rec_td, pass_attempts: pass_attempts,
      pass_complete: pass_complete, complete_pct: complete_pct, pass_yards: pass_yards, pass_avg: pass_avg,
      pass_td: pass_td, interceptions: interceptions, rating: rating, fumbles: fumbles,
      total_points: total_points, player_id: player.id)
    end
  end


    def self.get_rushing_table(tables)
      tables.each do |table|
        stathead = table.css('tr.stathead')
        next if stathead.size == 0

        if stathead[0].text.strip =~ /Rushing Stats/
          return table
        end

      end
    end


    def self.get_receiving_table(tables)
      tables.each do |table|
        stathead = table.css('tr.stathead')
        next if stathead.size == 0

        if stathead.text.strip =~ /Receiving Stats/
          return table
        end

      end
    end

    def self.get_passing_table(tables)
      tables.each do |table|
        stathead = table.css('tr.stathead')
        next if stathead.size == 0

        if stathead.text.strip =~ /Passing Stats/
          return table
        end

      end
    end

end
