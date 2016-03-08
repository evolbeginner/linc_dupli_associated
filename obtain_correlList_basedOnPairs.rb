#! /bin/env ruby

require "getoptlong"


##################################################################################
infiles1 = Array.new
infiles2 = Array.new
field1 = 2
field2 = 2
pair_file = nil
sep = "\t"
is_fold1 = false
is_fold2 = false
is_log2_1 = false
is_log2_2 = false
min1 = nil
min2 = nil


##################################################################################
def read_files(infiles, field, min)
  info = Hash.new{|h,k|h[k]=[]}
  infiles.each do |infile|
    File.open(File::expand_path(infile), "r").each_line do |line|
      line.chomp!
      line_arr = line.split("\t")
      gene = line_arr[0]
      value = line_arr[field-1].to_f
      if not min.nil?
        next if value < min
      end
      info[gene] << value.to_f
    end
  end
  info.each_pair do |gene,k|
    info[gene] = k.reduce(:+).to_f/infiles.size
  end
  return(info)
end


def get_relative_diver(v1, v2, is_fold=false, is_log2=false)
  if is_log2
    v1 = Math.log2(v1+0.001)
    v2 = Math.log2(v2+0.001)
  end
  v1 += 1e-6
  v2 += 1e-6
  if is_fold
    return([v1,v2].max/[v1,v2].min.to_f)
  else
    return((v1-v2).abs/(v1+v2).to_f)
  end
end


##################################################################################
opts = GetoptLong.new(
  ["--i1", GetoptLong::REQUIRED_ARGUMENT],
  ["--i2", GetoptLong::REQUIRED_ARGUMENT],
  ["--f1", GetoptLong::REQUIRED_ARGUMENT],
  ["--f2", GetoptLong::REQUIRED_ARGUMENT],
  ["--pair", "--gene_pair", GetoptLong::REQUIRED_ARGUMENT],
  ["--sep", "--separator", GetoptLong::REQUIRED_ARGUMENT],
  ["--fold", GetoptLong::REQUIRED_ARGUMENT],
  ["--log2", GetoptLong::REQUIRED_ARGUMENT],
  ["--min1", GetoptLong::REQUIRED_ARGUMENT],
  ["--min2", GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt, value|
  case opt
    when "--i1"
      value.split(',').each do |i|
        infiles1 << i
      end
    when "--i2"
      value.split(',').each do |i|
        infiles2 << i
      end
    when "--f1"
      field1 = value.to_i
    when "--f2"
      field2 = value.to_i
    when "--pair", "--gene_pair"
      pair_file = value
    when "--sep", "--separator"
      sep = value
    when "--fold"
      value.split(",").each do |i|
        is_fold1 = true if i =~ /1/
        is_fold2 = true if i =~ /2/
      end
    when "--log2"
      value.split(",").each do |i|
        is_log2_1 = true if i =~ /1/
        is_log2_2 = true if i =~ /2/
      end
    when "--min1"
      min1 = value.to_f
    when "--min2"
      min2 = value.to_f
  end
end


##################################################################################
gene_info1 = read_files(infiles1, field1, min1)
gene_info2 = read_files(infiles2, field2, min2)


if pair_file.nil?
  gene_info1.each_pair do |gene, value|
    next if not gene_info2.include?(gene)
    puts [gene, value, gene_info2[gene]].map{|i|i.to_s}.join("\t")
  end
  exit
end


File.open(pair_file ,"r").each_line do |line|
  line.chomp!
  genes = line.split(sep)
  next if not gene_info1.include?(genes[0]) or not gene_info1.include?(genes[1])
  next if not gene_info2.include?(genes[0]) or not gene_info2.include?(genes[1])
  relative_diver1 = get_relative_diver(gene_info1[genes[0]], gene_info1[genes[1]], is_fold1, is_log2_1)
  relative_diver2 = get_relative_diver(gene_info2[genes[0]], gene_info2[genes[1]], is_fold2, is_log2_2)
  puts [genes.join(sep), relative_diver1, relative_diver2].map{|i|i.to_s}.join("\t")
end


