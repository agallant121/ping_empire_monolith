#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'

COMMIT = ARGV[0] || 'HEAD'

def run_git(*args)
  stdout, status = Open3.capture2('git', *args)
  unless status.success?
    warn "Failed to run git #{args.join(' ')}"
    exit status.exitstatus || 1
  end
  stdout
end

files_output = run_git('diff-tree', '--no-commit-id', '--name-only', '-r', COMMIT)
files = files_output.split("\n").reject(&:empty?)

if files.empty?
  puts "No files changed in #{COMMIT}."
  exit 0
end

files.each_with_index do |file, index|
  puts "=" * 80
  puts "#{index + 1}. #{file} (@#{COMMIT})"
  puts "=" * 80
  content = run_git('show', "#{COMMIT}:#{file}")
  puts content
end
