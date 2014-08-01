module Populator

  def self.populate
    # [
    #   'http://espn.go.com/fantasy/football/story/_/page/FFLranks14top300/2014-fantasy-football-rankings-preseason-top-300',
    #   'http://espn.go.com/fantasy/football/story/_/page/2013preseasonFFLranks250/top-300-position',
    #   'http://sports.espn.go.com/fantasy/football/ffl/story?page=NFLDK2K12ranksTop300'
    # ].each do |page|
    #   self.populate_from_list_page(page)
    # end

    self.populate_stats_pages

  end

  def self.populate_fantasy_pages
    [
      'http://espn.go.com/fantasy/football/story/_/page/FFLranks14top300/2014-fantasy-football-rankings-preseason-top-300',
      'http://espn.go.com/fantasy/football/story/_/page/2013preseasonFFLranks250/top-300-position',
      'http://sports.espn.go.com/fantasy/football/ffl/story?page=NFLDK2K12ranksTop300'
    ].each do |page|
      self.populate_from_list_page(page)
    end

    Player.standardize_positions
    Season.set_all
  end

  def self.populate_stats_pages

    ['rushing','receiving','passing'].each do |style|
      (2002..2013).each do |year|
        self.populate_from_list_stats('http://espn.go.com/nfl/statistics/player/_/stat/'+style+'/year/'+year.to_s)

        #second page for receiving + rushing
        if(style == 'receiving')
          self.populate_from_list_stats('http://espn.go.com/nfl/statistics/player/_/stat/' + style + '/sort/' + style + 'Yards/year/'+ (year.to_s) +'/qualified/false/count/41')
        end
      end
    end

    Player.standardize_positions
    Season.set_all
    Player.calc_all_projected_points
    Player.set_actives
  end


  def self.populate_from_list_page(list_page)
    self.get_player_links(list_page).each do |link|
      puts "\n************************************************\n" + link +
      "\n************************************************\n"
      begin
      self.parse_player(link)
      rescue
      end
    end
  end

  def self.populate_from_list_stats(list_page)
    self.get_player_links_stats(list_page).each do |link|
      puts "\n************************************************\n" + link +
      "\n************************************************\n"
      begin
      self.parse_player(link)
      rescue
      end
    end
  end

  def self.get_player_links(url)
    nodes = Nokogiri::HTML(HTTParty.get(url).body).css('tr.last')
    links = []
    nodes.each do |node|
      link = node.css('a')[0]['href'].split('\'')[1]
      if(link =~ /fantasy/)
        page = Nokogiri::HTML(HTTParty.get(link).body)
        link = 'http://espn.go.com' + page.css('#content > div.mod-page-tabs.mod-pagenav-tabs > ul > li:nth-child(2) > a').first
      else
        link = link.gsub('/player', '/player/stats')
        next if link =~ /team/i
        links << URI.encode(link)
      end

    end
    links
  end

  def self.get_player_links_stats(url)
    page = Nokogiri::HTML(HTTParty.get(url).body).css('#my-players-table > div > div.mod-content > table')
    nodes = page.css('tr.oddrow, tr.evenrow')
    links = []
    nodes.each do |node|
      link = node.css('a')[0]['href'].gsub('/player', '/player/stats')
      links << link
    end
    links
  end

  def self.parse_player(url)
    page = Nokogiri::HTML(HTTParty.get(url).body)

    if( page.css('.player-bio').size == 0)
      return
    end



    top = page.css('.mod-page-header .mod-content')

    name = top.css('h1').text

    bio = top.css('.player-bio')

    number = bio.css('.general-info li:first-child').text.split(' ')[0].strip

    begin
      position = bio.css('.general-info li:first-child').text.split(' ')[1].strip
    rescue
    end


    begin
      team = bio.css('.general-info a').text
    rescue
    end


    begin
      experience = bio.css('.player-metadata li:nth-child(3)').text.strip
      if (experience =~ /rookie/i)
        experience = 1
      else
        experience = experience.split(' ')[0].split('Experience')[1].to_i
      end
    rescue
    end


    begin
    age = bio.css('.player-metadata li:first-child').text.split(':')[1].split(')')[0].to_i
    weight = bio.css('.general-info li:nth-child(2)').text.split(',')[1].split(' ')[0].strip.to_i
    rescue
    end

    if(Player.where(number: number).where(name: name).size != 0)


      player = Player.where(number: number).where(name: name)[0]
      player.update_attributes(name: name, position: position,
                team: team, age: age, number: number, experience: experience, weight: weight)
      player.save
    else


      player = Player.create(name: name, position: position,
                team: team, age: age, number: number, experience: experience, weight: weight)
    end

    if(experience!= nil && experience != 1)


      self.parse_seasons(page, player)
    end

    #self.parse_seasons(page)

  end

  def self.parse_seasons(page, player)
    tables = page.css('.mod-content table')

    begin
    rushing_table = self.get_rushing_table(tables).css('tr.oddrow, tr.evenrow')
    rescue
      return
    end
    begin
      receiving_table = self.get_receiving_table(tables).css('tr.oddrow, tr.evenrow')
    rescue
    end
    begin
      passing_table = self.get_passing_table(tables).css('tr.oddrow, tr.evenrow')
    rescue
    end


    the_table = rushing_table
    if(player.position == 'TE' || player.position == 'WR')
      the_table = receiving_table
    end
    (0..the_table.size-1).each do |i|
      fumbles = 0
      begin
        rush_row = rushing_table[i].css('td')
      rescue
      end

      begin
        rec_row = receiving_table[i].css('td')
      rescue
      end


      begin
        pass_row = passing_table[i].css('td')
      rescue
      end

      the_table_row = the_table[i].css('td')

      begin
        year = the_table_row[0].text.to_i
        team = the_table_row[1].css('a').text
        gp = the_table_row[2].text.to_i
      rescue
        year = rec_row[0].text.to_i
        team = rec_row[1].css('a').text
        gp = rec_row[2].text.to_i
      end

      begin
        rush_att = rush_row[3].text.to_i
        rush_yards = rush_row[4].text.gsub(',', '').to_i
        rush_avg = rush_row[5].text.to_f
        rush_td = rush_row[7].text.to_i
        fumbles += rush_row[10].text.to_i
      rescue
        rush_att = 0
        rush_yards = 0
        rush_avg = 0
        rush_td = 0
        fumbles += 0
      end

      begin
        receptions = rec_row[3].text.to_i
        targets = rec_row[4].text.to_i
        rec_yards = rec_row[5].text.gsub(',', '').to_i
        rec_avg = rec_row[6].text.to_f
        rec_td = rec_row[8].text.to_i
        fumbles += rec_row[11].text.to_i
      rescue
        receptions = 0
        targets = 0
        rec_yards = 0
        rec_avg = 0
        rec_td = 0
        fumbles += 0
      end

      begin
        pass_attempts = pass_row[4].text.to_i
        pass_complete = pass_row[3].text.to_i
        complete_pct  = pass_row[5].text.to_f
        pass_yards  = pass_row[6].text.gsub(',', '').to_i
        pass_avg  = pass_row[7].text.to_f
        pass_td = pass_row[8].text.to_i
        interceptions = pass_row[10].text.to_i
        fumbles += pass_row[11].text.to_i
        rating = pass_row[13].text.to_f
      rescue
        pass_attempts = 0
        pass_complete = 0
        complete_pct  = 0
        pass_yards  = 0
        pass_avg  = 0
        pass_td = 0
        interceptions = 0
        fumbles += 0
        rating = 0
      end

      total_points = (rush_yards.to_f / 10) + (rush_td.to_f * 6) +
                     (rec_yards.to_f / 10) + (rec_td.to_f * 6) +
                     (pass_yards.to_f / 25) + (pass_td.to_f * 4) -
                     (2 * fumbles)




      player_id = player.id
      pseason = player.seasons.where(year: year).first
      if(pseason == nil)

        Season.create(year: year, team: team, games_played: gp, rush_attempts: rush_att,
        rush_yards: rush_yards, rush_avg: rush_avg, rush_td: rush_td, receptions: receptions,
        rec_yards: rec_yards, rec_avg: rec_avg, rec_td: rec_td, pass_attempts: pass_attempts,
        pass_complete: pass_complete, complete_pct: complete_pct, pass_yards: pass_yards, pass_avg: pass_avg,
        pass_td: pass_td, interceptions: interceptions, rating: rating, fumbles: fumbles,
        total_points: total_points, player_id: player.id)

      else
        pseason.update_attributes(year: year, team: team, games_played: gp, rush_attempts: rush_att,
        rush_yards: rush_yards, rush_avg: rush_avg, rush_td: rush_td, receptions: receptions,
        rec_yards: rec_yards, rec_avg: rec_avg, rec_td: rec_td, pass_attempts: pass_attempts,
        pass_complete: pass_complete, complete_pct: complete_pct, pass_yards: pass_yards, pass_avg: pass_avg,
        pass_td: pass_td, interceptions: interceptions, rating: rating, fumbles: fumbles,
        total_points: total_points, player_id: player.id)
        pseason.save
      end
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
