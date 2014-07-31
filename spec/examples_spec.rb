require 'rspec'


describe 'Gherkin Formatter' do
  it 'should be able to run all examples' do
    original_stdout = $stdout
    $stdout = File.new('/dev/null', 'w')
    Dir.glob(__dir__ << '/../examples/*.rb').each do |file|
      require file
    end
    $stdout = original_stdout
  end
end
