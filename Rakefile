# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'rake/testtask'

Rails.application.load_tasks

Rake::TestTask.new do |t|
  t.test_files =  FileList['test/*_test.rb']
  t.warning = true
end

task :default => :test
