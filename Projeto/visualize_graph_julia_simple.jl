using JSON
using Graphs
using Plots

"""
Carrega os dados do grafo a partir do arquivo JSON.
"""
function load_graph_data(filename::String)
    return JSON.parsefile(filename)
end

"""
Cria um grafo Graphs.jl a partir dos dados JSON.
"""
function create_julia_graph(data::Dict)
    id_to_index = Dict{String, Int}()
    index_to_abbr = Dict{Int, String}()
    
    # Mapeia IDs para índices
    for (i, node) in enumerate(data["nodes"])
        id_to_index[node["id"]] = i
        index_to_abbr[i] = node["abbr"]
    end
    
    # Cria o grafo direcionado
    n_nodes = length(data["nodes"])
    g = SimpleDiGraph(n_nodes)
    
    # Adiciona arestas
    for edge in data["edges"]
        if haskey(id_to_index, edge["from"]) && haskey(id_to_index, edge["to"])
            add_edge!(g, id_to_index[edge["from"]], id_to_index[edge["to"]])
        end
    end
    
    return g, id_to_index, index_to_abbr
end

"""
Calcula layout hierárquico baseado nos níveis topológicos.
"""
function calculate_layout(g::SimpleDiGraph)
    n_nodes = nv(g)
    levels = zeros(Int, n_nodes)
    in_degree = [indegree(g, i) for i in 1:n_nodes]
    queue = [i for i in 1:n_nodes if in_degree[i] == 0]
    level = 0
    
    while !isempty(queue)
        next_queue = Int[]
        for node in queue
            levels[node] = level
            for successor in outneighbors(g, node)
                in_degree[successor] -= 1
                if in_degree[successor] == 0
                    push!(next_queue, successor)
                end
            end
        end
        queue = next_queue
        level += 1
    end
    
    positions = Vector{Tuple{Float64, Float64}}(undef, n_nodes)
    level_groups = Dict{Int, Vector{Int}}()
    
    for i in 1:n_nodes
        level = levels[i]
        if !haskey(level_groups, level)
            level_groups[level] = Int[]
        end
        push!(level_groups[level], i)
    end
    
    max_level = maximum(levels)
    for (level, nodes) in level_groups
        y = max_level - level + 1
        for (i, node) in enumerate(nodes)
            x = i - (length(nodes) + 1) / 2
            positions[node] = (x * 3.0, y * 2.0)
        end
    end
    
    return positions
end

"""
Cria visualização do grafo usando scatter e plot.
"""
function create_graph_plot(g::SimpleDiGraph, positions::Vector{Tuple{Float64, Float64}}, 
                         index_to_abbr::Dict{Int, String})
    x_coords = [pos[1] for pos in positions]
    y_coords = [pos[2] for pos in positions]
    
    plt = plot(size = (1400, 1000), 
              background_color = :white,
              grid = false,
              showaxis = false,
              legend = false,
              xlims = (minimum(x_coords) - 2, maximum(x_coords) + 2),
              ylims = (minimum(y_coords) - 1, maximum(y_coords) + 1))
    
    # Desenha arestas primeiro
    for edge in edges(g)
        x1, y1 = positions[src(edge)]
        x2, y2 = positions[dst(edge)]
        plot!(plt, [x1, x2], [y1, y2], color = :black, alpha = 0.5)
    end
    
    # Desenha nós com tamanho aumentado
    for i in 1:nv(g)
        x, y = positions[i]
        # Aumenta markersize para 25 (era 8)
        scatter!(plt, [x], [y], markersize = 35, color = :lightblue)
        # Aumenta fonte para 12 (era 8)
        annotate!(plt, x, y, text(index_to_abbr[i], 12))
    end
    
    savefig(plt, "/Projeto/graph/graph2.png")
end

"""
Função principal que executa somente a visualização da DAG.
"""
function main()
    # Carrega dados silenciosamente
    data = load_graph_data("Projeto/courses.json")
    
    # Cria grafo
    g, id_to_index, index_to_abbr = create_julia_graph(data)
    
    # Calcula níveis e posições
    positions = calculate_layout(g)
    
    # Cria apenas a visualização do grafo
    create_graph_plot(g, positions, index_to_abbr)
end

# Modifica o bloco principal para ser silencioso
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

