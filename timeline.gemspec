$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "timeline/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "timeline"
  s.version     = Timeline::VERSION
  s.authors     = ["Felix Clack"]
  s.email       = ["felixclack@gmail.com"]
  s.homepage    = "http://timeline.github.com"
  s.summary     = "Redis backed timeline for your activity feeds."
  s.description = ""

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "active_support"
  s.add_dependency "multi_json"
  s.add_dependency "redis"

  s.add_development_dependency "sqlite3"
end
