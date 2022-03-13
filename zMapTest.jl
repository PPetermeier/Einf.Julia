# This is just the implementation of the Zombie outbreak Model out of the Agents.jl Doc to get a feeling for the Agents.jl pkg, not part of project #5
using Agents

@agent Zombie OSMAgent begin
    infected::Bool
end

mutable struct Zombie <: AbstractAgent
    id::Int
    pos::Tuple{Int,Int,Float64}
    route::Vector{Int}
    destination::Tuple{Int,Int,Float64}
    infected::Bool
end

function initialise(; map_path = OSM.TEST_MAP)
    model = ABM(Zombie, OpenStreetMapSpace(map_path))

    for id in 1:100
        start = random_position(model) # At an intersection
        finish = OSM.random_road_position(model) # Somewhere on a road
        route = OSM.plan_route(start, finish, model)
        human = Zombie(id, start, route, finish, false)
        add_agent_pos!(human, model)
    end
    # We'll add patient zero at a specific (latitude, longitude)
    start = OSM.road((39.52320181536525, -119.78917553184259), model)
    finish = OSM.intersection((39.510773, -119.75916700000002), model)
    route = OSM.plan_route(start, finish, model)
    # This function call creates & adds an agent, see `add_agent!`
    zombie = add_agent!(start, model, route, finish, true)
    return model
end

function agent_step!(agent, model)
    # Each agent will progress 25 meters along their route
    move_along_route!(agent, model, 25)

    if is_stationary(agent, model) && rand(model.rng) < 0.1
        # When stationary, give the agent a 10% chance of going somewhere else
        OSM.random_route!(agent, model)
        # Start on new route
        move_along_route!(agent, model, 25)
    end

    if agent.infected
        # Agents will be infected if they get within 50 meters of a zombie.
        map(i -> model[i].infected = true, nearby_ids(agent, model, 50))
    end
end

using OpenStreetMapXPlot
using Plots
gr()

ac(agent) = agent.infected ? :green : :black
as(agent) = agent.infected ? 6 : 5

function plotagents(model)
    ids = model.scheduler(model)
    colors = [ac(model[i]) for i in ids]
    sizes = [as(model[i]) for i in ids]
    markers = :circle
    pos = [OSM.map_coordinates(model[i], model) for i in ids]

    scatter!(
        pos;
        markercolor = colors,
        markersize = sizes,
        markershapes = markers,
        label = "",
        markerstrokewidth = 0.5,
        markerstrokecolor = :black,
        markeralpha = 0.7,
    )
end

model = initialise()

frames = @animate for i in 0:200
    i > 0 && step!(model, agent_step!, 1)
    plotmap(model.space.m)
    plotagents(model)
end

gif(frames, "outbreak.gif", fps = 15)
