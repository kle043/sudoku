# Importing packages
using Distributed


struct SudokuState
    puzzle::Array
    energy::Number
end

struct Indices
    blocks::Array
    columns::Array
    rows::Array
    free_cells_pr_block::Dict
    fixed_numbers_pr_block::Dict
end

function  get_indices(puzzle)
    blocks = []
    columns = []
    rows = []
    free_cells_pr_block = Dict()
    fixed_numbers_pr_block = Dict()
    counter = 0
    for i in 1:3:7
        for j in 1:3:7
            counter += 1
            push!(rows, (counter, 1:9))
            push!(columns, (1:9, counter))
            push!(blocks, (i:i+2, j:j+2))
 
            free_block = []
            fixed_numbers = []
            for k in i:i+2
                for l in j:j+2
                    if puzzle[k, l]==0
                        push!(free_block, (k, l))
                    else
                        push!(fixed_numbers, puzzle[k, l])
                    end
                end      
            end
            free_cells_pr_block[(i:i+2, j:j+2)] = free_block
            fixed_numbers_pr_block[(i:i+2, j:j+2)] = fixed_numbers
        end
    end
    
    return Indices(blocks, columns, rows, free_cells_pr_block, fixed_numbers_pr_block)
end

function initialize_board(puzzle, indices)
    puzzle = copy(puzzle)
    for (b_i, b_j) in indices.blocks

        possible_values = [v for v in 1:9 if v ∉ indices.fixed_numbers_pr_block[(b_i,b_j)]]
    
        for (c_i, c_j) in indices.free_cells_pr_block[(b_i, b_j)]
            i = rand(1:length(possible_values))
            puzzle[c_i, c_j] = possible_values[i]
            deleteat!(possible_values, i)
        end
    end
    
    return get_state(puzzle, indices)
end

function get_energy(puzzle, indices)
    energy = sum([sum(unique(puzzle[i, j])) for (i, j) in indices.columns])
    energy += sum([sum(unique(puzzle[i, j])) for (i, j) in indices.rows])
    
    return abs(2*405 - energy)
    
end

function get_state(puzzle, indices)
    energy = get_energy(puzzle, indices)

    return SudokuState(puzzle, energy)
  
end

function random_block_swap(puzzle, indices)
    puzzle = copy(puzzle)
    (b_i, b_j) = indices.blocks[rand(1:length(indices.blocks))]
    (c_i, c_j) = rand(1:length(indices.free_cells_pr_block[(b_i, b_j)]), 2)
    (s1_i, s1_j) = indices.free_cells_pr_block[(b_i, b_j)][c_i]
    (s2_i, s2_j) = indices.free_cells_pr_block[(b_i, b_j)][c_j]
    puzzle[s1_i, s1_j], puzzle[s2_i, s2_j] = puzzle[s2_i, s2_j], puzzle[s1_i, s1_j]

    return puzzle
end

function distributed_run(states, indices, temp, random_ramp_temperature)
    max_energy = Inf
    nsteps = random_ramp_temperature
    while max_energy > 0
        futures = []
        for state in states
            temp = rand()*rand(1:4)
            push!(futures, @spawnat:any run_mc(state, indices, temp, random_ramp_temperature))
        end

        states = [fetch(f) for f in futures]
        max_energy = minimum([[s.energy for s in states]])

    end

    return states
    
end

function run_mc(state, indices, temp::Real, nsteps::Int)
    count = 0
    missed_moves = 0
    for i in 1:nsteps

        puzzle = random_block_swap(state.puzzle, indices)
        new_state = get_state(puzzle, indices)

        energy_diff = new_state.energy - state.energy

        if MathConstants.e^(-energy_diff/temp) > rand() || energy_diff <= 0 
            state = new_state
            #println("Energy: $(state.energy)")
        end
        
    end
    println("Energy: $(state.energy)")
    return state
end

function mc_solve(puzzle::Matrix, temp::Real, random_ramp_temperature::Int)
    indices = get_indices(puzzle)
    states = []
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

states = mc_solve(puzzle, 0.45, 100)

println(states[end])


#[5 7 2 1 6 4 8 9 3;
# 3 1 4 5 8 9 2 6 7;
# 6 9 8 3 7 2 4 1 5;
# 4 6 1 8 3 5 9 7 2;
# 7 8 5 9 2 1 6 3 4;
# 9 2 3 6 4 7 5 8 1;
# 8 5 7 2 9 3 1 4 6;
# 1 3 6 4 5 8 7 2 9;
# 2 4 9 7 1 6 3 5 8]
