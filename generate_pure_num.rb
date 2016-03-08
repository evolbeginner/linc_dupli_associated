#! /bin/env ruby

require "getoptlong"


############################################################
input_find_fifo = nil
infiles = Array.new
outdir = nil
is_force = false


############################################################
opts = GetoptLong.new(
  ["-i", GetoptLong::REQUIRED_ARGUMENT],
  ["--input_find", GetoptLong::REQUIRED_ARGUMENT],
  ["--outdir", GetoptLong::REQUIRED_ARGUMENT],
  ["--force", GetoptLong::NO_ARGUMENT],
)


opts.each do |opt, value|
  case opt
    when "--input_find"
      input_find_fifo = IO.popen(value)
    when "--outdir"
      outdir = value
    when "--force"
      is_force = true
  end
end


input_find_fifo.each_line do |file|
  next if File::dirname(file) =~ /\/#{outdir}/
  file.chomp!
  infiles << file
end

if File.directory?(outdir) and is_force
  `rm -rf #{outdir}`
end
`mkdir -p #{outdir}`


############################################################
infiles.each do |infile|
  next if File::directory?(infile)
  dirname = File::dirname(infile)
  basename = File::basename(infile)
  new_dirname = File.join(outdir, dirname)
  new_filename = File.join(new_dirname, basename)
  `mkdir -p #{new_dirname}` if ! File.directory?(new_dirname)
  #`awk '{print $2}' #{infile} > #{new_filename}`
  `awk 'BEGIN{OFS="\t"}{a=""; for(i=2;i<=NF;i++){a=a$i"\t"}; print a}' #{infile} > #{new_filename}`
end


