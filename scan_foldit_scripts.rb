#!/usr/bin/env ruby

require "#{Dir.getwd}/lib/foldit_script_helpers"

def process_script_file(code)
  FolditScript.new(
    :nl => count_lines(code),
    :hf => funcs_and_libraries(code),
    :il => long_runtime(code),
    :ig => is_genetic(code),
    :rs => has_recursion(code),
    :cs => checks_score(code),
    :st => checks_state(code),
    :cp => checks_protein(code),
    :rv => reverts_progress(code),
    :ub => profile_builtins(code)
  ).to_hash
end

FILE_STORE = ARGV[0]
RESULTS    = ARGV[1] || './results.log'

memo = []
Dir.entries(FILE_STORE).map {|n| "#{FILE_STORE}/#{n}"}.reject {|f| File.directory?(f) }.each do |f|
  memo << { :file => f, :res => process_script_file(File.read(f)) }
end

File.open(RESULTS,'w') do |f|
  memo.each do |hash|
    f.write("------------------------------------------------\n")
    f.write("File: #{hash[:file]}\n")
    f.write("Analysis: #{hash[:res].inspect}\n")
    f.write("#\n")
  end
end
exit(0)
