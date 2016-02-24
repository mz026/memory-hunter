require 'httparty'
require 'json'

url = 'http://localhost:9090/api/chatrooms/test-messages'
req_count = 500

req_count.times do |i|
  HTTParty.post(url,
                :body => {
                  message: {
                    content: 'hello this is the message',
                    push_at: Time.now.to_i
                  } }.to_json,
                headers: { 'Content-Type': 'application/json' })
end
