using Distributed
@everywhere include_string(Main, $(read("sudoku.jl", String)), "sudoku.jl")

function distributed_run(states, indices, temp, random_ramp_temperature)
    max_energy = Inf
    nsteps = random_ramp_temperature
    while max_energy > 0
        futures = []
        for state in states
            temp = rand()*rand(1:4)
            push!(futures, @spawn run_mc(state, indices, temp, random_ramp_temperature))
        end

        states = [fetch(f) for f in futures]
        max_energy = minimum([s.energy for s in states])
        println("Max energy $max_energy")

    end

    return states
    
end


function mc_solve(puzzle::Matrix, temp::Real, random_ramp_temperature::Int)
    indices = get_indices(puzzle)
    states = []
    println("Using $(nworkers()) workers")

    for i in 1:nworkers()
        push!(states, initialize_board(puzzle, indices)) 
    end
    states = distributed_run(states, indices, temp, random_ramp_temperature)

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

@time states = mc_solve(puzzle, 0.45, 10000)

println(states[end])