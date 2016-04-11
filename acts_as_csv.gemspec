Gem::Specification.new do |s|
  s.name        = 'acts_as_csv'
  s.version     = '1.0.0'
  s.date        = '2016-02-02'
  s.summary     = "Extends default CSV behavior to ActiveRecord models"
  s.description = "Extends default CSV behavior to ActiveRecord models"
  s.authors     = ["Jordan Graft"]
  s.email       = 'jordan@cratebind.com'
  s.files       = ["lib/acts_as_csv.rb"]
  s.license       = 'MIT'

  s.add_development_dependency 'activerecord'
  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"
  s.add_development_dependency "rake"
  s.add_development_dependency "simplecov"
end