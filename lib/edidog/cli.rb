require 'edidog'
require 'thor'

module Edidog
  class CLI < Thor
    desc "list board", "list datadog dashboard/graph"
    option :board, :type => :array, :aliases => :B
    def list(type)
      if type.eql?("board") then
        puts "edidog list board"

      elsif type.eql?("graph") then
        puts "edidog list graph"
        puts "Target Board is... #{options[:board]}" if options[:board]
      else 
        puts "Usage edidog list board / edidog list graph"
      end
    end
  end
end
