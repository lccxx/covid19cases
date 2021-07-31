#!/usr/bin/env ruby

require 'net/http'
require 'nokogiri'

dates = { }

countries = { :US => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_the_United_States',
  :UK => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_the_United_Kingdom',
  :PH => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_the_Philippines',
  :IN => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_India',
  :IL => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_Israel',
}.each { |country, url|
  doc = Nokogiri::HTML Net::HTTP.get URI url
  data = [ ]
  doc.css('tr.mw-collapsible').map { |tr|
    date = tr.css('.bb-c:first').text()
    next if date[/\d{4}-\d{2}-\d{2}/].nil?
    count = tr.css('td:nth-of-type(3) span:first').text().gsub(',', '').to_i
    deathCount = tr.css('td:nth-of-type(4) span:first').text().gsub(',', '').to_i
    dates[date] = { } if dates[date].nil?
    dates[date][country] = [ count, deathCount ]
    data.push([ date, count, deathCount ])
  }
  data.each_with_index { |row, i|
    new = deathNew= 0
    new = data[i][1] - data[i-1][1] if i > 0
    dates[row[0]][country].push new
    deathNew = data[i][2] - data[i-1][2] if i > 0
    dates[row[0]][country].push deathNew
  } 
}

dates.sort { |a, b| b[0] <=> a[0] }.to_h.each { |date, data|
  print "#{date}"
  countries.sort { |a, b| b[0] <=> a[0] }.to_h.each { |country, url|
    print("  #{country}, ")
    row = data[country]
    print("C: %-8d D: %-7d %+-7d %+-6d" % row) if row
    print("C: %-8s D: %-7s %+-7s %+-6s" % ([ '-' ] * 4)) if row.nil?
  }
  puts ""
}

puts "\nsource code: https://github.com/lccxz/covid19cases/blob/master/covid19cases.rb"
