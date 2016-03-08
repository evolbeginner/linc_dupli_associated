#! /bin/env ruby

require "getoptlong"


########################################################
mnt3_sswang = "/mnt/bay3/sswang"
BEDOPS = File.join(mnt3_sswang, "software/NGS/basic_processing/bedops/")

gff1_file = nil
gff2_file = nil
outdir = nil
sep = "\t"


########################################################
opts = GetoptLong.new(
  ["--gff1", GetoptLong::REQUIRED_ARGUMENT],
  ["--gff2", GetoptLong::REQUIRED_ARGUMENT],
  ["--outdir", GetoptLong::REQUIRED_ARGUMENT],
  ["--sep", "--separator", "--connector", GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt, value|
  case opt
    when "--gff1"
      gff1_file = value
    when "--gff2"
      gff2_file = value
    when "--outdir"
      outdir = value
    when "--sep", "--separator", "--connector"
      sep = value
  end
end


system("mkdir -p #{outdir}") if ! File.directory?(outdir)
bed1_file = File.join(outdir, "1.bed")
bed2_file = File.join(outdir, "2.bed")
closest_feature_file = File.join(outdir, "closest_feature")
pair_output = File.join(outdir, "out_pair")


########################################################
system("export PATH=$PATH:#{BEDOPS}")

cmd = "gff2bed < #{gff1_file} > #{bed1_file}"
system(cmd)
cmd = "gff2bed < #{gff2_file} > #{bed2_file}"
system(cmd)

system("closest-features --closest #{bed1_file} #{bed2_file} > #{closest_feature_file}")


out_fh = File.open(pair_output, "w")
File.open(closest_feature_file, 'r').each_line do |line|
  line.chomp!
  line_arr = line.split("\t")
  out_fh.puts line_arr.values_at(3,12).join(sep)
end
out_fh.close


