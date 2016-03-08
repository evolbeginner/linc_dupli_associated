#! /bin/env ruby

require "getoptlong"


########################################################
dna_methyl_file = nil
deseq_file = nil
count_file = nil
joiner = "\t"

counts = Array.new
deseqs = Array.new
deseq_info = Hash.new
dna_methyl_info = Hash.new


########################################################
opts = GetoptLong.new(
  ["--DNA_methyl", GetoptLong::REQUIRED_ARGUMENT],
  ["--deseq", GetoptLong::REQUIRED_ARGUMENT],
  ["--count", "--count_file", GetoptLong::REQUIRED_ARGUMENT],
  ["--join", "--joiner", GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt, value|
  case opt
    when "--DNA_methyl"
      dna_methyl_file = value
    when "--deseq"
      deseq_file = value
    when "--count_file", "--count"
      count_file = value
    when "--join", "--joiner"
      joiner = value
  end
end


########################################################
File.open(count_file, "r").each_line do |line|
  line.chomp!
  line_arr = line.split("\t")
  gene_pair = line_arr[0]
  counts << gene_pair
end


is_start_recording = false
File.open(deseq_file, "r").each_line do |line|
  line.chomp!
  is_start_recording = true if line =~ /log2FoldChange/
  if is_start_recording
    line_arr = line.split(/\s+/)
    if line_arr.size < 5 and line_arr[0] != line_arr[1]
      deseqs << line_arr[-1].to_f
    end
  end
end


deseqs.each_with_index do |ele, index|
  deseq_info[counts[index]] = ele
end


File.open(dna_methyl_file, "r").each_line do |line|
  line.chomp!
  line_arr = line.split("\t")
  p_value = line_arr[-1].to_f
  gene_pair = line_arr.values_at(0,1).sort.join(joiner)
  dna_methyl_info[gene_pair] = p_value 
end


########################################################
same = 0
diff1 = 0
diff2 = 0
diff3 = 0

dna_methyl_info.each_pair do |gene_pair, p_value|
  next if not deseq_info.include?(gene_pair)
  puts [p_value, deseq_info[gene_pair]].map{|i|i.to_s}.join("\t")
  if p_value < 0.0001 and deseq_info[gene_pair] < 0.0001
    same += 1
  elsif p_value < 0.0001 and deseq_info[gene_pair] >= 0.0001
    diff1 += 1
  elsif p_value >= 0.0001 and deseq_info[gene_pair] < 0.0001
    diff2 += 1
  else
    diff3 += 1
  end
end

puts same, diff1, diff2, diff3


