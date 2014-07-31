require './lib/gherkin_generator'

gg = GherkinGenerator.new("My Feature")
gg.add_scenario("Something: When I do something Then something should have happened")
gg.add_scenario("Something Else: When I do something else Then something else should have happened")
puts gg.to_gherkin
