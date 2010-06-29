require 'helper'
require 'flt/float'
require 'flt/tolerance'

include Flt

class TestSecant < Test::Unit::TestCase
  
  context "The Secant Solver" do
  
    context "using Float arithmetic" do
      
      setup do
        @context = Float.context
        @tolerance = Flt.Tolerance(3,:decimals)
        @delta = 5E-4
      end
  
      should "solve equations" do
        solver = Flt::Solver::SecantSolver.new(@context, [0.0, 100.0], @tolerance) do |x|
          2*x+11.0
        end
        assert_in_delta -5.5, solver.root, @delta
        assert_in_delta -5.5, solver.root(5.0), @delta
        assert_in_delta -5.5, solver.root(6.0), @delta
  
        solver = Flt::Solver::SecantSolver.new(@context, [0.0, 10.0], @tolerance) do |x|
          y = 2
          y*exp(x)-10
        end
        assert_in_delta 1.6094389956808506, solver.root, @delta
        assert_in_delta 1.6094389956808506, solver.root(1.0), @delta
        assert_in_delta 1.6094389956808506, solver.root(2.0), @delta
      end
    end

    context "using DecNum arithmetic" do
      
      setup do
        @context = Flt::DecNum.context(:precision=>12)
        @tolerance = Flt.Tolerance(5,:decimals)
        @delta = @tolerance.value
      end
  
      should "solve equations" do
        solver = Flt::Solver::SecantSolver.new(@context, [0, 100].map{|v| @context.Num(v)}, @tolerance) do |x|
          2*x+11
        end
        assert_in_delta @context.Num('-5.5'), solver.root, @delta
        assert_in_delta @context.Num('-5.5'), solver.root(5), @delta
        assert_in_delta @context.Num('-5.5'), solver.root(6), @delta
  
        solver = Flt::Solver::SecantSolver.new(@context, [0, 10].map{|v| @context.Num(v)}, @tolerance) do |x|
          y = 2
          y*exp(x)-10
        end
        assert_in_delta @context.Num('1.6094389956808506'), solver.root, @delta
        assert_in_delta @context.Num('1.6094389956808506'), solver.root(1), @delta
        assert_in_delta @context.Num('1.6094389956808506'), solver.root(2), @delta
      end
      
    end
    
  end
  
end
