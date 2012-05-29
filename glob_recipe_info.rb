#!/usr/bin/ruby

# A script to write out some basic information about each recipe.

# Takes the following parameters:
#  1) Location of the 'all.macro' file (for MacOS, it is within the .app structure)

require 'lib/foldit_helpers'
include Foldit

macro_file = ARGV[0].chomp("\n")
out_dir = ARGV[1] || Dir.getwd.chomp("\n")

raise "Error: invalid macro file" unless File.exists?(macro_file)
raise "Error: invalid directory!" unless File.exists?(out_dir) and File.directory?(out_dir)

parse_recipe_info(macro_file, out_dir)
exit(0)
