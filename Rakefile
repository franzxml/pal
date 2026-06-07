# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new(:test) do |task|
  task.libs << "test"
  task.libs << "lib"
  task.test_files = FileList["test/**/*_test.rb"]
end
Rake::Task[:test].instance_variable_set(:@comments, ["Jalankan seluruh test suite"])

desc "Jalankan test suite (default)"
task default: :test
