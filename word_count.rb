#!/usr/bin/env ruby

require 'rubygems' 
require 'wukong'

module WordCount
  class Mapper < Wukong::Streamer::LineStreamer
    # Emit each word in the line.
    def process line
      words = line.strip.split(/\W+/).reject(&:blank?)
      words.each{|word| yield [word, 1] }
    end
  end
      
  class Reducer < Wukong::Streamer::ListReducer
    def finalize
      yield [ key, values.map(&:last).map(&:to_i).sum ]
    end
  end
end
    
Wukong::Script.new(WordCount::Mapper, WordCount::Reducer).run 
