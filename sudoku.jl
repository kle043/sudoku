using Distributed
@everywhere include_string(Main, $(read("utils.jl", String)), "utils.jl")

function distributed_run(states, indices, temp, nsteps)
    min_state = states[1]
    nsteps = nsteps
    while min_state.energy > 0
        futures = []
        for state in states
            temp = rand()*rand(1:4)
            push!(futures, @spawn run_mc(state, indices, temp, nsteps))
        end

        states = [fetch(f) for f in futures]
        min_state = states[argmin([s.energy for s in states])]
        println("Max energy $(min_state.energy)")

    end

    return states[argmin([s.energy for s in states])]
    
end


function mc_solve(puzzle::Matrix, temp::Real, nsteps::Int)
    indices = get_indices(puzzle)
    states = []
    println("Using $(nworkers()) workers")

    for i in 1:nworkers()
        push!(states, initialize_board(puzzle, indices)) 
    end
    states = distributed_run(states, indices, temp, nsteps)

    return states
    
end

puzzle = [0  0  0  0  0  0  0  9  3;
          0  0  0  5  0  0  0  0  7;
          0  0  8  0  7  2  0  0  5;
          0  0  0  8  3  0  0  7  0;
          0  0  5  0  0  0  6  0  0;
          0  2  0  0  4  7  0  0  0;
          8  0  0  2  9  0  1  0  0;
          1  0  0  0  0  8  0  0  0;
          2  4  0  0  0  0  0  0  0;]

println("Solving:")
display(puzzle)
println("")

@time solution = mc_solve(puzzle, 0.45, 10000)

println("Initial board:")
display(puzzle)
println("")
println("Solution, energy=$(solution.energy)")
display(solution.puzzle)
println("")