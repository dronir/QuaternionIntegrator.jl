push!(LOAD_PATH, "..")

using Documenter, QuaternionIntegrator

makedocs(
    sitename = "QuaternionIntegrator.jl",
    pages = [
        "QuaternionIntegrator" => "index.md",
        "The algorithm" => "algorithm.md",
        "API" => "interface.md"
    ]
)