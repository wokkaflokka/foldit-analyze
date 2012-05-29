#!/usr/bin/ruby

# A script to write out Foldit recipes from the Application interface
# to the local filesystem. Works on MacOS, might work right away on windows too...

# Takes the following parameters:
#  1) Location of the 'all.macro' file (for MacOS, it is within the .app structure)
#  2) Location to write out scripts (defaults to current working directory)
require 'foldit_helpers'
include Foldit

macro_file = ARGV[0].chomp("\n")
out_dir = ARGV[1] || Dir.getwd.chomp("\n")

raise "Error: invalid macro file" unless File.exists?(macro_file)
raise "Error: invalid directory!" unless File.exists?(out_dir) and File.directory?(out_dir)

puts "We are about to write out all recipe files to the following location: #{out_dir}"
parse_macros_file(macro_file, out_dir.chomp("/"))
puts "Done!"

exit(0)
