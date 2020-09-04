module Sudoku
using Distributed
include("./Utils.jl")
@everywhere include("src/Utils.jl")

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

end #module
