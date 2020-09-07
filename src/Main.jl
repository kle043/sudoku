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

    puzzle = JSON.parse(parsed_args["puzzle"])
    println("Solving:")
    display(puzzle)
    #println("")
    #print(JSON.json(puzzle))
    ##@time solution = Sudoku.mc_solve(puzzle, 1500)
    #
    #println("Initial board:")
    #display(puzzle)
    #println("")
    #println("Solution, energy=$(solution.energy)")
    #display(solution.puzzle)
    #println("")
end

main()