using JSON

"""
    load_graph(filename::String)

Carrega o grafo a partir de um arquivo JSON.
Retorna o grafo como lista de adjacência, mapeamentos de ID para abreviação e label.
"""
function load_graph(filename::String)
    data = JSON.parsefile(filename)
    
    graph = Dict{String, Vector{String}}()
    id_to_label = Dict{String, String}()
    id_to_abbr = Dict{String, String}()
    
    # Inicializa todos os nós
    for node in data["nodes"]
        graph[node["id"]] = String[]
        id_to_label[node["id"]] = node["label"]
        id_to_abbr[node["id"]] = get(node, "abbr", node["id"])
    end
    
    # Adiciona arestas
    for edge in data["edges"]
        push!(graph[edge["from"]], edge["to"])
    end
    
    return graph, id_to_label, id_to_abbr
end

"""
    is_dag_dfs(graph::Dict{String, Vector{String}})

Verifica se o grafo é um DAG usando DFS.
Estados: 0 = não visitado, 1 = em processamento, 2 = processado
"""
function is_dag_dfs(graph::Dict{String, Vector{String}})
    state = Dict{String, Int}(node => 0 for node in keys(graph))
    
    function has_cycle_dfs(node::String)
        state[node] == 1 && return true  # Ciclo detectado
        state[node] == 2 && return false # Já processado
        
        state[node] = 1  # Marca como em processamento
        
        for neighbor in graph[node]
            has_cycle_dfs(neighbor) && return true
        end
        
        state[node] = 2  # Marca como processado
        return false
    end
    
    for node in keys(graph)
        state[node] == 0 && has_cycle_dfs(node) && return false
    end
    
    return true
end

"""
    calculate_in_degrees(graph::Dict{String, Vector{String}})

Calcula o grau de entrada de cada nó no grafo.
"""
function calculate_in_degrees(graph::Dict{String, Vector{String}})
    in_degrees = Dict{String, Int}(node => 0 for node in keys(graph))
    
    for neighbors in values(graph)
        for neighbor in neighbors
            in_degrees[neighbor] += 1
        end
    end
    
    return in_degrees
end

"""
    generate_topological_orders_dfs(graph, id_to_abbr, id_to_label, max_orders=50)

Gera ordens topológicas usando DFS com backtracking.
"""
function generate_topological_orders_dfs(graph, id_to_abbr, id_to_label, max_orders::Int=50)
    println("=== GERANDO ORDENS TOPOLÓGICAS USANDO DFS ===")
    
    !is_dag_dfs(graph) && (println("ERRO: O grafo contém ciclos!"); return Vector{Vector{String}}())
    
    in_degrees = calculate_in_degrees(graph)
    all_orders = Vector{Vector{String}}()
    orders_count = 0
    
    function dfs_generate(current_order, remaining_in_degrees, visited)
        orders_count >= max_orders && return
        
        if length(current_order) == length(graph)
            push!(all_orders, copy(current_order))
            orders_count += 1
            orders_count % 10 == 0 && println("  Ordens encontradas: $orders_count")
            return
        end
        
        # Encontra nós disponíveis (grau de entrada = 0 e não visitados)
        available_nodes = [node for node in keys(graph) 
                          if !visited[node] && remaining_in_degrees[node] == 0]
        
        for node in available_nodes
            orders_count >= max_orders && break
            
            visited[node] = true
            push!(current_order, node)
            
            new_in_degrees = copy(remaining_in_degrees)
            for neighbor in graph[node]
                new_in_degrees[neighbor] -= 1
            end
            
            dfs_generate(current_order, new_in_degrees, visited)
            
            # Backtrack
            pop!(current_order)
            visited[node] = false
        end
    end
    
    visited = Dict{String, Bool}(node => false for node in keys(graph))
    println("Iniciando busca com limite de $max_orders ordens...")
    dfs_generate(String[], in_degrees, visited)
    
    return all_orders
end

