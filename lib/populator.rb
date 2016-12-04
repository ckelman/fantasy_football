module Populator

  def self.populate
    # [
    #   'http://espn.go.com/fantasy/football/story/_/page/FFLranks14top300/2014-fantasy-football-rankings-preseason-top-300',
    #   'http://espn.go.com/fantasy/football/story/_/page/2013preseasonFFLranks250/top-300-position',
    #   'http://sports.espn.go.com/fantasy/football/ffl/story?page=NFLDK2K12ranksTop300'
    # ].each do |page|
    #   self.populate_from_list_page(page)
    # end

    self.populate_stats_pages(2010,2016, ['rushing','receiving','passing'] )

  end

  def self.update_current_year
    self.populate_stats_pages(2016,2016,nil)
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

  def self.populate_stats_pages(start, finish, styles)

    start = start || 2016
    finish = finish || 2016
    styles = styles || ['rushing','receiving','passing']

      styles.each do |style|
      (start..finish).each do |year|
        self.populate_from_list_stats('http://espn.go.com/nfl/statistics/player/_/stat/'+style+'/year/'+year.to_s)

        #second and third page for receiving + rushing
        if(style != 'passing')
          self.populate_from_list_stats('http://espn.go.com/nfl/statistics/player/_/stat/' + style + '/sort/' + style + 'Yards/year/'+ (year.to_s) +'/qualified/false/count/41')
          self.populate_from_list_stats('http://espn.go.com/nfl/statistics/player/_/stat/' + style + '/sort/' + style + 'Yards/year/'+ (year.to_s) +'/qualified/false/count/81')
        end

        #fourth page for receiving + rushing
        if(style == 'receiving')
          self.populate_from_list_stats('http://espn.go.com/nfl/statistics/player/_/stat/' + style + '/sort/' + style + 'Yards/year/'+ (year.to_s) +'/qualified/false/count/121')
        end
      end
    end

    Player.standardize_positions
    Season.set_all
    Player.calc_all_projected_points
    Player.set_actives
    # Player.remove_all_nils
  end

  def self.populate_stats_qb
    ['passing'].each do |style|
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

      # self.parse_games(link)
    end
  end

