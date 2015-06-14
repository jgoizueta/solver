module Flt::Solver

  # Regula-Falsi/Secant method solver
  # Secant is used if no bracketing is available
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
  class RFSecantSolver < Base

    def initialize(context, default_guesses, tol, eqn=nil, &blk)
      super context, default_guesses, tol, eqn, &blk
      @half = num(Rational(1,2))
      reset
    end

    def reset
      super
      @a = @b = @fa = @fb = nil
      @bracketing = false
    end

    def step
      return @guess[1] if @iteration == 0
      regula_falsi = false
      dy = @fx - @l_fx

      if @tol.zero?(dy)
        if @bracketing
          regula_falsi = true
        else
          @ok = false
          return @x
        end
      end

      if !regula_falsi
        next_x = @x - ((@x - @l_x)*@fx)/dy
        regula_falsi = true if @bracketing && (next_x < @a || next_x > @b)
      end
      next_x = @b - (@b - @a)*@fb/(@fb - @fa) if regula_falsi
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
      # puts "br: #{@bracketing} r-f: #{regula_falsi} x:#{@x}[#{@fx}] l_x:#{@l_x}[#{@l_fx}] #{next_x}"
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

  end  # RFSecantSolver

end # Flt::Solver
