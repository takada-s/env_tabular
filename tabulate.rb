#!ruby
require 'yaml'
require 'erb'
require 'optparse'

require 'active_support'
require 'active_support/core_ext'
require_relative './mocker'
require_relative './hash_walker'

Version = '0.0.1'

options = Hash.new
opt     = OptionParser.new

opt.on('-i IGNORE_LIST', '--ignore=IGNORE_LIST') { |v|
  options[:ignore] = v.split(',').map(&:chomp) rescue nil
}
opt.on('-o filename', '--output=filename') { |v|
  options[:out] = v.chomp
}
opt.parse!(ARGV)
options[:ignore] ||= ['defaults']
options[:out]    ||= '/dev/stdout'

yaml_file = ARGV[0]
if yaml_file.nil? or yaml_file.empty?
  STDERR.puts "Usage: #{$0} path/to/settings.yml"
  exit 1
end

yaml = MockedBinding.load_with_mock(yaml_file)

envs   = yaml.keys - options[:ignore]
walker = HashWalker.new('./env_diff.erb', yaml_file)
envs.each do |env|
  walker.register(yaml[env], env)
end

File.open(options[:out], 'w') do |fp|
  fp.puts walker.to_html
end
