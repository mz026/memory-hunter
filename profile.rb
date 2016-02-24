require 'httparty'
require 'json'

def worker_pids
  processes = `ps aux | grep unicorn`.split("\n")
  worker_strs = processes.select do |process_str|
    process_str.split[11].include?('worker')
  end

  worker_strs.map do |process_str|
    process_str.split[1]
  end
end

def memory_usage_of pid
  `ps ax -o pid,rss | grep -E "^[[:space:]]*#{pid}"`.strip.split.map(&:to_i)[1]
end

pid = ARGV[0]
url = 'http://localhost:9090/api/chatrooms/test-messages'
req_count = 3000

memory_usages = req_count.times.map do |i|
  HTTParty.post(url,
                :body => {
                  message: {
                    content: 'hello this is the message',
                    push_at: Time.now.to_i
                  } }.to_json,
                headers: { 'Content-Type': 'application/json' })
  mem = memory_usage_of(pid)/1000.0
  p "req #{i}: #{mem} mb"
  mem
end

p "difference after #{memory_usages.length} req: #{( memory_usages.last - memory_usages.first ).round(3)} mb"
