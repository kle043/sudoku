# Importing packages


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

function run(states, indices, temp, random_ramp_temperature)
    state = states[end]
    count = 0
    missed_moves = 0
    while (state.energy>0)
        count += 1

        if count%100000==0
            println("Energy: $(state.energy)")
            println("Temperature: $temp")
            println("Move nr: $count")
            println("Missed nr: $missed_moves")
            push!(states, state)
        end
        puzzle = random_block_swap(state.puzzle, indices)
        new_state = get_state(puzzle, indices)

        energy_diff = new_state.energy - state.energy

        if MathConstants.e^(-energy_diff/temp) > rand() || energy_diff <= 0 
            state = new_state
            #println("Energy: $(state.energy)")
        else
            missed_moves += 1
            if missed_moves%random_ramp_temperature == 0
                temp = rand()*rand(1:4)
            end
        end
        
    end
    push!(states, state)
    println("Energy: $(state.energy)")
    println("Finished on move nr: $count")
    return state
end

function mc_solve(puzzle::Matrix, temp::Real, random_ramp_temperature::Int)
    states = []
    indices = get_indices(puzzle)
    push!(states, get_state(puzzle, indices))
    push!(states, initialize_board(puzzle, indices))
    state = run(states, indices, temp, random_ramp_temperature)

    return states
    
end

#puzzle = [0  0  0  0  0  0  0  9  3;
#          0  0  0  5  0  0  0  0  7;
#          0  0  8  0  7  2  0  0  5;
#          0  0  0  8  3  0  0  7  0;
#          0  0  5  0  0  0  6  0  0;
#          0  2  0  0  4  7  0  0  0;
#          8  0  0  2  9  0  1  0  0;
#          1  0  0  0  0  8  0  0  0;
#          2  4  0  0  0  0  0  0  0;]
#
#states = mc_solve(puzzle, 0.45)
#
#println(states[end])


#[5 7 2 1 6 4 8 9 3;
# 3 1 4 5 8 9 2 6 7;
# 6 9 8 3 7 2 4 1 5;
# 4 6 1 8 3 5 9 7 2;
# 7 8 5 9 2 1 6 3 4;
# 9 2 3 6 4 7 5 8 1;
# 8 5 7 2 9 3 1 4 6;
# 1 3 6 4 5 8 7 2 9;
# 2 4 9 7 1 6 3 5 8]
