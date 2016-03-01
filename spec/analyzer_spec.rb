require_relative '../analyzer'
require_relative './support'

describe Analyzer do
  let!(:dump_creator) { TestUtils::DumpCreator.new }
  after :each do
    dump_creator.clean
  end

  describe '::new(first_dump:, second_dump:, third_dump:)' do
    it 'raises if not all dump files exists' do
      expect(lambda {
        Analyzer.new(first_dump: 'not-exist', second_dump: 'unknown', third_dump: 'no-such-file')
      }).to raise_error(Analyzer::AnalyzeException, 'dump file does not exist')
    end

    it 'takes three dumps to init' do
      first_dump = dump_creator.create([{ type: 'ROOT' }])
      second_dump = dump_creator.create([{ type: 'STRING' }])
      third_dump = dump_creator.create([{ type: 'ARRAY' }])

      Analyzer.new(first_dump: first_dump,
                   second_dump: second_dump,
                   third_dump: third_dump)
    end
  end

  describe '#leaked_objects' do
    let(:dump1) do
      dump_creator.create([
        { adderss: 'gc-ed-1' },
        { address: 'long-lived-1' }
      ])
    end

    let(:dump2) do
      dump_creator.create([
        { address: 'gc-ed-2' },
        { address: 'leaked-1' },
        { address: 'leaked-2' },
        { address: 'long-lived-1' }
      ])
    end

    let(:dump3) do
      dump_creator.create([
        { address: 'gc-ed-3' },
        { address: 'leaked-1' },
        { address: 'leaked-2' },
        { address: 'long-lived-1' }
      ])
    end

    let(:analyzer) do
      Analyzer.new({
        first_dump: dump1,
        second_dump: dump2,
        third_dump: dump3
      })
    end

    it 'returns the remaining objects ' do
      expect(analyzer.leaked_objects).to eq([
        { 'address' => 'leaked-1' }, { 'address' => 'leaked-2' } ])
    end
  end

  describe '::group(leaked_objects)' do
    let(:leaked_objs) do
      [
        { 'file' => 'file1', 'type' => 'OBJECT', 'line' => 10, 'memsize' => 100 },
        { 'file' => 'file1', 'type' => 'OBJECT', 'line' => 10, 'memsize' => 200 },
        { 'file' => 'file1', 'type' => 'ARRAY', 'line' => 10, 'memsize' => 200 },
        { 'file' => 'file1', 'type' => 'ARRAY', 'line' => 10, 'memsize' => 300 },
        { 'file' => 'file2', 'type' => 'ARRAY', 'line' => 20, 'memsize' => 300 },
        { 'file' => 'file3', 'type' => 'ARRAY', 'line' => 30, 'memsize' => 300 }
      ]
    end
    it 'group leaked objects by line number and types' do
      grouped = Analyzer::group(leaked_objs)
      expect(grouped).to eq({
        { file: 'file1', line: 10, type: 'OBJECT' } => [
          { 'file' => 'file1', 'type' => 'OBJECT', 'line' => 10, 'memsize' => 100 },
          { 'file' => 'file1', 'type' => 'OBJECT', 'line' => 10, 'memsize' => 200 }
        ],
        { file: 'file1', line: 10, type: 'ARRAY' } => [
          { 'file' => 'file1', 'type' => 'ARRAY', 'line' => 10, 'memsize' => 200 },
          { 'file' => 'file1', 'type' => 'ARRAY', 'line' => 10, 'memsize' => 300 }
        ],
        { file: 'file2', line: 20, type: 'ARRAY' } => [
          { 'file' => 'file2', 'type' => 'ARRAY', 'line' => 20, 'memsize' => 300 }
        ],
        { file: 'file3', line: 30, type: 'ARRAY' } => [
          { 'file' => 'file3', 'type' => 'ARRAY', 'line' => 30, 'memsize' => 300 }
        ],

      })
    end
  end
end
