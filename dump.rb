# usage: ruby dump.rb <PID> <RESULT_FILE>
pid = ARGV[0]
filename = ARGV[1]

command = <<-COM
  bundle exec rbtrace -p #{pid} -e 'Thread.new{GC.start;require "objspace";io=File.open("#{__dir__}/#{filename}", "w"); ObjectSpace.dump_all(output: io); io.close}'
COM

system command
