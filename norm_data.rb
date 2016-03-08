#! /bin/env ruby

require "getoptlong"


################################################
input = nil
field = 2

values = Hash.new


################################################
opts = GetoptLong.new(
  ["-i", GetoptLong::REQUIRED_ARGUMENT],
  ["-f", GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt, value|
  case opt
    when "-i"
      input = value
    when "-f"
      field = value.to_i
  end
end


################################################
File.open(input, "r").each_line do |line|
  line.chomp!
  gene, value = line.split("\t").values_at(0,field-1)
  values[gene] = value.to_f
end


min = values.values.min
max = values.values.max

values.each_pair do |gene, value|
  values[gene] = (value - min) / (max - min)
  puts [gene, values[gene]].map{|i|i.to_s}.join("\t")
end


