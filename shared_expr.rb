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
is_output_gene_name = false

fpkms = Hash.new{|h1,k1|h1[k1]=Hash.new{|h2,k2|h2[k2]=[]}}
genes = Hash.new


##########################################################################
def read_gene_list(gene_list)
  genes = Hash.new
  File.open(gene_list, 'r').each_line do |line|
    line.chomp!
    genes[line] = ""
  end
  return(genes)
end


##########################################################################
opts = GetoptLong.new(
  ["-i", "--cufflinks", GetoptLong::REQUIRED_ARGUMENT],
  ["--gene_list", GetoptLong::REQUIRED_ARGUMENT],
  ["--pair", GetoptLong::REQUIRED_ARGUMENT],
  ["--sep", GetoptLong::REQUIRED_ARGUMENT],
  ["--with_gene", "--with_gene_name", "--gene_name", GetoptLong::NO_ARGUMENT],
  ["--read_infiles", "--read_infile", GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt, value|
  case opt
    when '-i', '--cufflinks'
      cufflinks_files << value.split(',')
    when '--gene_list'
      gene_list = value
    when '--read_infiles'
      cufflinks_files = read_infiles_file(value, cufflinks_files)
    when '--pair'
      pair_file = value
    when '--sep'
      sep = value
    when "--with_gene", "--with_gene_name", "--gene_name"
      is_output_gene_name = true
  end
end


##########################################################################
genes = read_gene_list(gene_list) if ! gene_list.nil?

cufflinks_files.each_with_index do |infiles, index|
  infiles.each do |cufflinks_file|
    File.open(cufflinks_file, 'r').each_line do |line|
      line.chomp!
      line_arr = line.split("\t")
      gene, fpkm = line_arr.values_at(0,-4)
      fpkm = fpkm.to_f
      #next if fpkm == 0
      #fpkm += 1
      status = fpkm == 0 ? 0 : 1
      if ! genes.empty?
        if genes.include?(gene)
          fpkms[gene][index] << status
        end
      else
        fpkms[gene][index] << status
      end
    end
  end

  fpkms.each_pair do |gene, v|
    if v[index].size < infiles.size
      fpkms[gene][index] = [0] * infiles.size
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
  fpkms[gene] = Array.new
  v.values.each do |i|
    fpkms[gene] << i
  end
  fpkms.delete(gene) if fpkms[gene].empty?
end


##########################################################################
File.open(pair_file, "r").each_line do |line|
  line.chomp!
  genes = line.split(sep)
  next if not fpkms.include?(genes[0]) or not fpkms.include?(genes[1])
  if is_output_gene_name
    name = genes.join(sep)
  end

  same = 0
  total = 0
  win1 = 0
  win2 = 0 
  is_reciprocal = 0
  tec = Float::NAN
  fpkms[genes[0]].each_with_index do |ele1, index|
    ele2 = fpkms[genes[1]][index]
    if ele1 == 1 and ele2 == 1
      same += 1
    end
    if ele1 == 1 or ele2 == 1
      total += 1
    end
    if ele1 == 1 and ele2 == 0
      win1 += 1
    end
    if ele1 == 0 and ele2 == 1
      win2 += 1
    end
  end
  tec = (win1.to_f/(win1+same) + win2.to_f/(win2+same))/2

  if win1 != 0 and win2 != 0
    is_reciprocal = 1
  end

  puts [name,same,total,same/total.to_f, is_reciprocal, tec].map{|i|i.to_s}.join("\t")
end


