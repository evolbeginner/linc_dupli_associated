#! /bin/env ruby2.1

BEGIN{
  file_name=__FILE__
  $: << [File.dirname(file_name),'lib'].join('/')
}

require 'getoptlong'
require 'basic_math'

require 'read_infiles_file'


##########################################################################
cufflinks_files = Array.new #Hash.new{|h,k|h[k]=[]}
gene_list = nil
pair_file = nil
sep = "\t"
n = nil
mode = "Spearman"
cufflinks_gene_field = 4
is_expr_breadth = false
is_highest = false
is_output_gene_name = false

fpkms = Hash.new{|h1,k1|h1[k1]=Hash.new{|h2,k2|h2[k2]=[]}}
genes = Hash.new
highest = Hash.new
all_genes = Array.new


##########################################################################
def read_gene_list(gene_list)
  genes = Hash.new
  File.open(gene_list, 'r').each_line do |line|
    line.chomp!
    genes[line] = ""
  end
  return(genes)
end


def calculate_euclidean_distance(values1, values2)
  sum = 0
  0.upto(values1.size-1).each do |i|
    sum += (values1[i]-values2[i]) ** 2
  end
  distance = sum ** (0.5)
  return(distance)
end


##########################################################################
opts = GetoptLong.new(
  ["-i", "--cufflinks", GetoptLong::REQUIRED_ARGUMENT],
  ["--mode", GetoptLong::REQUIRED_ARGUMENT],
  ["--gene_list", GetoptLong::REQUIRED_ARGUMENT],
  ["--pair", GetoptLong::REQUIRED_ARGUMENT],
  ["--sep", GetoptLong::REQUIRED_ARGUMENT],
  ["--read_infiles", "--read_infile", GetoptLong::REQUIRED_ARGUMENT],
  ["--with_gene", "--with_gene_name", "--gene_name", GetoptLong::NO_ARGUMENT],
  ["--cufflinks_gene_field", GetoptLong::NO_ARGUMENT],
)

opts.each do |opt, value|
  case opt
    when '-i', '--cufflinks'
      cufflinks_files << value.split(',')
    when "--mode"
      mode = value
    when '--gene_list'
      gene_list = value
    when '--pair'
      pair_file = value
    when '--sep'
      sep = value
    when '--read_infiles'
      cufflinks_files = read_infiles_file(value, cufflinks_files)
    when "--with_gene", "--with_gene_name", "--gene_name"
      is_output_gene_name = true
    when "--cufflinks_gene_field"
      cufflinks_gene_field = value.to_i
  end
end


##########################################################################
genes = read_gene_list(gene_list) if ! gene_list.nil?


cufflinks_files.each_with_index do |infiles, index|
  infiles.each do |cufflinks_file|
    File.open(cufflinks_file, 'r').each_line do |line|
      line.chomp!
      line_arr = line.split("\t")
      gene, fpkm = line_arr.values_at(0, cufflinks_gene_field)
      fpkm = fpkm.to_f
      if ! genes.empty?
        if genes.include?(gene)
          fpkms[gene][index] << Math.log2(fpkm+0.000001)
        end
      else
        fpkms[gene][index] << Math.log2(fpkm+0.000001)
      end
    end
  end

  fpkms.each_pair do |gene, v|
    if v[index].size < infiles.size
      fpkms[gene].delete(index)
    end
  end
end


fpkms.each_pair do |gene, v1|
  v1.each_pair do |index, v2|
    v1[index] = v2.reduce(:+)/v2.size  
  end
end


n = ! n.nil? ? n : cufflinks_files.size
fpkms.each_pair do |gene, v|
  if is_highest
    if is_highest and ! v.to_a.empty?
      highest[gene] = (v.to_a.sort_by{|i|i[1].to_f}.reverse)[0][0] if is_highest
    end
  end
  a = v
  fpkms[gene] = Array.new
  a.values.each do |i|
    fpkms[gene] << i
  end
  fpkms.delete(gene) if a.empty?
end


##########################################################################
File.open(pair_file, "r").readlines.each do |line|
  line.chomp!
  genes = line.split(sep)
  all_genes << genes
end

(all_genes.sort!).uniq!
all_genes.each do |genes|
  next if not fpkms.include?(genes[0]) or not fpkms.include?(genes[1])
  if is_output_gene_name
    name = genes.join(sep)
  end
  values = [fpkms[genes[0]], fpkms[genes[1]]]
  distance = Float::NAN
  next if values[0].size != values[1].size
  case mode
    when "Spearman_correl"
      distance = spearman_correlate(values[0], values[1])
    when "Spearman"
      distance = 1 - spearman_correlate(values[0], values[1])
    when "Euclidean"
      distance = calculate_euclidean_distance(values[0], values[1])
  end
  puts [name, distance].map{|i|i.to_s}.join("\t")
end



