#!/usr/bin/env ruby
# to run: 
# gem install wukong
# local: cat fasta.file | ruby fasta_reader.rb --map
# hadoop: ruby fasta_reader.rb --run --hadoop dfs/fasta.file dfs/out

require 'rubygems'
require 'wukong'

class FastaReaderMapper < Wukong::Streamer::Base
  
  def stream
    before_stream
    while not $stdin.eof?
      $stdin.each { |l| break if l =~ /^\s*>(.*)/ }
      seq = {
        :id => $1, 
        :data => lambda { 
          r = $stdin.gets('>').chomp('>')
          $stdin.ungetc('>'[0]) unless $stdin.eof?
          r.gsub("\n", "").strip }.call 
        } unless $stdin.eof?
      emit seq
    end
    after_stream
  end

end

Wukong::Script.new(FastaReaderMapper, nil).run

