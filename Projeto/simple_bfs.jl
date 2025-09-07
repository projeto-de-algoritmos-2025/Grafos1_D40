using JSON

"""
Carrega o grafo a partir de um arquivo JSON.
Retorna o grafo como lista de adjacência, mapeamentos de ID para abreviação e label.
"""
function load_graph(filename)
    # Lê e analisa o arquivo JSON
    data = JSON.parsefile(filename)
    
    # Cria dicionários para armazenar informações do grafo
    graph = Dict{String, Vector{String}}()
    id_to_label = Dict{String, String}()
    id_to_abbr = Dict{String, String}()
    
    # Inicializa todos os nós com listas de adjacência vazias
    for node in data["nodes"]
        graph[node["id"]] = String[]
        id_to_label[node["id"]] = node["label"]
        # Use abbreviation if available, otherwise use ID
        id_to_abbr[node["id"]] = get(node, "abbr", node["id"])
    end
    
    # Adiciona arestas à lista de adjacência
    for edge in data["edges"]
        push!(graph[edge["from"]], edge["to"])
    end
    
    return graph, id_to_label, id_to_abbr
end

"""
Implementação da BFS que retorna a ordem de visitação.
"""
function bfs_corrected(graph, start, id_to_abbr)
    if !haskey(graph, start)
        println("Erro: Nó inicial '$start' não encontrado no grafo")
        return String[]
    end
    
    visited = Set{String}()
    queue = [start]
    visit_order = String[]
    
    while !isempty(queue)
        current = popfirst!(queue)
        
        if current ∉ visited
            push!(visited, current)
            push!(visit_order, current)
            println("Visitando: $(id_to_abbr[current]) ($(current))")
            
            for neighbor in graph[current]
                if neighbor ∉ visited && neighbor ∉ queue
                    push!(queue, neighbor)
                end
            end
        end
    end
    
    return visit_order
end

"""
Gera algumas ordens topológicas possíveis a partir de um nó inicial (limitado para performance).
"""
function generate_topological_orders(graph, start, id_to_abbr, max_orders = 10)
    # Primeiro, encontra todos os nós alcançáveis a partir do nó inicial
    reachable = Set{String}()
    
    function find_reachable(node)
        if node ∈ reachable
            return
        end
        push!(reachable, node)
        for neighbor in graph[node]
            find_reachable(neighbor)
        end
    end
    
    find_reachable(start)
    reachable_list = collect(reachable)
    
    println("Nós alcançáveis a partir de $(id_to_abbr[start]): $(length(reachable_list))")
    for node in reachable_list
        println("  - $(id_to_abbr[node]): $(node)")
    end
    println()
    
    # Cria subgrafo apenas com nós alcançáveis
    subgraph = Dict{String, Vector{String}}()
    for node in reachable_list
        subgraph[node] = [neighbor for neighbor in graph[node] if neighbor ∈ reachable]
    end
    
    # Calcula grau de entrada para cada nó no subgrafo
    function calculate_in_degrees(g)
        in_degrees = Dict{String, Int}()
        for node in keys(g)
            in_degrees[node] = 0
        end
        for (node, neighbors) in g
            for neighbor in neighbors
                in_degrees[neighbor] += 1
            end
        end
        return in_degrees
    end
    
    # Gera algumas ordens topológicas (limitado para performance)
    all_orders = Vector{Vector{String}}()
    
    function generate_orders(current_order, remaining_nodes, in_degrees)
        if length(all_orders) >= max_orders
            return  # Limita o número de ordens geradas
        end
        
        if isempty(remaining_nodes)
            push!(all_orders, copy(current_order))
            return
        end
        
        # Encontra nós que podem ser visitados (grau de entrada = 0)
        available = [node for node in remaining_nodes if in_degrees[node] == 0]
        
        for node in available
            if length(all_orders) >= max_orders
                break
            end
            
            # Adiciona o nó à ordem atual
            push!(current_order, node)
            
            # Remove o nó dos restantes
            new_remaining = filter(x -> x != node, remaining_nodes)
            
            # Atualiza graus de entrada
            new_in_degrees = copy(in_degrees)
            for neighbor in subgraph[node]
                if neighbor ∈ new_remaining
                    new_in_degrees[neighbor] -= 1
                end
            end
            
            # Recursão
            generate_orders(current_order, new_remaining, new_in_degrees)
            
            # Backtrack
            pop!(current_order)
        end
    end
    
    in_degrees = calculate_in_degrees(subgraph)
    generate_orders(String[], reachable_list, in_degrees)
    
    return all_orders
