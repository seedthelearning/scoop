Gem::Specification.new do |s|
  s.name        = 'scoop'
  s.version     = '0.0.1'
  s.date        = '2012-07-19'
  s.summary     = "Scoop"
  s.description = "Gem to connect to SeedTheLearning's Granary api"
  s.authors     = ["Jacqueline Chenault", "Austen Ito", "Jonan Scheffler", "Charles Strahan"]
  s.email       = 'jacqueline.chenault@livingsocial.com'
  s.files       = ["lib/scoop.rb"]
  s.homepage    =
    'http://github.com/seedthelearning/scoop'

  s.add_runtime_dependency 'faraday'
end