require 'rspec'
require __dir__ + '/../lib/gherkin_generator'

describe 'Gherkin Formatter' do

  it 'should output feature name' do
    gf = GherkinGenerator.new 'My Feature'
    expect(gf.to_gherkin).to eq <<EOS
Feature: My Feature
EOS
  end

  it 'should output description' do
    gf = GherkinGenerator.new 'abc'
    gf.description = 'def'
    expect(gf.to_gherkin).to eq <<EOS
Feature: abc
	def
EOS
  end

  it 'should accept multiline description' do
    gf = GherkinGenerator.new 'abc'
    gf.description = "def\nghi"
    expect(gf.to_gherkin).to eq <<EOS
Feature: abc
	def
	ghi
EOS
  end

  it 'should output basic scenario' do
    gf = GherkinGenerator.new 'abc'
    gf.description = 'def'
    gf.add_scenario 'My Scenario: Given I have a scenario'
    expect(gf.to_gherkin).to eq <<EOS
Feature: abc
	def

	Scenario: My Scenario
		Given I have a scenario
EOS
  end

  it 'should output multiple scenario' do
    gf = GherkinGenerator.new 'My Full Feature'
    gf.description = 'This has multiple scenarios'
    gf.add_scenario 'My Scenario: Given I have a scenario'
    gf.add_scenario 'Another Scenario: Given I have another scenario'
    expect(gf.to_gherkin).to eq <<EOS
Feature: My Full Feature
	This has multiple scenarios

	Scenario: My Scenario
		Given I have a scenario

	Scenario: Another Scenario
		Given I have another scenario
EOS
  end

  it 'should output multiple steps in one scenario' do
    gf = GherkinGenerator.new 'My Full Feature'
    gf.description = 'This has multiple scenarios'
    gf.add_scenario 'My Scenario: Given I have a step And I have another step'
    expect(gf.to_gherkin).to eq <<EOS
Feature: My Full Feature
	This has multiple scenarios

	Scenario: My Scenario
		Given I have a step
		And I have another step
EOS
  end

  it 'should support all step types' do
    gf = GherkinGenerator.new 'abc'
    gf.add_scenario 'My Scenario: Given I have a step And I have ' \
                        'another step Given I have another given When I do ' \
                        'something Then something should happen'
    expect(gf.to_gherkin).to eq <<EOS
Feature: abc

	Scenario: My Scenario
		Given I have a step
		And I have another step
		Given I have another given
		When I do something
		Then something should happen
EOS
  end

  it 'should support tags for a scenario' do
    gf = GherkinGenerator.new 'abc'
    scenario = gf.add_scenario 'My Scenario: Given I have a step'
    scenario.add_tag 'wip'
    expect(gf.to_gherkin).to eq <<EOS
Feature: abc

	@wip
	Scenario: My Scenario
		Given I have a step
EOS
  end

  it 'should support multiple tags for a scenario' do
    gf = GherkinGenerator.new 'abc'
    scenario = gf.add_scenario 'My Scenario: Given I have a step'
    scenario.add_tag 'wip'
    scenario.add_tag 'ignore'
    expect(gf.to_gherkin).to eq <<EOS
Feature: abc

	@wip @ignore
	Scenario: My Scenario
		Given I have a step
EOS
  end

  it 'should support only tag one scenario' do
    gf = GherkinGenerator.new 'abc'
    gf.add_scenario 'My Scenario: Given I have a step'
    scenario = gf.add_scenario 'Another Scenario: Given I have a step'
    scenario.add_tag 'wip'
    expect(gf.to_gherkin).to eq <<EOS
Feature: abc

	Scenario: My Scenario
		Given I have a step

	@wip
	Scenario: Another Scenario
		Given I have a step
EOS
  end

  describe 'Scenario Outlines' do
    it 'should lookup examples' do
      called = false
      gf = GherkinGenerator.new 'abc'
      gf.example_handler do |url|
        expect(url).to eq('http://abc.com/def?ghi=jkl')
        called = true
        ''
      end
      gf.add_scenario 'My Scenario: Given I have a <type> Examples http://abc.com/def?ghi=jkl'
      expect(called).to be(true)
    end
    it 'should pass through url' do
      called = false
      gf = GherkinGenerator.new 'abc'
      gf.example_handler do |url|
        expect(url).to eq('ABC def')
        called = true
        ''
      end
      gf.add_scenario 'My Scenario: Given I have a <type> Examples ABC def'
      expect(called).to be(true)
    end
    it 'should include example' do
      gf = GherkinGenerator.new 'abc'
      gf.example_handler do
        <<EOS
| abc | def |
-------------
| ghi | jkl |
| mno | qrs |
EOS
      end
      gf.add_scenario 'My Scenario: Given I have a <type> Examples ABC'
      expect(gf.to_gherkin).to eq <<EOS
Feature: abc

	Scenario Outline: My Scenario
		Given I have a <type>
	Examples:
		| abc | def |
		-------------
		| ghi | jkl |
		| mno | qrs |
EOS
    end
  end
end
