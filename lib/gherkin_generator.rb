# A simple tool for generating Gherkin Feature Files programmatically.
#
# = Example
#
#   gg = GherkinGenerator.new("My Feature")
#   gg.add_scenario("Something: When I do something Then something should have happened")
#   gg.add_scenario("Something Else: When I do something else Then something else should have happened")
#   puts gg.to_gherkin
#
class GherkinGenerator
  ##
  # A multiline feature description
  #
  # = Example
  #
  #   GherkinGenerator.new("My Feature").description = <<EOS
  #   All sorts of information about my feature
  #   This info is not parsed, it's just a description of the feature
  #   EOS
  attr_accessor :description

  ##
  # Generate a new feature
  #
  # = Example
  #
  #   GherkinGenerator.new("Feature name goes here")
  def initialize(feature_name)
    @feature_name = feature_name
    @scenarios = []
    @tag = ''
  end


  ##
  # Add a scenario to the feature.  The format is a single line string
  # with capital letters for the GWTA's
  #
  # = Example
  #
  #   myFeature.add_scenario("My Scenario: Given I ... When I ... And I ... Then I ...")
  #
  def add_scenario(scenario)
    examples_keyword = 'Examples '
    scenario_parts = scenario.split examples_keyword
    if scenario_parts[1] && !@ex_yield.nil?
      examples = @ex_yield.call(scenario_parts[1])
    end
    result = Scenario.new(scenario_parts[0], examples)
    @scenarios << result
    result
  end

  ##
  # Examples in Gherkin don't suite the one-line input well.  This
  #
  # = Example
  #
  #   myFeature.exampleHandler do |reference|
  #     puts "looking up examples with ref: #{reference}"
  #     <<EOS
  #   | something | another |
  #   | abc       | def     |
  #   | def       | ghi     |
  #   EOS
  #   end
  #   myFeature.add_scenario("My Scenario With" +
  #     " Examples: Given I ... Then I ... Examples http://example.org/example1")
  #
  def example_handler(&block)
    @ex_yield = block
  end

  ##
  # Output the Gherkin formatted string, this can be saved in a Feature file.
  #
  # = Example
  #
  #   gg = GherkinGenerator.new("My Feature")
  #   gg.add_scenario("Something: When I do something Then something should have happened")
  #   gg.add_scenario("Something Else: When I do something else Then something else should have happened")
  #   puts gg.to_gherkin
  #
  def to_gherkin
    feature = 'Feature: ' + @feature_name
    desc = @description.nil? ? '' : "\n\t" + @description.sub("\n", "\n\t")
    scenarios = ''

    @scenarios.each do |item|
      scenarios << item.format_string
    end

    feature + desc + scenarios + "\n"
  end

  ##
  # Object oriented representation of scenarios.  This is designed for internal use by GherkinGenerator.
  class Scenario
    ##
    # Takes a single-line scenario and a formatted example table
    def initialize(scenario, examples)
      @scenario = scenario
      @tag = []
      @examples = if examples.nil?
                    ''
                  else
                    "\n\tExamples:\n\t\t" + examples.strip.gsub("\n", "\n\t\t")
                  end
    end

    ##
    # Adding a tag - the formatting is applied, you just supply the tag name
    def add_tag(tag)
      @tag << '@' + tag
    end

    ##
    # The output of the current scenario, a feature file is made up of a description
    # and multiple scenarios formatted as a string.
    def format_string
      keywords = %w(Given And When Then)
      steps = @scenario.split(':')[1].strip
      keywords.map do |word|
        steps = steps.split(" #{word}").join("\n\t\t#{word}")
      end
      scenario = @scenario.split(':')[0]
      tag = @tag.empty? ? '' : (@tag.join(' ') + "\n\t")
      type = @examples.empty? ? 'Scenario' : 'Scenario Outline'
      "\n\n\t" + tag + type + ': ' + scenario + "\n\t\t" + steps + @examples
    end
  end
end
