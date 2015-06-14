module Flt::Solver

  # A Time-Value-of-Money solver
  #
  # Example:
  #   tvm = TVM.new(Tolerance(3, :decimals), Float.context)
  #   puts tvm.solve(:t=>240, :m0=>10000, :m=>0, :i=>3, :p=>12).inspect # => {:pmt=>-55.45975978539105}
  #
  class TVM

    def initialize(tol, context=Float.context)
      @context = context
      @var_descriptions = {
        :m=>'money value at time t',
        :t=>'time',
        :m0=>'initial money value',
        :pmt=>'payment per time unit',
        :i=>'percent interest per year',
        :p=>'number of time units per year'
      }
      @vars = @var_descriptions.keys
      vars = @vars
      tvm = self
      @solver = PSolver.new(context, tol) do |m, t, m0, pmt, i, p|
        tvm.equation(m, t, m0, pmt, i, p)
      end
      @solver.default_guesses = 1,2
      @one = @context.Num(1)
    end

    def parameter_descriptions
      @var_descriptions
    end

    # Parameters:
    #  :t time in periods
    #  :p number of periods per year
    #  :i percent yearly interest rate
    #  :pmt payment per period
    #  :m0 initial value
    #  :m value at time :t
    def solve(parameters)
      nil_vars = @vars.select{|var| parameters[var].nil?}
      raise "Too many unknowns" if nil_vars.size>1
      raise "Nothing to solve" if nil_vars.empty?
      var = nil_vars.first
      # determine sensible initial value? => parameters[var] = initial_value
      {var=>@solver.root(var, parameters)}
    end

    def value(parameters)
      @solver.equation_value(paramters)
    end

    def equation(m, t, m0, pmt, i, p)
      i /= 100
      i /= p
      n = -t
      k = @context.exp(lnp1(i)*n) # (i+1)**n
      # Equation: -m*k = m0 + pmt*(1-k)/i
      m0 + pmt*(@one-k)/i + m*k
    end

    # ln(x+1)
    def lnp1(x)
      v = x + 1
      (v == 1) ? x : (x*@context.ln(v) / (v - 1))
    end

  end # TVM

end # Flt::Solver
