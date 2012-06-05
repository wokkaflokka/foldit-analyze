#!/usr/bin/env ruby

require 'nokogiri'

def panel_data panel
  "#{panel_named(panel)}/../div[2]/ul/li"
end

def panel_named a
  ".//*[@class='panel-title' and contains(text(),'#{a}')]"
end

def process_html_files(files, &blk)
  files.each do |f|
    yield(Nokogiri::HTML(File.open(f,'r')))
  end
end

def search_with_scope(artifact, context, &blk)
  artifact.search(context).each do |subcontext|
    yield(subcontext)
  end
end

def search_for_text(artifact, text)
  artifact.search("//*[contains(text(),'#{text}')]")
end

def glob_rating_data(html)
  data = {}
  search_with_scope(html, '#rating') do |context|
    if context.inner_text.match(/Used (\d+) times with an average impact of (-?)(\d+) points/i)
      data['usage']  = $0
      data['points'] = ($1 =~ /-/) ? "-#{$2}" : $2
    else
      data['usage'] = data['points'] = -1
    end
    {'avg' => '.average-rating','votes' => '.total-votes' }.each do |key, elem|
      search_with_scope(context, elem) do |subcontext|
        data[key] = (key == 'avg')? subcontext.inner_text.split(' ').last : subcontext.inner_text.split(' ').first.gsub('(','')
      end
    end
  end
  data
end

def glob_auxiliary_data(html)
  data = {}
  search_with_scope(html, '.macro-right') do |context|
    data['parent']   = (context.search(panel_data('Parent')).inner_text =~ /none/i) ? "0" : "1"
    data['children'] = context.search(panel_data('Children')).size
    data['authors']  = {}
    search_with_scope(context, panel_data('Authors')) do |subcontext|
      data['authors'][subcontext.inner_text.split(' ').first] = {
        'solo'   => subcontext.search('.schl-so').inner_text,
        'evolve' => subcontext.search('.schl-ev').inner_text
      }
    end
  end
  search_with_scope(html, '.macro-left') do |context|
    unless context.search('.best-for-list').empty?
      data['best-for-list'] = context.search('.best-for-list').map {|e| e.inner_text }
    end
  end
  data
end

def glob_human_data(html)
  data = {}
  strings = [
    'beginning', 'start', 'middle', 'end', 'long', 'fast', 'quick', 'score', 'great',
    'smart', 'bug', 'thank', 'slow', 'need', 'prerequisite', 'huge', 'initial', 'hours', 'forever',
    'old', 'new','intermedia', 'early', 'late', 'improve', 'restore', 'fix', 'probe', 'test', 'stabili', 'longer',
    'modifi', 'best', 'repear', 'recurs', 'team', 'compete', 'unfair', 'defect'
  ]
  data['comments'] = html.search('#forum-comments .forum-post').size.to_s
  data['sentiment_analysis'] = {}
  strings.each do |s|
    findings = search_for_text(html,s)
    data['sentiment_analysis'][s] = {
      :count   => findings.size,
      :context => findings.map { |f| f.inner_text }
    }
  end
  data
end

def log_processing_results(data)
  File.open(data[:out],'a') do |f|
    f.write("------------------------------------------------\n")
    f.write("Rating: #{data[:rating].inspect}\n")
    f.write("Context: #{data[:aux].inspect}\n")
    f.write("Expressed: #{data[:human].inspect}\n")
    f.write("#")
  end
end

FILES_DIR  = ARGV[0]
OUTPUT_LOG = ARGV[1] || './recipe-scan-log.log'
exit(-1) unless File.exist?(FILES_DIR) and File.directory?(FILES_DIR)
files = Dir.entries(FILES_DIR).reject {|f| File.directory?(f) }.map {|n| "#{FILES_DIR}/#{n}"}
`rm -f #{OUTPUT_LOG}` if File.exist?(OUTPUT_LOG)

process_html_files(files) do |html|
  log_processing_results({
      :rating => glob_rating_data(html),
      :human  => glob_human_data(html),
      :aux    => glob_auxiliary_data(html),
      :out    => OUTPUT_LOG
  })
end

exit(0)
