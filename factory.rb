class Factory
  include Enumerable

  def self.new(*key_args, keyword_init: false, &block)
    if key_args.empty?
      raise ArgumentError,
      "wrong number of arguments (given #{args.size}, expected 1+)"
    end
    if key_args[0].is_a?(String)
      unless key_args.first[0] == key_args.first[0].upcase
        raise NameError, "identifier #{key_args.first} needs to be constant"
      end
      @name = key_args.shift
      # @@params = args
    end
      
    subclass = Class.new(self) do 
      class << self
        define_method :new do |*args|
          instance = allocate
          instance.send(:initialize, *args)
          instance
        end
      end

      define_method :initialize do |*args|
        if args.size > key_args.size
          raise ArgumentError, 'factory size differs'
        end
        @table = key_args.map(&:to_sym).zip(args).to_h
      end
    end
    @name ? Factory.const_set(@name, subclass) : subclass
  end

  def each(&block)
    if block_given?
      @table.values.each(&block)
    else
      to_enum
    end
  end

  def to_h
    @table
  end

  def values
    @table.values
  end
  alias_method :to_a, :values

  def size
    @table.size
  end
  alias_method :length, :size

  def members
    @table.keys
  end

  def values_at(*select)
    @table.values.values_at(*select)
  end

  def dig(*keys)
    @table.dig(*keys)
  end
end

try = Factory.new(:name, :age)
puts try.class
puts Factory.new("Name", :name, :age, :size)
puts Struct.new("Name", :name, :age, :size)
puts
puts Factory::Name.new("Vvv", 12, 3).values
puts
puts Struct::Name.new("Vvv", 12, 3).values

# Struct.new('new', :ds)
puts
puts (Struct.instance_methods(false) - Factory.instance_methods(false)).size
puts (Struct.instance_methods(false) - Factory.instance_methods(false)).inspect

puts f.dig(:a, :a, :b, 0)    # => 1
puts f.dig(:b, 0)            # => nil