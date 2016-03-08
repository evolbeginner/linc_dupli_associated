#! /bin/env ruby

require "getoptlong"


##################################################################
cufflinks_file = nil
gene_pair_file = nil
sep = "\t"

pairs = Array.new
fpkms = Hash.new


##################################################################
opts = GetoptLong.new(
  ["-i", "--cufflinks", GetoptLong::REQUIRED_ARGUMENT],
  ["--pair", "--pair_gene", GetoptLong::REQUIRED_ARGUMENT],
  ["--sep", GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt, value|
  case opt
    when "-i", "--cufflinks"
      cufflinks_file = value
    when "--pair", "--pair_gene"
      gene_pair_file = value
    when "--sep"
      sep = value
  end
end


##################################################################
File.open(gene_pair_file, "r").each_line do |line|
  line.chomp!
  genes = line.split(sep)
  pairs << genes
end


File.open(cufflinks_file, "r").each_line do |line|
  line.chomp!
  line_arr = line.split("\t")
  fpkm = line_arr[-4].to_f
  gene = line_arr[0]
  fpkms[gene] = fpkm
end


pairs.each do |genes|
  next if not fpkms.include?(genes[0]) or not fpkms.include?(genes[1])
  puts [genes.join("-"), fpkms[genes[0]], fpkms[genes[1]]].map{|i|i.to_s}.join("\t")
end


