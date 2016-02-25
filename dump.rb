# usage: ruby dump.rb <PID> <RESULT_FILE>
pid = ARGV[0]
filename = ARGV[1]

command = <<-COM
  bundle exec rbtrace -p #{pid} -e 'Thread.new{GC.start;require "objspace";io=File.open("/home/mz026/codes/codementor/memory-hunting/#{filename}", "w"); ObjectSpace.dump_all(output: io); io.close}'
COM

system command
