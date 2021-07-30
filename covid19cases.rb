#!/usr/bin/env ruby

require 'net/http'
require 'nokogiri'

dates = { }

{ :US => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_the_United_States',
        :UK => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_the_United_Kingdom',
        :PH => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_the_Philippines',
        :IL => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_Israel' }.each { |country, url|
  doc = Nokogiri::HTML Net::HTTP.get URI url
  data = [ ]
  doc.css('tr.mw-collapsible').map { |tr|
    date = tr.css('.bb-c:first').text()
    next if date[/\d{4}-\d{2}-\d{2}/].nil?
    count = tr.css('td:nth-of-type(3)').text().gsub(',', '').to_i
    dates[date] = { } if dates[date].nil?
    dates[date][country] = [ count ]
    data.push([ date, count ])
  }
  data.each_with_index { |row, i|
    new = 0
    new = data[i][1] - data[i-1][1] if i > 0
    dates[row[0]][country].push new
    data[i][2] = new
  } 
}

dates.sort { |a, b| b[0] <=> a[0] }.to_h.each { |date, data|
  print "#{date}"
  data.each { |country, row|
    print("\t#{country}: %7d, +%-6d" % row)
  }
  puts ""
}

puts "source code: https://gist.github.com/lccxz/c422faba53e6f82acdf0f595df82bddd"
