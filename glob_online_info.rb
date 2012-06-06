#!/usr/bin/env ruby

require 'rubygems'
require 'excon'
require 'yaml'

# A script to download the HTML of a given recipe or user
# from the Foldit website

# Args: (optional) takes the location of the file containing necessary info from commandline

FOLDIT_HOST = "http://fold.it/portal"
RECIPE_INFO = "recipe_info.yaml"
INFO_STORE  = ARGV[0] || Dir.getwd

def get(resource)
  Excon.get(resource)
end

def recipe(nid)
  "#{FOLDIT_HOST}/recipe/#{nid}"
end

def player(nid)
  "#{FOLDIT_HOST}/user/#{nid}"
end

def load_yaml(file)
  raise "Bad args" unless File.exist?(file)
  hash = YAML::load_file(file)
  raise "Not a yaml file" unless hash.kind_of?(Hash)
  hash
end

analysis = {}

puts "Looking for recipe YAML in #{INFO_STORE}"
recipes = load_yaml("#{INFO_STORE}/#{RECIPE_INFO}")
recipes.each do |k,v|
  analysis[k] = {'parent' => '', 'self' => '', 'user' => ''}
  unless v['parent'] == '0'
    p = get(recipe(v['parent']))
    analysis[k]['parent'] = p.body
    puts "Parent returned status: #{p.status}"
  end
  s = get(recipe(v['nid']))
  u = get(player(v['pid']))
  puts "Recipe returned status: #{s.status}"
  puts "User returned status: #{u.status}"
  analysis[k]['recipe'] = s.body
  analysis[k]['user'] = u.body
end

puts "Saving our scraped data in #{INFO_STORE}"

i = 0
analysis.each do |k,v|
  File.open("#{INFO_STORE}/scraped-recipe-info-#{i+=1}.log", "w") do |f|
    f.puts("#{k} =>")
    f.puts("#{analysis[k]['recipe']}")
  end
end
exit(0)
