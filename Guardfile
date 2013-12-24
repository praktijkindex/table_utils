
guard :rspec, cmd: "bundle exec rspec", all_after_pass: true  do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch("spec/spec_helper.rb")  { "spec" }

  watch("lib/data_source.rb")   { "spec/lib/rake/table_import_spec.rb" }
end

