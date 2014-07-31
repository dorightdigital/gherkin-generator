require './lib/gherkin_generator'

exibitA = <<EOS
| Something | Something Else |
| Abc       | Def            |
| Def       | Ghi            |
EOS

exibitB = <<EOS
| numeral | number |
| I       | 1      |
| IV      | 4      |
| XII     | 12     |
| XIX     | 19     |
EOS

gg = GherkinGenerator.new("My Feature")
gg.description = "Demonstrating examples"
gg.example_handler do |ref|
  case ref
    when 'exibit A'
      exibitA
    when 'Roman Numerals'
      exibitB
  end
end

gg.add_scenario("Something: When I do <something> Then <something> should have happened And <something else> Examples exibit A")
gg.add_scenario("Something Else: Given the roman numeral <numeral> When I convert to integer Then the output should be <number> Examples Roman Numerals")
puts gg.to_gherkin
