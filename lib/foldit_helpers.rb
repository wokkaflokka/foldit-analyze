module Foldit
  def parse_macros_file(recipes_file, location)
    recipes = File.read(recipes_file).split("\n")
    # Ensure we loaded the right file...
    verify_macro_file(recipes)
    # Write the code out to files...
    code  = find_code(recipes.select{|r|is_scriptable(r)})
    names = find_name(recipes.select{|r|is_scriptable(r)})
    print_scripts(code, names, location)
  end

  def parse_recipe_info(recipes_file, location)
    recipes = File.read(recipes_file).split("\n")
    # Ensure we loaded the right file...
    verify_macro_file(recipes)
    # Write the info out as YAML
    names    = find_name(recipes.select{|r|is_scriptable(r)})
    parents  = find_parent(recipes.select{|r|is_scriptable(r)})
    nodes    = find_recipe_url(recipes.select{|r|is_scriptable(r)})
    pids     = find_player(recipes.select{|r|is_scriptable(r)})
    print_rec_info(names, parents, nodes, pids, location)
  end

  def find_code(recipes)
    process_array(find_block(recipes, 'script', 'script_version'))
  end

  def find_name(recipes)
    process_array(find_block(recipes, 'name', 'parent'))
  end

  def find_parent(recipes)
    process_array(find_block(recipes, 'parent', 'parent_mrid'))
  end

  def find_recipe_url(recipes)
    process_array(find_block(recipes, 'mid', 'mrid'))
  end

  def find_player(recipes)
    process_array(find_block(recipes, 'player_id', 'script'))
  end

  def find_block(recipes, start, close)
    container = []
    # this delimiter splits each entry in the recipe item
    s,e = 0
    recipes.each do |r_string|
      r = r_string.split('\\n ')
      r.each_with_index { |l,i|
        if l.include?("\\\"#{start}\\\" : ")
          s = i
        elsif l.include?("\\\"#{close}\\\" : ")
          e = i
        end
      }
      raise "Didn't find the block" if s == e
      container << r[s..(e-1)].join('\\n ')[0..-3]
    end
    return container
  end

  def print_scripts(scripts, names, bucket)
    scripts.each_with_index do |s,i|
      # Find the line delimiter
      d = s.include?('\\\r\\\n') ? '\\\r\\\n' : '\\\n'
      begin
        fname = names[i].downcase.strip.gsub(' ','').gsub('_','-').gsub('.','-')
        file = File.open("#{bucket}/#{fname}.lua","w")
        # break on line delimiter
        code = s.split(d)
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

  def print_rec_info(names, parents, nids, pids, bucket)
    File.open("#{bucket}/recipe_info.yaml", "w") { |f|
      names.each_with_index do |n,i|
        f.puts("'#{n}':")
        f.puts("    'parent': '#{parents[i]}'")
        f.puts("    'nid'   : '#{nids[i]}'")
        f.puts("    'pid'   : '#{pids[i]}'")
        f.puts
      end
    }
  end

  def is_scriptable(r_string)
    r_string.include?('type') && r_string.include?('script')
  end

  def trim_array(array)
    array.shift
    array.pop
  end

  def process_array(r)
    item = []
    r.each {|a|
      t = a.split('\\n ')
      s = t.shift
      q = s.split(' : \\"').pop.to_s
      t.insert(0,q)
      item << t.join('\\n ')
    }
    item
  end

  def verify_macro_file(recipes)
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
  end
end
