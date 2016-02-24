require 'json'
class Analyzer
  attr_reader :data
  def initialize(filename)
    @filename = filename
    @data = []
    File.open(@filename) do |f|
      f.each_line do |line|
        @data << (JSON.parse(line))
      end
    end
  end

  def analyze log
    data.group_by{|row| row["generation"]}
      .sort{|a,b| a[0].to_i <=> b[0].to_i}
      .map do |k,v|
        log.puts "generation #{k} objects #{v.count}"
        k
      end
  end

  def analyze_generation generation, log
    log.puts "=========== #{generation} =============\n"
    gen_data = data.select {|d| d['generation'] == generation}

    gen_data.group_by{|row| "#{row["file"]}:#{row["line"]}"}
      .sort{|a,b| b[1].count <=> a[1].count}
      .each do |k,v|
        memsize = v.inject(0) {|sum, o| sum + (o['memsize'] || 0)}
        log.puts "#{k} * #{v.count} - #{memsize}"# if (k.include?('api') && v.count > 400)
      end
    log.puts("\n" * 3)
  end
end

file_name = ARGV[0]
log = File.open('log', 'w+')

analyzer = Analyzer.new file_name
generations = analyzer.analyze log

generations.each do |g|
  if g
    analyzer.analyze_generation g, log
  end
end

# generation = ARGV[1]
#
# if generation
#   Analyzer.new(file_name).analyze_generation(generation.to_i)
# else
#   Analyzer.new(file_name).analyze
# end
