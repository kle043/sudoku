module Sudoku
using Distributed
@everywhere include_string(Main, $(read("src/Utils.jl", String)), "Utils.jl")

function distributed_run(states, indices, nsteps)
    min_state = states[1]
    tot_steps = 0
    while min_state.energy > 0
        futures = []
        for state in states
            temp = rand()*rand(1:4)
            push!(futures, @spawn run_mc(state, indices, temp, nsteps))
            tot_steps += nsteps
        end

        states = [fetch(f) for f in futures]
        min_state = states[argmin([s.energy for s in states])]
        if tot_steps % 10000 == 0
            println("Min energy = $(min_state.energy)")
            println("Temp = $(min_state.T)")
        end

    end

    return states[argmin([s.energy for s in states])]
    
end


function mc_solve(puzzle::Matrix, nsteps::Int)
    indices = get_indices(puzzle)
    states = []
    println("Using $(nworkers()) workers")

    for i in 1:nworkers()
        push!(states, initialize_board(puzzle, indices)) 
    end
    states = distributed_run(states, indices, nsteps)

    return states
    
end

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
    display(puzzle)
    println("")
    
    @time solution = mc_solve(puzzle, 1000)
    
    println("Initial board:")
    display(puzzle)
    println("")
    println("Solution, energy=$(solution.energy)")
    display(solution.puzzle)
    println("")
end

end #module

if !isinteractive()
    Sudoku.main()
end
