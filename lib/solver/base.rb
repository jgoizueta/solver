# TODO: add method to check for result: zero or sign reversal / extrema / inflection / asymptote
# TODO: automatic guesses if single guess or no guesses

# Base class for Fixed-Point Numeric Solvers
module Flt::Solver

class Base

  # Admitted options:
  #
  # * :context : Numerical context (e.g. Flt::Decimal::Context) Float by default
  # * :default_guesses : default initial guesses
  # * :tolerance : numerical tolerance
  # * :equation : equation to be solved; can also be passed as a block
  #
  # default_guesses: nil for no pre-guess, or one or two guesses (use array for two)
  #
  # The values of any of the parameters can also be passed as arguments
  # (not in the options Hash, if present) in any order, e.g.:
  #
  #   Solver::Base.new Flt::DecNum.context, tolerance: Flt::Tolerance(3, :decimals)
  #
  def initialize(*args, &blk)
    options = Base.extract_options(*args, &blk)
    @context = options[:context] || Float.context
    @default_guesses = Array(options[:default_guesses])
    @x = @default_guesses.first
    @f = options[:equation]
    @tol = options[:tolerance] # user-requested tolerance
    @max_it = 8192
    reset
  end

  def reset
    @l_x = nil
    @fx = nil
    @l_fx = nil
    @ok = true
    @conv = false
  end

  def root(*guesses)
    @guess = (guesses + @default_guesses).map{|g| num(g)}
    reset
    @l_x = @x = @guess.first
    @l_fx = @fx = eval_f(@x)
    @ok = true
    @conv = false

    # Minimum tolerance of the numeric type used
    @numeric_tol = Flt::Tolerance(1,:ulps) # Tolerance(@context.epsilon, :floating)

    raise "Invalid parameters" unless validate

    @reason = nil
    @iteration = 0
    # TODO: handle NaNs (stop or try to find other guess)
    while @ok && @iteration < @max_it
      next_x = step()
      @l_x = @x
      @l_fx = @fx
      @x = next_x
      @fx = eval_f(@x)
      @conv = test_conv() if @ok
      break if @conv
      @iteration += 1
    end
    @ok = false if @iteration >= @max_it # TODO: set reason
    @x

  end

  def value
    @fx
  end

  attr_reader :reason, :iteration

  protected

  def eval_f(x)
    @context.math x, &@f
  end

  def num(v)
    @context.Num(v)
  end

  def zero?
    @tol.zero?(@fx)
  end

  def test_conv
    #@tol.eq?(@x, @l_x) || @tol.eq?(@fx, @l_fx) || zero?
    # puts "test #{@x} #{@fx}"
    # if @tol.eq?(@fx, @l_fx) && !(@tol.eq?(@x, @l_x) || zero?)
    #   puts "---> v=#{@tol.relative_to_many(:max, @fx, @l_fx)} #{@fx} #{@l_fx} x=#{@x}"
    # end

    # zero? || @x==@l_x || @fx == @l_fx
    #@numeric_tol.eq?(@x, @l_x) || zero? || @numeric_tol.eq?(@fx, @l_fx)

    # TODO : use symbols for reason
    if zero?
      @reason = "Zero found #{@fx.inspect} @ #{@x.inspect}"
    elsif @numeric_tol.eq?(@x, @l_x)
      @reason = "Critical point" # Sign Reversal (@fx != @l_fx) or vertical tangent / asymptote
    elsif @numeric_tol.eq?(@fx, @l_fx)
      @reason = "Flat" # flat function
    end
    !@reason.nil?

    # TODO: try to get out of flat; if @x==@l_x try to find other point?;

    #zero?
  end

  def validate
    true
  end

  def self.extract_options(*args, &blk)
    options = {}
    args.each do |arg|
      case arg
      when Hash
        options.merge! arg
      when Flt::Num::ContextBase, Flt::FloatContext
        options.merge! context: arg
      when Array, Numeric
        options.merge! default_guesses: Array(arg)
      when Proc
        options.merge! equation: arg
      when Flt::Tolerance
        options.merge! tolerance: arg
      when Base
        options.merge! solver_class: arg
      else
        raise "Invalid Argument #{arg.inspect}"
      end
    end
    options[:equation] ||= blk
    options
  end

end # Base

end # Flt::Solve
