# -*- Ruby -*-
require "bundler/gem_tasks"
require "rake/testtask.rb"

desc "Start website"
task :start do
  source = ENV["SRC"] || ENV["SOURCE"] || "sample"
  ruby "-Ilib bin/jewfish start #{source}"
end

namespace "test" do
  Rake::TestTask.new do |t|
    t.name = "units"
    t.pattern = "test/unit/test_*.rb"
  end
end

desc "Run all tests"
task test: ["test:units"]
