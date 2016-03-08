#! /bin/env ruby

require "getoptlong"


#############################################################
methyl_file = nil
evolRate_file = nil

methyl_diver_info = Hash.new
evolRates = Hash.new


#############################################################
opts = GetoptLong.new(
  ["--methyl", GetoptLong::REQUIRED_ARGUMENT],
  ["--evolRate", GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt, value|
  case opt
    when "--methyl"
      methyl_file = value
    when "--evolRate"
      evolRate_file = value
  end
end


#############################################################
File.open(methyl_file, "r").each_line do |line|
  line.chomp!
  line_arr = line.split("\t")
  gene_names = line_arr[0,2].sort
  m1, unm1, m2, unm2, p_value = line_arr[2, line_arr.size].map!{|i|i.to_f}
  methyl_levels = [m1/(m1+unm1), m2/(m2+unm2)]
  relative_methyl_divergence = (methyl_levels[0] - methyl_levels[1])/(methyl_levels[0] + methyl_levels[1]).to_f
  #relative_methyl_divergence = (methyl_levels[0] + methyl_levels[1])/2.to_f
  gene_pair_name = gene_names.join("-")
  next if methyl_levels[0] + methyl_levels[1] == 0
  methyl_diver_info[gene_pair_name] = relative_methyl_divergence
end


File.open(evolRate_file, "r").each_line do |line|
  line.chomp!
  line_arr = line.split("\t")
  #evolRates[line_arr[0]] = line_arr[1].to_f
  line_arr[1], line_arr[2] = Math.log2(line_arr[1].to_f), Math.log2(line_arr[2].to_f)
  evolRates[line_arr[0].split("-").sort.join("-")] = (line_arr[1].to_f-line_arr[2].to_f)/(line_arr[1].to_f+line_arr[2].to_f)
end


evolRates.each_pair do |gene_pair_name, evolRate|
  next if not methyl_diver_info.include?(gene_pair_name)
  puts [gene_pair_name, methyl_diver_info[gene_pair_name], evolRates[gene_pair_name]].map{|i|i.to_s}.join("\t")
end


