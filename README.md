# BFS - Ordem Topológica

**Número da Lista**: 1  
**Conteúdo da Disciplina**: FGA0124 - PROJETO DE ALGORITMOS - T01  


## Alunos


<div align = "center">
<table>
  <tr>
    <td align="center"><a href="https://github.com/joaombc"><img style="border-radius: 50%;" src="https://github.com/joaombc.png" width="190;" alt=""/><br /><sub><b>João Paulo</b></sub></a><br /><a href="Link git" title="Rocketseat"></a></td>
    <td align="center"><a href="https://github.com/yanzin00"><img style="border-radius: 50%;" src="https://github.com/yanzin00.png" width="190px;" alt=""/><br /><sub><b>Yan Guimarães </b></sub></a><br />
  </tr>
</table>

| Matrícula   | Aluno                             |
| ----------- | ---------------------------------- |
| 20/2045141  | João Paulo Monteiro de Barros Ceva Rodrigues|
| 22/2006220  | Yan Guimarães |
</div>

## Sobre

Este projeto utiliza algoritmos de grafos para analisar e visualizar o fluxograma de Engenharia de Software. A partir de um arquivo JSON com as disciplinas e seus pré-requisitos, o programa constrói um grafo direcionado acíclico (DAG) e realiza diversas operações:

- **Visualização**: Gera fluxogramas hierárquicos do currículo, destacando os níveis e dependências entre disciplinas.
- **Percurso e Análise**: Utiliza algoritmos BFS e DFS para percorrer o grafo, identificar fontes, sumidouros e verificar se o grafo é um DAG.
- **Ordenações Topológicas**: Lista todas as possíveis ordens topológicas das disciplinas, mostrando diferentes formas válidas de cursar o ciclo.
- **Estatísticas**: Exibe informações como número de disciplinas, arestas, fontes, sumidouros e total de ordenações possíveis.

O projeto facilita o entendimento da estrutura curricular, permitindo visualizar caminhos de formação e dependências entre matérias de forma clara

## Grafo Acíclico Direcionado (DAG) Fluxograma APC
<p align="center">
  <img src="Projeto/graph/course_dag_hierarchical2.png" alt="Dag fluxograma APC" width="800"/>
</p>




### Instalando o Julia

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
cd /caminho/para/Grafos1_D40/Projeto

# Rodar o arquivo Julia
julia run {{nome_do_arquivo}}
```

## Apresentação 

<div align="center">
<a href="https://youtu.be/VmqM0kqmLx8"><img src="https://img.youtube.com/vi/VmqM0kqmLx8/maxresdefault.jpg" width="50%"></a>
</div>

<font size="3"><p style="text-align: center">Autor: [João Paulo](https://github.com/joaombc) e [yan Guimarães](https://github.com/yanzin00).</p></font>

