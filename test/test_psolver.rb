require 'helper'
require 'flt/float'
require 'flt/tolerance'

include Flt

class TestPSolver < MiniTest::Unit::TestCase

  context "The PSolver class" do

    context "using Float arithmetic" do

      setup do
        @context = Float.context
        @tolerance = Flt.Tolerance(3,:decimals)
        @delta = 5E-4
      end

      context "with a TVM-equation definition" do

        setup do
          @context.class.class_eval do
            define_method :lnp1 do |x|
              v = x + 1
              (v == 1) ? x : (x*ln(v) / (v - 1))
            end
          end
          @tvm = Flt::Solver::PSolver.new(@context, @tolerance) do |m, t, m0, pmt, i, p|
            i /= 100
            i /= p
            n = -t
            k = exp(lnp1(i)*n) # (i+1)**n
            # Equation: -m*k = m0 + pmt*(1-k)/i
            m0 + pmt*(Num(1)-k)/i + m*k
          end
          @tvm.default_guesses = 1,2
        end

        should "solve for :pmt correctly" do
          solution = @tvm.root :pmt, :t=>240, :m0=>10000, :m=>0, :i=>3, :p=>12 #, :pmt=>[1,2]
          assert_in_delta @context.Num('-55.45975978539105'), solution, @delta
        end

        should "solve for :t correctly" do
          solution = @tvm.root :t, :pmt=>@context.Num('-55.45975978539105'), :m0=>10000, :m=>0, :i=>3, :p=>12 #, :pmt=>[1,2]
          assert_in_delta 240, solution, @delta
        end

      end

    end

  end

end
