#! /bin/env ruby

require "getoptlong"


####################################################################
input = nil
pair_file = nil
sep = "\t"

gene_info = Hash.new
same = 0
diff = 0


####################################################################
opts = GetoptLong.new(
  ["-i", GetoptLong::REQUIRED_ARGUMENT],
  ["--pair", GetoptLong::REQUIRED_ARGUMENT],
  ["--sep", GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt, value|
  case opt
    when "-i"
      input = value
    when "--pair"
      pair_file = value
    when "--sep"
      sep = value
  end
end


####################################################################
File.open(input, "r").each_line do |line|
  line.chomp!
  line_arr = line.split(/\s+/)
  gene, value = line_arr.values_at(0,1)
  gene_info[gene] = value
end


File.open(pair_file, "r").each_line do |line|
  line.chomp!
  genes = line.split(sep)
  next if not gene_info.include?(genes[0]) or not gene_info.include?(genes[1])
  if gene_info[genes[0]] == gene_info[genes[1]]
    same += 1
  else
    diff += 1
  end
end


puts [same, diff, same+diff].map{|i|i.to_i}


