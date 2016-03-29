# for method chaining (ex: Rails.config.hoge.fuga)
class MockedString < BasicObject
  attr_reader :to_s

  def initialize(str)
    @to_s = str.to_s.freeze
  end

  def method_missing(name, *_)
    ::MockedString.new(to_s + ".#{name}")
  end
end

class MockedBinding
  # usually we have ENV already
  class MockedEnv
    def self.[](key)
      "ENV['#{key}']"
    end
  end
  ENV = MockedEnv

  BINDING_PREFIX = self.to_s << '::'

  # called if we write: Rails.root # const_name = :Rails
  def self.const_missing(const_name)
    the_class = Class.new do |_klass|
      define_singleton_method(:method_missing) { |meth|     # def self.root
        name  = "#{self}.#{meth}"                           #   name = "MockedBinding::Rails.root"
        MockedString.new(name.sub(BINDING_PREFIX, ''))      #   MockedString.new("Rails.root")
      }                                                     # end
    end
    const_set(const_name, the_class)
  end

  def self.load_with_mock(path)
    YAML::load(ERB.new(File.read(path)).result(binding))
  end
end

if $0 == __FILE__
  class MockedBinding
    raise 'broken' unless Rails.root.to_s == 'Rails.root'
    raise 'broken' unless Rails.config.hoge.fuga.to_s == 'Rails.config.hoge.fuga'
    raise 'broken' unless ENV['foobar'].to_s == "ENV['foobar']"
  end
  puts 'self test OK.'
end
