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
    tables = page.css('.mod-content table')


    rushing_table = self.get_rushing_table(tables)
    receiving_table = self.get_receiving_table(tables)
    passing_table = self.get_passing_table(tables)

    debugger

    puts tables

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
