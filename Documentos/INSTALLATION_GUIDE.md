# Guia de Instalação do Julia e Algoritmo BFS

Este guia irá te orientar na instalação do Julia e execução do algoritmo BFS (Busca em Largura) no DAG de pré-requisitos dos cursos.

## Índice
1. [Instalando o Julia](#instalando-o-julia)
2. [Configurando o Projeto](#configurando-o-projeto)
3. [Entendendo o Código](#entendendo-o-código)
4. [Executando o Algoritmo BFS](#executando-o-algoritmo-bfs)
5. [Gerando Visualizações](#gerando-visualizações)
6. [Solução de Problemas](#solução-de-problemas)

## Instalando o Julia

### Opção 1: Site Oficial do Julia (Recomendado)

1. **Visite o site do Julia**: Acesse [https://julialang.org/downloads/](https://julialang.org/downloads/)

2. **Baixe o Julia**: 
   - Escolha a versão estável mais recente (1.10.x ou mais nova)
   - Selecione o instalador apropriado para seu sistema operacional:
     - **Windows**: Baixe o instalador `.exe`
     - **macOS**: Baixe o arquivo `.dmg`
     - **Linux**: Baixe o arquivo `.tar.gz` apropriado

3. **Instale o Julia**:
   - **Windows**: Execute o arquivo `.exe` e siga o assistente de instalação
   - **macOS**: Abra o arquivo `.dmg` e arraste o Julia para a pasta Applications
   - **Linux**: Extraia o arquivo `.tar.gz` e adicione o Julia ao seu PATH

4. **Verifique a Instalação**:
   ```bash
   julia --version
   ```
   Você deve ver uma saída como: `julia version 1.10.x`


## Configurando o Projeto

### 1. Clone ou Baixe o Projeto
```bash
git clone https://github.com/projeto-de-algoritmos-2025/Grafos1_D40.git

cd Grafos1_D40
```

### 2. Inicialize o Projeto Julia
```bash
# Navegue até o diretório do projeto
cd /caminho/para/Grafos1_D40

# Permite o sh
chmod u+x ./initialize.sh

# Execute o script de inicialização automático
./initialize.sh
```

## Entendendo o Código

### Estrutura do Projeto
```
Grafos1_D40/
├── Projeto/
│   ├── bfs.jl              # Implementação principal do BFS
│   ├── courses.json        # Dados dos cursos com pré-requisitos
│   ├── course_dag.png      # Visualização básica do DAG
│   ├── course_dag_enhanced.png      # Visualização aprimorada
│   └── course_dag_hierarchical.png  # Layout hierárquico
├── Project.toml            # Dependências do projeto Julia
├── Manifest.toml           # Versões exatas dos pacotes
└── README.md              # Documentação do projeto
```

### Funções Principais em `bfs.jl`

#### 1. `load_graph(filename)`
- **Propósito**: Carrega dados dos cursos do arquivo JSON e cria lista de adjacência
- **Entrada**: Caminho para o arquivo `courses.json`
- **Saída**: Dicionário do grafo e mapeamento de abreviações

#### 2. `bfs(graph, start, abbr_to_id)`
- **Propósito**: Executa travessia por busca em largura
- **Entrada**: 
  - `graph`: Representação de lista de adjacência
  - `start`: Curso inicial (pode ser ID completo ou abreviação)
  - `abbr_to_id`: Mapeamento de abreviações para IDs completos
- **Saída**: Imprime cursos na ordem BFS

#### 3. `create_graph_visualization(data, output_file)`
- **Propósito**: Cria visualização aprimorada do DAG
- **Recursos**: Codificação por cores por níveis, setas claras, estilo profissional

#### 4. `create_hierarchical_visualization(data, output_file)`
- **Propósito**: Cria visualização de layout hierárquico
- **Recursos**: Posicionamento baseado em níveis, layout estruturado

## Executando o Algoritmo BFS

```bash
# Do diretório raiz do projeto
julia --proj Projeto/bfs.jl
```

## Gerando Visualizações

### Visualização Básica
O script gera automaticamente três tipos de visualizações:

1. **DAG Básico** (`course_dag.png`): Layout simples do grafo
2. **DAG Aprimorado** (`course_dag_enhanced.png`): Codificado por cores por níveis
3. **DAG Hierárquico** (`course_dag_hierarchical.png`): Layout baseado em níveis


### Estatísticas do Grafo
```
Graph has 44 nodes and 41 edges
Levels: Dict(0 => 11, 4 => 6, 5 => 1, 2 => 9, 3 => 7, 1 => 10)
```

- **44 nós**: Número total de cursos
- **41 arestas**: Número total de relacionamentos de pré-requisitos
- **Níveis**: Distribuição dos cursos pelos níveis de pré-requisitos

## Estrutura dos Dados dos Cursos

O arquivo `courses.json` contém:

```json
{
  "nodes": [
    {
      "id": "CIC0004",
      "label": "Algoritmos e Programação de Computadores",
      "abbr": "APC"
    }
  ],
  "edges": [
    {
      "from": "CIC0004",
      "to": "FGA0158"
    }
  ]
}
```

- **nodes**: Informações dos cursos (ID, nome completo, abreviação)
- **edges**: Relacionamentos de pré-requisitos (do pré-requisito para o curso dependente)

## Uso Avançado

### Implementações Personalizadas de BFS
```julia
# BFS com função de visita personalizada
function custom_bfs(graph, start, abbr_to_id, visit_func)
    visited = Set([start])
    queue = [start]
    
    while !isempty(queue)
        current = popfirst!(queue)
        visit_func(current, abbr_to_id[current])
        
        for neighbor in graph[current]
            if neighbor ∉ visited
                push!(visited, neighbor)
                push!(queue, neighbor)
            end
        end
    end
end

# Uso
custom_bfs(graph, "APC", abbr_to_id, (id, abbr) -> println("Curso: $abbr ($id)"))
```

## Recursos

- [Documentação do Julia](https://docs.julialang.org/)
- [Documentação do Graphs.jl](https://juliagraphs.org/Graphs.jl/)
- [Documentação do Plots.jl](http://docs.juliaplots.org/)
- [Documentação do JSON.jl](https://github.com/JuliaIO/JSON.jl)