#*********************************************************************************************
#NEED TO CALCULATE GAME FANTASY POINTS
#link is the link to a players stats page (what was previously being grabbed)
#  example link for Gronk:  'http://espn.go.com/nfl/player/stats/_/id/13229/rob-gronkowski'
#*********************************************************************************************

  def self.parse_games(link)
    url = link.gsub('/stats/', '/gamelog/')

    page = Nokogiri::HTML(HTTParty.get(url).body)
    years = page.css('.article .select-container .tablesm option').map{|y| y.text}
    years.delete('Select');

    arr = url.split('/')

    arr[arr.length-1] = 'year/placeholder/'+arr.last

    url = arr.join('/')

    years.each do |year|
      link = url.gsub('/placeholder/', '/' + year + '/')
      puts link

      #table is the table of rows for the given year.  All games will be either .evenrow or .oddrow within this
      page = Nokogiri::HTML(HTTParty.get(link).body)
      oddgames = page.css('.mod-container.mod-table.mod-player-stats .mod-content table').first.css('.oddrow')

      evengames = page.css('.mod-container.mod-table.mod-player-stats .mod-content table').first.css('.evenrow')

      name = page.css('.mod-page-header .mod-content h1').inner_html
      puts name

      games = []

      i=0
      k=0
      while(i < oddgames.size || k<evengames.size)
        if (i+k) % 2 == 0
          games << oddgames[i]
          i+=1;
        else
          games << evengames[k]
          k+=1;
        end

      end

      player = Player.get(name)
      year = year.to_i
      if (year < 2010)
        next
      end
      season = player.get_season(year)
      position = player.position
      number = player.number


      games.each do |game|
        begin
          if(position == "TE" || position == "WR" || position.include?("Receiver"))

            date = game.css('td:nth-child(1)').inner_html
            opponent = game.css('td:nth-child(2) a').inner_html
            score = game.css('td:nth-child(3) a').inner_html

            receptions = game.css('td:nth-child(4)').inner_html
            targets = game.css('td:nth-child(5)').inner_html
            rec_yards = game.css('td:nth-child(6)').inner_html
            rec_avg = game.css('td:nth-child(7)').inner_html
            rec_lng = game.css('td:nth-child(8)').inner_html
            rec_td = game.css('td:nth-child(9)').inner_html

            rush_att = game.css('td:nth-child(10)').inner_html
            rush_yards = game.css('td:nth-child(11)').inner_html
            rush_avg = game.css('td:nth-child(12)').inner_html
            rush_lng = game.css('td:nth-child(13)').inner_html
            rush_td = game.css('td:nth-child(14)').inner_html
            fumbles = game.css('td:nth-child(15)').inner_html
            fumbles_lost = game.css('td:nth-child(16)').inner_html

            month = date.split(' ')[1].split('/')[0].to_i
            day = date.split(' ')[1].split('/')[1].to_i
            year = year.to_i

            if(month <=2)
              year+=1;
            end

            date = Date.new(year, month, day)
            s_id = season.id

            scoreArr= score.split('-')
            
            win = scoreArr[0] > scoreArr[1]

            pass_yards = 0
            pass_td = 0
            interceptions = 0
            points = rush_yards.to_f * 0.1 + rush_td.to_f * 6 + rec_yards.to_f * 0.1 + rec_td.to_f * 6 + pass_yards.to_f * 0.025 + pass_td.to_f * 4 - fumbles_lost.to_f * 2 - interceptions.to_f * 2


            old_game = Game.where(season_id: s_id, date: date)
            if(old_game.size == 0)

              Game.create(season_id: s_id, date: date, opponent: opponent, score: score, receptions: receptions, targets: targets, rec_yards: rec_yards, 
                          rec_avg: rec_avg, rec_lng: rec_lng, rec_td: rec_td, rush_att: rush_att, rush_yards: rush_yards, rush_avg: rush_avg, rush_lng: rush_lng,
                          rush_td: rush_td, fumbles: fumbles, fumbles_lost: fumbles_lost, win: win, points: points)

            else
              old_game = old_game[0]
              old_game.update_attributes(season_id: s_id, date: date, opponent: opponent, score: score, receptions: receptions, targets: targets, rec_yards: rec_yards, 
                          rec_avg: rec_avg, rec_lng: rec_lng, rec_td: rec_td, rush_att: rush_att, rush_yards: rush_yards, rush_avg: rush_avg, rush_lng: rush_lng,
                          rush_td: rush_td, fumbles: fumbles, fumbles_lost: fumbles_lost, win: win, points: points)
            end

          elsif(position == "RB" || (position.downcase.include? "back") || (number.downcase.include? "running"))
            # 
            # 
            # Just need to set up for different order of stats for RB and QB
            # 
            # 

            date = game.css('td:nth-child(1)').inner_html
            opponent = game.css('td:nth-child(2) a').inner_html
            score = game.css('td:nth-child(3) a').inner_html

            rush_att = game.css('td:nth-child(4)').inner_html
            rush_yards = game.css('td:nth-child(5)').inner_html
            rush_avg = game.css('td:nth-child(6)').inner_html
            rush_lng = game.css('td:nth-child(7)').inner_html
            rush_td = game.css('td:nth-child(8)').inner_html

            receptions = game.css('td:nth-child(9)').inner_html
            targets = nil
            rec_yards = game.css('td:nth-child(10)').inner_html
            rec_avg = game.css('td:nth-child(11)').inner_html
            rec_lng = game.css('td:nth-child(12)').inner_html
            rec_td = game.css('td:nth-child(13)').inner_html


            fumbles = game.css('td:nth-child(14)').inner_html
            fumbles_lost = game.css('td:nth-child(15)').inner_html

            month = date.split(' ')[1].split('/')[0].to_i
            day = date.split(' ')[1].split('/')[1].to_i
            year = year.to_i

            if(month <=2)
              year+=1;
            end

            date = Date.new(year, month, day)
            s_id = season.id

            scoreArr= score.split('-')
            
            win = scoreArr[0] > scoreArr[1]
            pass_yards = 0
            pass_td = 0
            interceptions = 0
            points = rush_yards.to_f * 0.1 + rush_td.to_f * 6 + rec_yards.to_f * 0.1 + rec_td.to_f * 6 + pass_yards.to_f * 0.025 + pass_td.to_f * 4 - fumbles_lost.to_f * 2 - interceptions.to_f * 2




            old_game = Game.where(season_id: s_id, date: date)
            if(old_game.size == 0)

              Game.create(season_id: s_id, date: date, opponent: opponent, score: score, receptions: receptions, targets: targets, rec_yards: rec_yards, 
                          rec_avg: rec_avg, rec_lng: rec_lng, rec_td: rec_td, rush_att: rush_att, rush_yards: rush_yards, rush_avg: rush_avg, rush_lng: rush_lng,
                          rush_td: rush_td, fumbles: fumbles, fumbles_lost: fumbles_lost, win: win, points: points)

            else
              old_game = old_game[0]
              old_game.update_attributes(season_id: s_id, date: date, opponent: opponent, score: score, receptions: receptions, targets: targets, rec_yards: rec_yards, 
                          rec_avg: rec_avg, rec_lng: rec_lng, rec_td: rec_td, rush_att: rush_att, rush_yards: rush_yards, rush_avg: rush_avg, rush_lng: rush_lng,
                          rush_td: rush_td, fumbles: fumbles, fumbles_lost: fumbles_lost, win: win, points: points)
            end

          else   
            #QB  
            date = game.css('td:nth-child(1)').inner_html
            opponent = game.css('td:nth-child(2) a').inner_html
            score = game.css('td:nth-child(3) a').inner_html  

            completions = game.css('td:nth-child(4)').inner_html 
            pass_att = game.css('td:nth-child(5)').inner_html 
            pass_yards = game.css('td:nth-child(6)').inner_html 
            cmp_pct = game.css('td:nth-child(7)').inner_html 
            pass_avg = game.css('td:nth-child(8)').inner_html 
            pass_lng = game.css('td:nth-child(9)').inner_html 
            pass_td = game.css('td:nth-child(10)').inner_html 
            interceptions = game.css('td:nth-child(11)').inner_html 
            qbr = game.css('td:nth-child(12)').inner_html 
            pass_rating = game.css('td:nth-child(13)').inner_html 

            rush_att = game.css('td:nth-child(14)').inner_html
            rush_yards = game.css('td:nth-child(15)').inner_html
            rush_avg = game.css('td:nth-child(16)').inner_html
            rush_lng = game.css('td:nth-child(17)').inner_html
            rush_td = game.css('td:nth-child(18)').inner_html

            month = date.split(' ')[1].split('/')[0].to_i
            day = date.split(' ')[1].split('/')[1].to_i
            year = year.to_i

            if(month <=2)
              year+=1;
            end

            date = Date.new(year, month, day)
            s_id = season.id

            scoreArr= score.split('-')
            
            win = scoreArr[0] > scoreArr[1]

            rec_yards = 0
            rec_td = 0
            fumbles_lost = 0
            points = rush_yards.to_f * 0.1 + rush_td.to_f * 6 + rec_yards.to_f * 0.1 + rec_td.to_f * 6 + pass_yards.to_f * 0.025 + pass_td.to_f * 4 - fumbles_lost.to_f * 2 - interceptions.to_f * 2



            old_game = Game.where(season_id: s_id, date: date)
            if(old_game.size == 0)

              Game.create(season_id: s_id, date: date, opponent: opponent, score: score, rush_att: rush_att, rush_yards: rush_yards, rush_avg: rush_avg, rush_lng: rush_lng,
                          rush_td: rush_td, fumbles: fumbles, fumbles_lost: fumbles_lost, win: win, completions: completions, attempts: pass_att,
                          pass_yards: pass_yards, completion_pct: cmp_pct, pass_avg: pass_avg, pass_lng: pass_lng, pass_td: pass_td,
                          interceptions: interceptions, qbr: qbr, pass_rating: pass_rating, points: points)

            else
              old_game = old_game[0]
              old_game.update_attributes(season_id: s_id, date: date, opponent: opponent, score: score, rush_att: rush_att, rush_yards: rush_yards, rush_avg: rush_avg, rush_lng: rush_lng,
                          rush_td: rush_td, fumbles: fumbles, fumbles_lost: fumbles_lost, win: win, completions: completions, attempts: pass_att,
                          pass_yards: pass_yards, completion_pct: cmp_pct, pass_avg: pass_avg, pass_lng: pass_lng, pass_td: pass_td,
                          interceptions: interceptions, qbr: qbr, pass_rating: pass_rating, points: points)
            end



          end
        rescue => error
          puts error
        end

      end



    end

    links = years.map{|y| url.gsub('/placeholder/', '/' + y + '/')}
    return links

    
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

    if(position == nil)
      position = number
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

    if(Player.where(name: name).size != 0)


      player = Player.where(name: name)[0]
      player.update_attributes(
                team: team, age: age, number: number, experience: experience, weight: weight)
      player.save
    else


      player = Player.create(name: name, position: position,
                team: team, age: age, number: number, experience: experience, weight: weight)


    end

    #if(experience!= nil && experience != 1)

      self.parse_seasons(page, player)
    #end

    # Uncomment this to pull games
    self.parse_games(url)

  end

  def self.parse_seasons(page, player)
    tables = page.css('.mod-content table')

    # puts tables.css('tr.stathead')


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
    if(player.position == 'TE' || player.position == 'WR' || player.position.include?("Receiver"))
      the_table = receiving_table
    elsif(player.position == 'QB')
      the_table = passing_table
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
        begin
          year = rec_row[0].text.to_i
          team = rec_row[1].css('a').text
          gp = rec_row[2].text.to_i
        rescue
        end
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

        if stathead[0].text.strip =~ /Rushing Stats/ || stathead[0].text.strip =~ /RUSHING/
          # puts table
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
