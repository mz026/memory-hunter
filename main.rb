# usage: ruby main.rb <DUMP1> <DUMP2> <DUMP3>
require_relative './analyzer'

analyzer = Analyzer.new(first_dump: ARGV[0], second_dump: ARGV[1], third_dump: ARGV[2])
grouped = Analyzer::group(analyzer.leaked_objects)

grouped.each do |key, objs|
  size = objs.inject(0) {|sum, o| sum + (o['memsize'] || 0)}
  puts "LEAKED #{objs.count} #{key[:type]} objects (#{size}): #{key[:file]}:#{key[:line]}"
end
