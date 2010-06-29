# TODO: add method to check for result: zero or sign reversal / extrema / inflection / asymptote
# TODO: automatic guesses if single guess or no guesses

# Base class for Fixed-Point Numeric Solvers
module Flt::Solver

class Base

  # default_guesses: nil for no pre-guess, or one or two guesses (use array for two)
  def initialize(context, default_guesses, tol, eqn=nil, &blk)
    @context = context
    @default_guesses = Array(default_guesses)
    @x = @default_guesses.first
    @f = eqn || blk
    @tol = tol # user-requested tolerance
    @l_x = nil
    @fx = nil
    @l_fx = nil
    @ok = true
    @conv = false
    @max_it = 8192
  end

  # value of parameters[var] is used as a guess in precedence to the pre-guesses if not nil
  # use Array for two guesses
  def root(*guesses)
    @guess = (guesses + @default_guesses).map{|g| num(g)}
    @l_x = @x = @guess.first
    @l_fx = @fx = eval_f(@x)
    @ok = true
    @conv = false

    # Minimum tolerance of the numeric type used
    @numeric_tol = Tolerance(1,:ulps) # Tolerance(@context.epsilon, :floating)

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
      # puts "X=#{@x.inspect}[#{@fx.inspect}]"
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

end # Base

end # Flt::Solve
