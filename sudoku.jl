# Importing packages
using JuMP, Gurobi, Distributions


puzzle = [0  0  0  0  0  0  0  9  3;
          0  0  0  5  0  0  0  0  7;
          0  0  8  0  7  2  0  0  5;
          0  0  0  8  3  0  0  7  0;
          0  0  5  0  0  0  6  0  0;
          0  2  0  0  4  7  0  0  0;
          8  0  0  2  9  0  1  0  0;
          1  0  0  0  0  8  0  0  0;
          2  4  0  0  0  0  0  0  0;]