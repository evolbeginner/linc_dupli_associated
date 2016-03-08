#! /bin/env ruby

############################################################
def read_infiles_file(infile, cufflinks_files)
  File.open(infile, "r").each_line do |line|
    line.chomp!
    cufflinks_files << line.split(',')
  end
  return(cufflinks_files)
end

