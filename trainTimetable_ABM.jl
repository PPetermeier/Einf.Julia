using Agents

@agent Mover GraphAgent begin
    isTrain::Bool
end

mutable struct Mover <: AbstractAgent
    id::Int
    pos::Tuple{Int,Int,Float64}
    route::Vector{Int}
    destination::Tuple{int,Int,Float64}
    isTrain::Bool
    capacity::Int
end

function initialize(; numagents = 12)
    space = GraphSpace()

end

function agent_step!(agent, model)
    # Moving each Agent One Step per One Time unit

end
