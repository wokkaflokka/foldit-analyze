#!/usr/bin/ruby

# A script to write out Foldit recipes from the Application interface
# to the local filesystem. Works on MacOS, might work right away on windows too...

# Takes the following parameters:
#  1) Location of the 'all.macro' file (for MacOS, it is within the .app structure)
#  2) Location to write out scripts (defaults to current working directory)


def parse_macros_file(recipes_file, location)
  recipes = File.read(recipes_file).split("\n")

  # Verify foldit constants
  unless recipes.first =~ /version: \d/
    raise "Ill-formed macros file: first line must be version string"
  end
  unless recipes.last =~ /verify: [a-zA-Z0-9]*/
    raise "Ill-formed macros file: last line must be verification string"
  end
  trim_array(recipes) # get rid of cruft
  unless recipes.first =~ /\{/ and recipes.last =~ /\}/
    raise "Ill-formed macros file: does not appear to be valid json"
  end
  trim_array(recipes) # more cruft...

  # Write the code out to files...
  print_scripts(find_code(recipes.select{|r|is_scriptable(r)}), location)
end

def print_scripts(scripts, bucket)
  fname = 'recipe-' # name to save as
  scripts.each_with_index do |s,i|
    # Find the line delimiter
    d = s.include?('\\\r\\\n') ? '\\\r\\\n' : '\\\n'
    begin
      file = File.open("#{bucket}/#{fname}#{i}.lua","w")
      code = s.split(d) # break on line delimiter
      code.each do |line|
        # Remove escape sequences
        temp = line.gsub("\\\\\\",'')
        # Look for tabs..
        if temp.include?("\\\\t")
          temp.gsub!("\\\\t","\t")
        end
        file.puts(temp)
      end
    rescue => e
      puts e.inspect
    ensure
      file.close
    end
  end
end

def find_code(recipes)
  container = []
  # this delimiter splits each entry in the recipe item
  delim = Regexp.new(" : ")
  recipes.each do |r_string|
    code = ''
    until r_string.empty?
      # Read through each entry until we find the script code...
      d = r_string.match(delim)
      break if d.nil?
      if d.pre_match.include?('"script\\')
        code = d.post_match
        break
      end
      r_string = d.post_match
    end
    if code.empty?
      puts "Failed to find script code for recipe #{r_string}"
    else
      # Removes a leading quote at the beginning of the match
      pm = code.match(delim).pre_match[2..-1]
      container << pm.split("\\\"\\n \\\"script_version").first
    end
  end
  container
end

def is_scriptable(r_string)
  r_string.include?('type') && r_string.include?('script')
end

def trim_array(array)
  array.shift
  array.pop
end

macro_file = ARGV[0].chomp("\n")
out_dir = ARGV[1] || Dir.getwd.chomp("\n")

raise "Error: invalid macro file" unless File.exists?(macro_file)
raise "Error: invalid directory!" unless File.exists?(out_dir) and File.directory?(out_dir)

puts "We are about to write out all recipe files to the following location: #{out_dir}"
parse_macros_file(macro_file, out_dir.chomp("/"))
puts "Done!"

exit(0)
