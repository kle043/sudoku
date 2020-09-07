using Sudoku
using JSON
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "puzzle"
            help = "A sudoku puzzle as a json string with lists in list"
            required = true
    end

    return parse_args(s)
end

function main()
    #golden nugget
    parsed_args = parse_commandline()

    json_vector = JSON.parse(parsed_args["puzzle"])
    
    puzzle = zeros(Int8, 9, 9)
    for i in 1:9
        for j in 1:9
            puzzle[i, j] = json_vector[j][i]
        end
    end
    
    println("Solving:")
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

# julia src/Main.jl [[0,0,0,0,0,1,0,0,4],[0,0,0,0,7,0,0,2,0],[0,0,3,8,0,0,9,0,0],[0,0,0,0,0,4,0,0,7],[0,1,0,0,2,0,0,0,0],[0,0,5,9,0,0,8,0,0],[0,0,8,0,0,0,0,6,0],[3,0,0,0,0,0,5,0,0],[9,5,0,6,0,0,0,0,0]]