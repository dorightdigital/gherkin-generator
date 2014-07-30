class GherkinGenerator
  attr_accessor :description

  def initialize(feature_name)
    @feature_name = feature_name
    @scenarios = []
    @tag = ''
  end

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

  def example_handler(&block)
    @ex_yield = block
  end

  def to_gherkin
    feature = 'Feature: ' + @feature_name
    desc = @description.nil? ? '' : "\n\t" + @description.sub("\n", "\n\t")
    scenarios = ''

    @scenarios.each do |item|
      scenarios << item.format_string
    end

    feature + desc + scenarios + "\n"
  end

  class Scenario
    def initialize(scenario, examples)
      @scenario = scenario
      @tag = []
      @examples = if examples.nil?
                    ''
                  else
                    "\n\tExamples:\n\t\t" + examples.strip.gsub("\n", "\n\t\t")
                  end
    end

    def add_tag(tag)
      @tag << '@' + tag
    end

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
