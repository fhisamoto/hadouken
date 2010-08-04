#!/usr/bin/env ruby
# to run: 
# gem install wukong
# local: cat fasta.file | ruby fasta_reader.rb --map
# hadoop: ruby fasta_reader.rb --run --hadoop dfs/fasta.file dfs/out

require 'rubygems'
require 'wukong'

module FastaReader

  class Mapper < Wukong::Streamer::Base
    def stream
      before_stream
      while not $stdin.eof?
        $stdin.each { |l| break if l =~ /^\s*>(.*)/ }
          
        seq = [ $1, 
           lambda { 
            r = $stdin.gets('>').chomp('>')
            $stdin.ungetc('>'[0]) unless $stdin.eof?
            r.gsub("\n", "").strip }.call 
          ] unless $stdin.eof?
        emit seq
      end
      after_stream
    end
    
  end
  
  class Reducer < Wukong::Streamer::ListReducer
    def finalize
      yield [ key, ">> #{values.map(&:last).join(":")}" ]
    end
  end
      
end

Wukong::Script.new(FastaReader::Mapper, FastaReader::Reducer).run

