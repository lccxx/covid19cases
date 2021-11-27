#!/usr/bin/env ruby

require 'net/http'
require 'nokogiri'

SOURCE_CODE = "https://github.com/lccxz/covid19cases/blob/master/covid19cases.rb"

dates = { }

countries = { :US => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_the_United_States',
  :UK => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_the_United_Kingdom',
  :TH => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_Thailand',
  :PH => 'https://en.wikipedia.org/wiki/COVID-19_pandemic_in_the_Philippines',
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

def text_output(dates, countries)
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

  puts "\nsource code: #{SOURCE_CODE}"
end

def html_output(dates, countries)
  puts '<doctype html>'
  puts '<html>'
  puts '<meta charset="utf-8" />'
  puts '<title>COVID-19 cases table</title>'
  puts '<style>body { background-color: #000; color: rgba(255,255,255,0.7); }</style>'
  puts ''
  puts '<center><table style="text-align: center; border-spacing: 8px;">'
  puts '<thead><tr><th><br/></th>'
  countries = countries.sort { |a, b| b[0] <=> a[0] }.to_h.each { |country, url|
    puts "<th colspan='2'>#{country}</th>"
  }
  puts '</tr><tr><th><br/></th>'
  countries.each { |country, url|
    puts '<th>Cases</th>'
    puts '<th>Deaths</th>'
  }
  puts '</tr></thead>'
  dates.sort { |a, b| b[0] <=> a[0] }.to_h.each { |date, data|
    puts "<tr><td>#{date}</td>"
    countries.each { |country, url|
      row = data[country]
      next puts("<td>-</td>" * 2) if row.nil?
      puts "<td>#{row[0]} (+#{row[2]})</td><td>#{row[1]} (+#{row[3]})</td>"
    }
    puts "</tr>"
  }
  puts "</table><p>source code: <a href='#{SOURCE_CODE}' title='source code'>#{SOURCE_CODE}</a></center>"

  return 0
end


text_output(dates, countries) if ARGV[0].nil?
html_output(dates, countries) if ARGV[0] && ARGV[0].upcase == "HTML"
