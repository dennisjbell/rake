module Rake

  ####################################################################
  # TaskArguments manage the arguments passed to a task.
  #
  class TaskArguments
    include Enumerable

    attr_reader :names

    # Create a TaskArgument object with a list of named arguments
    # (given by :names) and a set of associated values (given by
    # :values).  :parent is the parent argument object.
    def initialize(names, values, parent=nil)
      @names = names
      @parent = parent
      @hash = {}
      @values = values
      names.each_with_index { |name, i|
        @hash[name.to_sym] = values[i] unless values[i].nil?
      }
    end

    # Retrive the complete array of sequential values
    def to_a
      @values.dup
    end

    # Retrive the list of values not associated with named arguments
    def extras
      @values[@names.length..-1] || []
    end

    # Create a new argument scope using the prerequisite argument
    # names.
    def new_scope(names)
      values = names.collect { |n| self[n] }
      self.class.new(names, values+self.extras, self)
    end

    # Find an argument value by name or index.
    def [](index)
      lookup(index.to_sym)
    end

    # Specify a hash of default values for task arguments. Use the
    # defaults only if there is no specific value for the given
    # argument.
    def with_defaults(defaults)
      @hash = defaults.merge(@hash)
    end

    def each(&block)
      @hash.each(&block)
    end

    def values_at(*keys)
      keys.map { |k| lookup(k) }
    end

    def method_missing(sym, *args)
      lookup(sym.to_sym)
    end

    def to_hash
      @hash
    end

    def to_s
      @hash.inspect
    end

    def inspect
      to_s
    end

    protected

    def lookup(name)
      if @hash.has_key?(name)
        @hash[name]
      elsif @parent
        @parent.lookup(name)
      end
    end
  end

  EMPTY_TASK_ARGS = TaskArguments.new([], [])
end
