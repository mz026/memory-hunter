# usage: ruby main.rb <DUMP1> <DUMP2> <DUMP3>
require_relative './analyzer'

MB = 1000000.0
analyzer = Analyzer.new(first_dump: ARGV[0], second_dump: ARGV[1], third_dump: ARGV[2])
grouped = Analyzer::group(analyzer.leaked_objects)

g = grouped.map do |key, objs|
  memsize = objs.inject(0) {|sum, o| sum + (o['memsize'] || 0)}
  bsize = objs.inject(0) {|sum, o| sum + (o['bytesize'] || 0)}
  {
    key: key,
    count: objs.count,
    size: memsize,
    bsize: bsize
  }
end

def log_to_file filename, data_arr
  f = File.open(filename, 'w+')
  data_arr.each do |data|
    memsize = data[:size] / MB
    bsize = data[:bsize] / MB
    f.puts "LEAKED #{data[:count]} #{data[:key][:type]} objects (#{memsize}/#{bsize}): #{data[:key][:file]}:#{data[:key][:line]}"
  end
  f.close
end

log_to_file("result-mem-#{Time.now.to_i}", g.sort_by {|data| - data[:size]})
log_to_file("result-byte-#{Time.now.to_i}", g.sort_by {|data| - data[:bsize]})

# f = File.open("result-mem-#{Time.now.to_i}", 'w+')
# g.sort_by do |data|
#   - data[:size]
# end.each do |data|
#   memsize = data[:size] / MB
#   bsize = data[:bsize] / MB
#   f.puts "LEAKED #{data[:count]} #{data[:key][:type]} objects (#{memsize}/#{bsize}): #{data[:key][:file]}:#{data[:key][:line]}"
# end
# f.close

# f = File.open("result-byte-#{Time.now.to_i}", 'w+')
# g.sort_by do |data|
#   - data[:bsize]
# end.each do |data|
#   memsize = data[:size] / MB
#   bsize = data[:bsize] / MB
#   f.puts "LEAKED #{data[:count]} #{data[:key][:type]} objects (#{memsize}/#{bsize}): #{data[:key][:file]}:#{data[:key][:line]}"
# end
# f.close
