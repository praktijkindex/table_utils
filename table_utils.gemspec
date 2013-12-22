$LOAD_PATH << File.expand_path("../lib", __FILE__)

require  "table_utils/version"

Gem::Specification.new do |s|
  s.name = "table_utils"
  s.version = TableUtils::VERSION
  s.summary = "utilities for working with real world tabular data"
  s.description = "make dealing with real life tables simpler"
  s.author = "Artem Baguinski"
  s.email = "femistofel@gmail.com"
  s.homepage = "https://github.com/artm/table_utils"
  s.license = "MIT"

  s.files = `git ls-files`.split($/)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_runtime_dependency "activerecord"
  s.add_runtime_dependency "activerecord-import"
  s.add_runtime_dependency "ruby-progressbar"

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard", "< 2.0"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "sqlite3"
end

