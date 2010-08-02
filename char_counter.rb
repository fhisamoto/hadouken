#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'

module CharCounter  
  class Mapper < Wukong::Streamer::LineStreamer
    def process(line)
      data = line.split()[0].split(':')[1]
      data.each_char { |c| yield [c, 1] }
    end
  end

  class Reducer < Wukong::Streamer::ListReducer
    def finalize
      yield [ key, values.map(&:last).map(&:to_i).sum ]
    end
  end
end

Wukong::Script.new(CharCounter::Mapper, CharCounter::Reducer).run
