# Some utilities to work with functions defined by blocks or lambdas, and defining parameter values with
# hashes without the need to redundantly define the names of the parameters.
# Currently works only with Ruby >= 1.9.2 (it uses Proc#parameters).
# 
# Examples:
#   f = Function.with_named_parameters(){|x,y,z| puts "x=#{x} y=#{y} z=#{z}"}
#   f[x:100, y:200, z:300] # => "x=100 y=200 z=300"
#   f = Function.bind(:x=>1000,:z=>2000){|x,y,z| puts "x=#{x} y=#{y} z=#{z}"}
#   f[5000] # => "x=1000 y=5000 z=2000"
#   f[6000] # => "x=1000 y=6000 z=2000"
# Or, with Function[] syntax:
#   f = lambda{|x,y,z| puts "x=#{x} y=#{y} z=#{z}"}
#   Function[f][x:100, y:200, z:300] # => "x=100 y=200 z=300"
#   f = Function[f, :x=>1000, :z=>2000]
#   f[5000] # => "x=1000 y=5000 z=2000"
#   f[6000] # => "x=1000 y=6000 z=2000"
#
module Flt::Solver::Function

  # Names of the parameters of a functor (block, Proc, etc.) (including optional and 'rest' parameters)
  #   Function.parameters(lambda{|a,b,c|...}) => [:a, :b, :c]
  #   Function.parameters{|a,b,c|...} => [:a, :b, :c]
  # Note that a block access through a &block variable is converted with Proc.new and this makes
  # all arguments optional (or :rest). On the other hand if a lambda is passed as a block it retains the
  # :req/:opt/attributes of its arguments.
  def self.parameters(fun=nil, &blk)
    fun = get(:parameters, fun, blk)  
    fun.parameters.select{|p,cls| cls!=:rest}.map{|p| p.last} # requires Ruby >= 1.9.2
  end
  
  # Returns a function by binding some of the arguments of a functor to values passed in a hash 
  #   Function.bind(f=lambda{|a,b,c|...}, :a=>1,:c=>2) => lambda{|x| f[1,x,2]}
  #   Function.bind(:a=>1, :c=>2){|a,b,c|...}          => lambda{|x| f[1,x,2]}
  def self.bind(*args, &blk)
    fun = args.shift unless args.first.kind_of?(Hash)
    params = args.shift || {}
    fun = get(:bind, fun, blk)
    fun_parameters = parameters(fun)
    fun_args = fun_parameters - params.keys
    lambda do |*args|
      fun[*params.merge(Hash[fun_args.zip(args)]).values_at(*fun_parameters)]
    end
  end

  # Returns a function that takes parameters from a hash
  #   Function.with_named_parameters(f=lambda{|a,b,c|...}) =>  lambda{|params| f[params[:a], params[:b], params[:c]]}
  #   Function.with_named_parameters{|a,b,c|...} =>  lambda{|params| f[params[:a], params[:b], params[:c]]}
  def self.with_named_parameters(*args, &blk)    
    fun = args.shift unless args.first.kind_of?(Hash)
    fun = get(:with_named_parameters, fun, blk)
    lambda do |parameters|
      fun[*parameters.values_at(*parameters(fun))]
    end
  end
  
  # Shortcut for Function.bind or Function.with_named_parameters
  #   Function[f=lambda{|a,b,c|...}, :a=>1,:c=>2] => lambda{|x| f[1,x,2]}
  #   Function[:a=>1, :c=>2, &lambda{|a,b,c|...}]          => lambda{|x| f[1,x,2]}
  #   Function[f=lambda{|a,b,c|...}] =>  lambda{|params| f[params[:a], params[:b], params[:c]]}
  #   Function[&lambda{|a,b,c|...}]         =>  lambda{|params| f[params[:a], params[:b], params[:c]]}
  # Note that this syntax is not admitted by Ruby:
  #   Function[:a=>1, :c=>2]{|a,b,c|...}
  #   Function[]{|a,b,c|...}
  def self.[](*args, &blk)
    fun = args.shift unless args.first.kind_of?(Hash)
    parameters = args.shift
    if parameters.nil?
      with_named_parameters(fun, &blk)
    else
      bind(fun, parameters, &blk)
    end
  end

  # # alternative implementation
  # def self.bind(fun, parameters, &blk)
  #   fun = get(:bind, fun, blk)
  #   fun_parameters = parameters(fun)
  #   fun_args = (fun_parameters - parameters.keys).map{|arg| fun_parameters.index(arg)}
  #   parameters = fun_parameters.map{|p| parameters[p]}
  #   lambda do |*args|
  #     fun_args.each_with_index do |arg_pos, i|
  #       parameters[arg_pos] = args[i]
  #     end
  #     fun[*parameters]
  #   end
  # end


  class <<self
    private
      def get(mth, fun, blk)
        raise "Must pass either a proc/lambda or a block to #{mth}" unless fun || blk
        raise "Must pass only one of a proc/lambda or a block to #{mth}" if fun && blk
        fun || blk
      end
   end

end

