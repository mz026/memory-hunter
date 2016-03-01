require 'json'
module TestUtils
  class DumpCreator
    def initialize
      @dumps = []
    end

    def create dump_contents
      filename = "#{__dir__}/fixtures/#{Random.rand(100000)}.dump"
      File.open(filename, 'w+') do |f|
        dump_contents.each {|o| f.puts o.to_json}
      end
      @dumps << filename
      filename
    end

    def clean
      @dumps.each {|f| File.unlink(f)}
    end
  end
end
