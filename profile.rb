require 'httparty'
require 'json'
require 'yaml'

def memory_usage_of pid
  `ps ax -o pid,rss | grep -E "^[[:space:]]*#{pid}"`.strip.split.map(&:to_i)[1]
end

pid = ARGV[0]
req_config = YAML.load_file('request.yml')
count = req_config['count']

memory_usages = count.times.map do |i|
  HTTParty.send(req_config['method'], req_config['url'],
                  :body => req_config['body'].to_json,
                  :headers => req_config['headers'])
  mem = memory_usage_of(pid)/1000.0
  puts "req #{i}: #{mem} mb"
  mem
end

puts "difference after #{memory_usages.length} req: #{( memory_usages.last - memory_usages.first ).round(3)} mb"
