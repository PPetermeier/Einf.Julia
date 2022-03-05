using Agents

@agent Mover GraphAgent begin
    isTrain::Bool
end

#Struktur Konzept:
#Knoten = Bahnhöfe mit ID & Kapazität
#Strecken =  Kanten der Knoten mit: ID, Knoten 1&2, Kapazität, Länge (nicht mehr sicher ob das errechnet werden muss oder nicht)
#Agenttyp 1 = Zug mit ID, Kapazität, Geschwindigkeit, Startposition, boardable(boolean), Array mit schedule, der sich automatisch bei steps appended
#Agenttyp 2 = Agent mit ID, Start, Ziel, Zielzeit, Größe der Gruppe, Array mit schedule mit den möglichen Einträgen add train für zusteigen, detrain für verlassen
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
