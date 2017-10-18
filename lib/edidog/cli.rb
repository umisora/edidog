require 'edidog'
require 'thor'
require 'dogapi'
require 'json'

module Edidog
  class CLI < Thor
    desc "list board", "list datadog dashboard/graph"
    option :board, :type => :array, :aliases => :B
    def list(type)
      api_key=ENV.fetch('DATADOG_API_KEY')
      app_key=ENV.fetch('DATADOG_APP_KEY')
      if type.eql?("board") then
        puts "edidog list board"
        dog = Dogapi::Client.new(api_key, app_key)
        result = dog.get_dashboards()
        json = result[1]
        json["dashes"].each {|board|
          puts "* #{board['id']} : #{board['title']} (#{board['description']})"
        }
      elsif type.eql?("graph") then
        puts "edidog list graph"
        puts "Target Board is... #{options[:board]}" if options[:board]
      else 
        puts "Usage edidog list board / edidog list graph"
      end
    end
  end
end
