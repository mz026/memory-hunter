require 'json'

class Analyzer
  class AnalyzeException < StandardError; end
  attr_reader :first_dump, :second_dump, :third_dump

  def self.group objs
    puts "grouping..."
    objs.group_by do |obj|
      { file: obj['file'], type: obj['type'], line: obj['line'] }
    end
  end

  def initialize(first_dump:, second_dump:, third_dump:)
    @first_dump = first_dump
    @second_dump = second_dump
    @third_dump = third_dump

    raise AnalyzeException, 'dump file does not exist' unless all_dumps_present?
  end

  def all_dumps_present?
    File.exist?(first_dump) && File.exist?(second_dump) && File.exist?(third_dump)
  end
  private :all_dumps_present?

  def leaked_objects
    leaked = []
    index = 1

    first_dump_addresses
    third_dump_addresses

    puts "couting leaked..."
    File.open(second_dump).each_line do |line|
      puts "counting index #{index}" if index % 1000 == 0
      parsed = JSON.parse(line)
      address = parsed['address']
      leaked << parsed if leaked?(address)
      index = index + 1
    end
    leaked
  end

  def first_dump_addresses
    return @first_dump_addresses if @first_dump_addresses

    puts "extracting dump1 addresses..."
    @first_dump_addresses = []
    File.open(first_dump).each_line do |line|
      obj = JSON.parse(line)
      @first_dump_addresses << obj['address'] if obj['address']
    end
    @first_dump_addresses
  end
  private :first_dump_addresses

  def third_dump_addresses
    return @third_dump_addresses if @third_dump_addresses

    puts "extracting dump3 addresses..."
    @third_dump_addresses = []
    File.open(third_dump).each_line do |line|
      obj = JSON.parse(line)
      @third_dump_addresses << obj['address'] if obj['address']
    end
    @third_dump_addresses
  end
  private :third_dump_addresses

  def leaked? address
    !first_dump_addresses.include?(address) && third_dump_addresses.include?(address)
  end
  private :leaked?
end
