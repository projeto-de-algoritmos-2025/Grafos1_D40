using Graphs
using JSON
using Plots
using GraphRecipes

function load_graph(filename)
    # Read and parse the JSON file
    data = JSON.parsefile(filename)
    
    # Create a dictionary to store the adjacency list
    graph = Dict{String, Vector{String}}()
    abbr_to_id = Dict{String, String}()
    # Initialize all nodes with empty adjacency lists
    for node in data["nodes"]
        graph[node["id"]] = String[]
        abbr_to_id[node["id"]] = node["abbr"]
    end

    println(abbr_to_id)
    # Add edges to the adjacency list
    for edge in data["edges"]
        from_node = edge["from"]
        to_node = edge["to"]
        push!(graph[from_node], to_node)
    end
    println(graph)
    
    return graph, abbr_to_id
end

function create_hierarchical_visualization(data, output_file = "course_dag_hierarchical.png")
    # Create a Graphs.jl SimpleDiGraph
    n_nodes = length(data["nodes"])
    g = SimpleDiGraph(n_nodes)
    
    # Create mapping from node ID to index
    id_to_index = Dict{String, Int}()
    index_to_id = Dict{Int, String}()
    index_to_abbr = Dict{Int, String}()
    index_to_label = Dict{Int, String}()
    
    for (i, node) in enumerate(data["nodes"])
        id_to_index[node["id"]] = i
        index_to_id[i] = node["id"]
        index_to_abbr[i] = node["abbr"]
        index_to_label[i] = node["label"]
    end
    
    # Add edges to the graph
    for edge in data["edges"]
        from_idx = id_to_index[edge["from"]]
        to_idx = id_to_index[edge["to"]]
        add_edge!(g, from_idx, to_idx)
    end
    
    # Calculate hierarchical levels
    levels = zeros(Int, n_nodes)
    in_degree = zeros(Int, n_nodes)
    
    # Calculate in-degrees
    for edge in data["edges"]
        to_idx = id_to_index[edge["to"]]
        in_degree[to_idx] += 1
    end
    
    # Assign levels using topological sort
    queue = Int[]
    for i in 1:n_nodes
        if in_degree[i] == 0
            push!(queue, i)
            levels[i] = 0
        end
    end
    
    while !isempty(queue)
        current = popfirst!(queue)
        for neighbor in neighbors(g, current)
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0
                levels[neighbor] = levels[current] + 1
                push!(queue, neighbor)
            end
        end
    end
    
    # Create custom layout based on levels
    max_level = maximum(levels)
    level_groups = Dict{Int, Vector{Int}}()
    for i in 1:n_nodes
        level = levels[i]
        if !haskey(level_groups, level)
            level_groups[level] = Int[]
        end
        push!(level_groups[level], i)
    end
    
    # Position nodes hierarchically
    node_positions = Vector{Tuple{Float64, Float64}}()
    for i in 1:n_nodes
        push!(node_positions, (0.0, 0.0))
    end
    
    for (level, nodes) in level_groups
        y_pos = -level * 2.0  # Higher levels at top
        for (i, node_idx) in enumerate(nodes)
            x_pos = (i - 1) * 2.0 - (length(nodes) - 1)  # Center horizontally
            node_positions[node_idx] = (x_pos, y_pos)
        end
    end
    
    # Color nodes by level
    colors = [:lightblue, :lightgreen, :lightcoral, :lightyellow, :lightpink, :lightgray, :lightsalmon, :lightcyan, :lightsteelblue, :lightseagreen]
    node_colors = [colors[mod(levels[i], length(colors)) + 1] for i in 1:n_nodes]
    
    # Create the hierarchical plot
    p = graphplot(g, 
        names = [index_to_abbr[i] for i in 1:n_nodes],
        fontsize = 9,
        fontfamily = "Arial",
        nodesize = 0.2,
        nodecolor = node_colors,
        nodeborder = :black,
        nodebordercolor = :darkblue,
        nodeborderwidth = 2,
        edgecolor = :darkgray,
        edgelinewidth = 2,
        arrow = true,
        arrowsize = 0.4,
        arrowcolor = :darkgray,
        title = "Course Prerequisites DAG - Hierarchical Layout\n(Engineering Curriculum)",
        titlefontsize = 16,
        titlefontfamily = "Arial Bold",
        size = (1800, 1200),
        curves = false,
        background_color = :white,
        grid = false,
        showaxis = false,
        legend = false
    )
    
    # Level information is printed to console instead of on plot
    
    # Save the plot
    savefig(p, output_file)
    println("Hierarchical graph saved as $output_file")
    println("Graph has $(n_nodes) nodes and $(ne(g)) edges")
    println("Levels: $(Dict(level => length(nodes) for (level, nodes) in level_groups))")
    
    return p
end

function bfs(graph, start, abbr_to_id)
    visited = Set([start])
    queue = [start]
    
    while !isempty(queue)
        current = popfirst!(queue)
        println(abbr_to_id[current])
        
        for neighbor in graph[current]
            if neighbor ∉ visited
                push!(visited, neighbor)
                push!(queue, neighbor)
            end
        end
    end
end

# Load the data
data = JSON.parsefile("Projeto/courses.json")
graph, abbr_to_id = load_graph("Projeto/courses.json")

# Generate the DAG visualizations
println("\nGenerating hierarchical DAG visualization...")
create_hierarchical_visualization(data, "Projeto/course_dag_hierarchical2.png")

# Run BFS
println("\nBFS traversal:")
bfs(graph, "CIC0004", abbr_to_id)