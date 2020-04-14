# Importing packages

struct SudokuState
    puzzle::Array
    energy::Number
    T::Number
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

function get_state(puzzle, indices, T=-1.0)
    energy = get_energy(puzzle, indices)

    return SudokuState(puzzle, energy, T)
  
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

function run_mc(state, indices, temp::Real, nsteps::Int)
    count = 0
    missed_moves = 0
    for i in 1:nsteps

        puzzle = random_block_swap(state.puzzle, indices)
        new_state = get_state(puzzle, indices, temp)

        energy_diff = new_state.energy - state.energy

        if MathConstants.e^(-energy_diff/temp) > rand() || energy_diff <= 0 
            state = new_state
        end
        if state.energy==0
            break
        end
        
    end
    return state
end

