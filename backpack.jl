function get_data(filename="data_set.txt")
    data_input = readlines(filename)
    split_data = split.(data_input, ',')
    data_matrix = reduce(vcat, permutedims.(split_data))
    names = data_matrix[:, 1]
    values = parse.(Float64, data_matrix[:, 2])
    weights = parse.(Float64, data_matrix[:, 3])
    return names, values, weights
end
function create_initial_population(population_size, num_items)
    return rand(0:1, population_size, num_items)
end
function calculate_fitness(population, values, weights, max_capacity)
    population_size = size(population, 1)
    fitness_scores = zeros(population_size)
    for i in 1:population_size
        chromosome = population[i, :]
        total_weight = sum(chromosome .* weights)
        total_value = sum(chromosome .* values)
        if total_weight > max_capacity
            fitness_scores[i] = 0.0
        else
            fitness_scores[i] = total_value
        end
    end
    return fitness_scores
end
function selection(population, fitness_scores)
    ranked_indices = sortperm(fitness_scores, rev=true)
    ranked_population = population[ranked_indices, :]
    best_fitness = fitness_scores[ranked_indices[1]]
    return ranked_population, best_fitness
end
function crossover(ranked_population, population_size, num_items)
    num_elites = population_size ÷ 2
    top_elites = ranked_population[1:num_elites, :]
    num_offspring = population_size - num_elites
    offspring = zeros(Int, num_offspring, num_items)
    for i in 1:num_offspring
        parent1 = top_elites[rand(1:num_elites), :]
        parent2 = top_elites[rand(1:num_elites), :]
        crossover_point = rand(1:num_items-1) 
        offspring[i, :] = [parent1[1:crossover_point]; parent2[crossover_point+1:end]]
    end
    return vcat(top_elites, offspring)
end
function mutation(population, mutation_rate)
    mutated_population = copy(population)
    population_size, num_items = size(population)
    for i in 2:population_size 
        for j in 1:num_items
            if rand() < mutation_rate
                mutated_population[i, j] = 1 - mutated_population[i, j]
            end
        end
    end
    return mutated_population
end
const MAX_CAPACITY = 150.0
const POPULATION_SIZE = 100
const MAX_GENERATIONS = 200
const MUTATION_RATE = 0.01 
function genetic_backpack()
    local names, values, weights
    try
        names, values, weights = get_data("data_set.txt")
    catch e
        println("Error reading 'data_set.txt'. Does the file exist?")
        println("Error message: $e")
        return
    end
    num_items = length(names)
    println("Starting genetic algorithm...")
    println("Number of items: $num_items, Max capacity: $MAX_CAPACITY kg")
    println("Population size: $POPULATION_SIZE, Generations: $MAX_GENERATIONS")
    population = create_initial_population(POPULATION_SIZE, num_items)
    best_fitness_overall = 0.0
    best_chromosome_overall = zeros(Int, num_items)
    for generation in 1:MAX_GENERATIONS
        fitness_scores = calculate_fitness(population, values, weights, MAX_CAPACITY)
        ranked_population, current_best_fitness = selection(population, fitness_scores)
        if current_best_fitness > best_fitness_overall
            best_fitness_overall = current_best_fitness
            best_chromosome_overall = ranked_population[1, :]
        end
        if generation % 20 == 0 || generation == 1
            println("Generation: $generation, Current best: $current_best_fitness, Overall best: $best_fitness_overall")
        end
        new_generation = crossover(ranked_population, POPULATION_SIZE, num_items)
        population = mutation(new_generation, MUTATION_RATE)
    end
    println("\n" * "-"^30)
    println("Algorithm finished.")
    println("Best value found: $best_fitness_overall")
    println("\nItems in the backpack:")
    total_weight_check = 0.0
    for i in 1:num_items
        if best_chromosome_overall[i] == 1
            println(" - $(names[i]) (Value: $(values[i]), Weight: $(weights[i]))")
            total_weight_check += weights[i]
        end
    end
    println("\nTotal (Value: $best_fitness_overall, Weight: $total_weight_check / $MAX_CAPACITY kg)")
end
genetic_backpack()