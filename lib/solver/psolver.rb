module Flt::Solver
  
  # Solver with equation parameters passed in a hash
  # 
  # Example: a simple TVM (Time Value of Money) solver
  #
  #   # ln(x+1)
  #   def lnp1(x)
  #     v = x + 1
  #     (v == 1) ? x : (x*ln(v) / (v - 1))
  #   end
  # 
  #   tvm = Flt::Solver::PSolver.new(Float.context, Flt.Tolerance(3,:decimals)) do |m, t, m0, pmt, i, p|
  #     i /= 100
  #     i /= p
  #     n = -t
  #     k = exp(lnp1(i)*n) # (i+1)**n
  #     # Equation: -m*k = m0 + pmt*(1-k)/i
  #     m0 + pmt*(Num(1)-k)/i + m*k
  #   end
  #   tvm.default_guesses = 1,2
  #   sol = tvm.root :pmt, :t=>240, :m0=>10000, :m=>0, :i=>3, :p=>12 #, :pmt=>[1,2]
  #   puts sol.inspect # => -55.45975978539105
  #
  class PSolver
    
    def initialize(context, tol, solver_class=nil, &blk)

      @solver_class = solver_class || RFSecantSolver
      @eqn = blk
      @vars = Function.parameters(@eqn)
      # alternatively, we could keep @eqn = Function[@eqn] and dispense with @vars

      @default_guesses = nil

      @context = context
      @tol = tol
      @solver = nil

    end

    def default_guesses=(*g)
      @default_guesses = g
      @solver = nil
    end

    def root(var, parameters)
      init_solver
      @var = var
      @parameters = parameters
      guesses = Array(parameters[var])
      @solver.root *guesses
    end

    def equation_value(v)
      values = @parameters.merge(@var=>v)
      #@context.math(*values.values_at(*@vars).map{|v| @context.Num(v)}, &@eqn)
      @context.math(*@vars.map{|v| @context.Num(values[v])}, &@eqn)
      # equivalent to: @context.math(values, &Function[@eqn]) # which doesn't need @vars
    end

    private
    def init_solver
      this = self
      @solver ||= @solver_class.new(@context, @default_guesses, @tol){|v| this.equation_value(v)}
    end

  end

end # Flt::PSolver