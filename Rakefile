# frozen_string_literal: true

require "rake/testtask"

desc "Jalankan seluruh test suite"
Rake::TestTask.new(:test) do |task|
  task.libs << "test"
  task.libs << "lib"
  task.test_files = FileList["test/**/*_test.rb"]
end

desc "Jalankan test suite (default)"
task default: :test