"""
    count_topological_orders(graph::Dict{String, Vector{String}})

Calcula o número total de ordens topológicas usando programação dinâmica.
"""
function count_topological_orders(graph::Dict{String, Vector{String}})
    n = length(graph)
    n == 0 && return 0
    
    in_degrees = calculate_in_degrees(graph)
    memo = Dict{String, Int}()
    
    function count_orders_dp(visited_mask, remaining_in_degrees)
        length(visited_mask) == n && return 1
        
        state_key = join(sort(collect(visited_mask)), ",") * "|" * 
                   join([string(k, ":", v) for (k, v) in remaining_in_degrees], ",")
        
        haskey(memo, state_key) && return memo[state_key]
        
        total_count = 0
        for node in keys(graph)
            if !(node in visited_mask) && remaining_in_degrees[node] == 0
                new_visited = union(visited_mask, Set([node]))
                new_in_degrees = copy(remaining_in_degrees)
                
                for neighbor in graph[node]
                    new_in_degrees[neighbor] -= 1
                end
                
                total_count += count_orders_dp(new_visited, new_in_degrees)
            end
        end
        
        memo[state_key] = total_count
        return total_count
    end
    
    return count_orders_dp(Set{String}(), in_degrees)
end

"""
    remove_duplicate_orders(orders::Vector{Vector{String}})

Remove ordens topológicas duplicadas.
"""
function remove_duplicate_orders(orders::Vector{Vector{String}})
    isempty(orders) && return orders
    
    order_strings = Set{String}()
    unique_orders = Vector{Vector{String}}()
    
    for order in orders
        order_str = join(order, ",")
        if !(order_str in order_strings)
            push!(order_strings, order_str)
            push!(unique_orders, order)
        end
    end
    
    return unique_orders
end

"""
    display_topological_order(order, id_to_abbr, id_to_label, order_number)

Exibe uma ordem topológica de forma formatada.
"""
function display_topological_order(order, id_to_abbr, id_to_label, order_number::Int)
    println("Ordem Topológica #$order_number:")
    println("=" ^ 50)
    for (i, node) in enumerate(order)
        println("$i. $(id_to_abbr[node]) - $(id_to_label[node])")
    end
    println()
end

"""
    analyze_graph(graph, id_to_abbr, id_to_label)

Análise básica do grafo - estatísticas e propriedades.
"""
function analyze_graph(graph, id_to_abbr, id_to_label)
    println("=== ANÁLISE DO GRAFO ===")
    println("Número de nós: $(length(graph))")
    
    total_edges = sum(length(neighbors) for neighbors in values(graph))
    println("Número de arestas: $total_edges")
    
    # Encontra fontes e sumidouros
    all_targets = Set{String}()
    for neighbors in values(graph)
        for neighbor in neighbors
            push!(all_targets, neighbor)
        end
    end
    
    sources = [node for node in keys(graph) if node ∉ all_targets]
    sinks = [node for node in keys(graph) if isempty(graph[node])]
    
    println("Nós fonte: $(length(sources))")
    for source in sources
        println("  - $(id_to_abbr[source]): $(id_to_label[source])")
    end
    
    println("Nós sem sucessores: $(length(sinks))")
    for sink in sinks
        println("  - $(id_to_abbr[sink]): $(id_to_label[sink])")
    end
    
    println("É um DAG? $(is_dag_dfs(graph))")
    println()
end

"""
    main()

Função principal que executa a análise completa do grafo.
"""
function main()
    # Carrega o grafo
    graph, id_to_label, id_to_abbr = load_graph("Projeto/courses.json")
    
    # Análise do grafo
    analyze_graph(graph, id_to_abbr, id_to_label)
    
    # Conta ordens topológicas
    println("=== CONTAGEM DE ORDENS TOPOLÓGICAS ===")
    count_start_time = time()
    total_orders = count_topological_orders(graph)
    count_end_time = time()
    
    println("Número total de ordens topológicas possíveis: $total_orders")
    println()
    
    # Gera algumas ordens topológicas
    start_time = time()
    all_orders = generate_topological_orders_dfs(graph, id_to_abbr, id_to_label, 15)
    end_time = time()
    
    # Remove duplicatas
    println("Removendo ordens duplicadas...")
    unique_orders = remove_duplicate_orders(all_orders)
    
    # Resultados
    println("=== RESULTADOS ===")
    println("Total de ordens geradas: $(length(all_orders))")
    println("Total de ordens únicas: $(length(unique_orders))")
    println()
    
    # Exibe ordens encontradas
    if !isempty(unique_orders)
        println("=== ORDENS TOPOLÓGICAS ÚNICAS ===")
        for (i, order) in enumerate(unique_orders)
            display_topological_order(order, id_to_abbr, id_to_label, i)
        end
    else
        println("Nenhuma ordem topológica foi encontrada.")
    end
    
    return unique_orders
end

# Executa o programa principal
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end