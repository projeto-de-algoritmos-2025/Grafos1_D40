#!/bin/bash

echo "Inicializando projeto Julia BFS..."

# Verificar se Julia está instalado
if ! command -v julia &> /dev/null; then
    echo "Julia não encontrado! Por favor, instale o Julia primeiro."
    echo "   Visite: https://julialang.org/downloads/"
    exit 1
fi

echo "Julia encontrado: $(julia --version)"

# Ativar projeto e instalar pacotes
echo "Instalando pacotes necessários..."
julia --project=. -e "
using Pkg
Pkg.activate(\".\")
Pkg.add([\"Graphs\", \"JSON\", \"Plots\", \"GraphRecipes\"])
Pkg.instantiate()
"
echo "Projeto inicializado!"