end

"""
Verifica se o grafo é um DAG (Directed Acyclic Graph).
"""
function is_dag(graph)
    # Usa DFS para detectar ciclos
    white = Set(keys(graph))  # Não visitados
    gray = Set{String}()      # Em processamento
    black = Set{String}()     # Processados
    
    function has_cycle(node)
        if node ∈ black
            return false
        end
        if node ∈ gray
            return true  # Ciclo detectado
        end
        
        delete!(white, node)
        push!(gray, node)
        
        for neighbor in graph[node]
            if has_cycle(neighbor)
                return true
            end
        end
        
        delete!(gray, node)
        push!(black, node)
        return false
    end
    
    for node in collect(white)
        if node ∈ white && has_cycle(node)
            return false
        end
    end
    
    return true
end

"""
Análise do grafo - estatísticas básicas.
"""
function analyze_graph(graph, id_to_abbr, id_to_label)
    println("=== ANÁLISE DO GRAFO ===")
    println("Número de nós: $(length(graph))")
    
    total_edges = sum(length(neighbors) for neighbors in values(graph))
    println("Número de arestas: $total_edges")
    
    # Nós sem predecessores (fontes)
    sources = String[]
    sinks = String[]
    
    all_targets = Set{String}()
    for neighbors in values(graph)
        for neighbor in neighbors
            push!(all_targets, neighbor)
        end
    end
    
    for node in keys(graph)
        if node ∉ all_targets
            push!(sources, node)
        end
        if isempty(graph[node])
            push!(sinks, node)
        end
    end
    
    println("Nós fonte (sem predecessores): $(length(sources))")
    for source in sources
        println("  - $(id_to_abbr[source]): $(id_to_label[source])")
    end
    
    println("Nós sumidouro (sem sucessores): $(length(sinks))")
    for sink in sinks
        println("  - $(id_to_abbr[sink]): $(id_to_label[sink])")
    end
    
    println("É um DAG? $(is_dag(graph))")
    println()
end

"""
Gera todas as ordens topológicas possíveis para um grafo.
"""
function get_all_topological_orders(graph)
    orders = Vector{Vector{String}}()
    visited = Dict(node => false for node in keys(graph))
    
    # Calcula grau de entrada inicial
    in_degree = Dict{String, Int}()
    for node in keys(graph)
        in_degree[node] = 0
    end
    for (_, neighbors) in graph
        for neighbor in neighbors
            in_degree[neighbor] += 1
        end
    end
    
    function backtrack(current_order)
        if length(current_order) == length(graph)
            push!(orders, copy(current_order))
            return
        end
        
        for node in keys(graph)
            if !visited[node] && in_degree[node] == 0
                visited[node] = true
                push!(current_order, node)
                
                # Atualiza graus de entrada
                for neighbor in graph[node]
                    in_degree[neighbor] -= 1
                end
                
                backtrack(current_order)
                
                # Retrocede
                visited[node] = false
                pop!(current_order)
                for neighbor in graph[node]
                    in_degree[neighbor] += 1
                end
            end
        end
    end
    
    backtrack(String[])
    return orders
end

# Função principal para testar tudo
function main()
    graph, id_to_label, id_to_abbr = load_graph("courses.json")
    start_node = "CIC0004"
    
    topological_orders = generate_topological_orders(graph, start_node, id_to_abbr)
    
    println("=== ORDENS TOPOLÓGICAS ===")
    println("Total de ordens encontradas: $(length(topological_orders))\n")
    
    # Show all topological orders found
    for (i, order) in enumerate(topological_orders)
        println("Ordem topológica $i:")
        for (j, node) in enumerate(order)
            println("  $j. $(id_to_abbr[node]) - $(id_to_label[node])")
        end
        println()
    end
    
    return topological_orders
end

# Executa o programa principal
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

