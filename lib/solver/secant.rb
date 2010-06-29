module Flt::Solver
  
  # Secant method solver
  # Bisect method is used is bracketing found (sign(f(a)) != sign(f(b)))
  # 
  # Example of use:
  #   require 'solver'
  #   include Flt
  #   solver = Solver::SecantSolver.new(Float.context, [0.0, 100.0], Tolerance(3, :decimals)) do |x|
  #     2*x+11.0
  #   end
  #   puts solver.root
  #   # with a guess:
  #   puts solver.root(5.0)
  #
  #   solver = SecantSolver.new(Float.context, [0.0, 10.0], Tolerance(3, :decimals)) do |x|
  #     y = 2
  #     y*exp(x)-10
  #   end
  #   puts solver.root
  #
  class SecantSolver < Base

    def initialize(context, default_guesses, tol, eqn=nil, &blk)
      super context, default_guesses, tol, eqn, &blk
      @a = @b = @fa = @fb = nil
      @bracketing = false
      @half = num(Rational(1,2))
    end

    def step
      return @guess[1] if @iteration == 0
      bisect = false
      dy = @fx - @l_fx

      if @tol.zero?(dy)
        if @bracketing
          bisect = true
        else
          @ok = false
          return @x
        end
      end

      if !bisect
        next_x = @x - ((@x - @l_x)*@fx)/dy
        bisect = true if @bracketing && (next_x < @a || next_x > @b)
      end
      next_x = (@a + @b)*@half if bisect
      next_fx = eval_f(next_x)

      if @bracketing
        if @context.sign(@fa) == @context.sign(next_fx)
          @a = next_x
          @fa = next_fx
        else
          @b = next_x
          @fb = next_fx
        end
      else
        if @context.sign(next_fx) != @context.sign(@fx)
          @a, @b = @x, next_x
          @a, @b = @b, @a if @a > @b
          @fa = eval_f(@a)
          @fb = eval_f(@b)
          @bracketing = true
        end
      end
      next_x
    end

    def validate
      @guess = @guess.uniq
      if @guess.size < 2
        return false if @guess.empty?
        @guess << (@guess.first + 1)
      end
      true
    end

  end # SecantSolver
  
end # Flt::Solver