using Sudoku

function main()
    #golden nugget
    puzzle = [0 0 0 0 0 0 0 3 9;
              0 0 0 0 1 0 0 0 5;
              0 0 3 0 0 5 8 0 0;
              0 0 8 0 0 9 0 0 6;
              0 7 0 0 2 0 0 0 0;
              1 0 0 4 0 0 0 0 0;
              0 0 9 0 0 8 0 5 0;
              0 2 0 0 0 0 6 0 0;
              4 0 0 7 0 0 0 0 0;]
    
    println("Solving:")
    println("Golden Nugget")
    display(puzzle)
    println("")
    
    @time solution = Sudoku.mc_solve(puzzle, 1500)
    
    println("Initial board:")
    display(puzzle)
    println("")
    println("Solution, energy=$(solution.energy)")
    display(solution.puzzle)
    println("")
end

main()