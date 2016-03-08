#! /bin/env ruby

require "getoptlong"


#############################################################
input = nil

methylationProportions = Hash.new


#############################################################
opts = GetoptLong.new(
  ["-i", GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt, value|
  case opt
    when "-i"
      input = value
  end
end


#############################################################
File.open(input, "r").each_line do |line|
  line.chomp!
  line_arr = line.split("\t")
  gene, m, unm = line_arr.values_at(0,1,2)
  m, unm = [m, unm].map{|i|i.to_i}
  methylationProportions[gene] = m/(m+unm).to_f
end


methylationProportions.each_pair do |gene, v|
  puts [gene, v].map{|i|i.to_s}.join("\t")
end



