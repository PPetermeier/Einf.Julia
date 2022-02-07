using Agents, Plots

# Agentendefinition mit Werten: Need = Energiebedarf / Zyklus, extraction = maximal extrahierte Energie / Zyklus, reserve = maximale Reserve, threshhold = Wert bis zur Duplizierung, restliche reserve wird geteilt, 
mutable struct BasicConsumer<: GridAgent{2}
    age:: Int
    max_age::Int
    need::Int
    extraction::Int
    reserve::Int
    max_reserve::Int
    threshhold::Int
end



#dims: 50,50 
# Eigenschaften der Orte: Available Energy (wie im sugarscape) später: Transferkapazität (in & out), Bedarfsmultiplikatoren
# Zum start radiale Struktur mit festen Peaks. Für komplette Randomisierung & glättung später parallelisierung?
#Start: Übernahme von distances & sugar_caps aus sugarspace

function distances(pos, sugar_peaks, max_sugar)
    all_dists = Array{Int,1}(undef, length(sugar_peaks))
    for (ind, peak) in enumerate(sugar_peaks)
        d = round(Int, sqrt(sum((pos .- peak) .^ 2)))
        all_dists[ind] = d
    end
    return minimum(all_dists)
end

function sugar_caps(dims, sugar_peaks, max_sugar, dia = 4)
    sugar_capacities = zeros(Int, dims)
    for i in 1:dims[1], j in 1:dims[2]
        sugar_capacities[i, j] = distances((i, j), sugar_peaks, max_sugar)
    end
    for i in 1:dims[1]
        for j in 1:dims[2]
            sugar_capacities[i, j] = max(0, max_sugar - (sugar_capacities[i, j] ÷ dia))
        end
    end
    return sugar_capacities
end


# Unser Modell braucht keine growth-rate und weniger Agenenten, weil diese sich reproduzieren sollen. 
function altered_sugarscape(; dims = (50, 50),
                                sugar_peaks = ((5, 15), (45, 35), (25, 25)),
                                N = 50,                               
                                max_age_distribution = (30,60),
                                need_distribution = (1,3),
                                extraction_distribution = (2,4),
                                reserve_distribution = (6, 18),
                                max_reserve_distribution = (15,45),
                                max_sugar = 4
)
    sugar_capacities = sugar_caps(dims, sugar_peaks, max_sugar, 6)
    sugar_values = deepcopy(sugar_capacities)
    space = GridSpace(dims)
    properties = Dict(
        :N => N,
        :need_distribution => need_distribution ,
        :extraction_distribution => extraction_distribution,
        :max_age_distribution => max_age_distribution,
        :sugar_values => sugar_values,
        :sugar_capacities => sugar_capacities,
    )
    model = AgentBasedModel(
        BasicConsumer,
        space,
        scheduler = random_activation,
        properties = properties,
    )
    for ag in 1:N
        add_agent_single!(
            model,
            0,
            rand(max_age_distribution[1]:max_age_distribution[2]),
            rand(need_distribution[1]:need_distribution[2]),
            rand(extraction_distribution[1]:extraction_distribution[2]),
            rand(reserve_distribution[1]:reserve_distribution[2]),
            rand(max_reserve_distribution[1]:max_reserve_distribution[2]),
            20
        )
    end
    return model
end

model = altered_sugarscape()

heatmap(model.sugar_capacities)

function harvest!(agent, model)
    agent.reserve+=maximum(agent.extraction, sugar_values[agent.pos])-agent.need

end

function populate(agent,model)
   if agent.reserve>agent.threshhold
        empty_space=collect(empty.positions(model))
        if empty_space ! =nothing
                resourcepool = 1/4*agent.reserve 
                agent.reserve*=1/4
                model.position = rand(empty_space)
                add_agent_single!(
                model,
                0,
                rand(max_age_distribution[1]:max_age_distribution[2]),
                rand(need_distribution[1]:need_distribution[2]),
                rand(extraction_distribution[1]:extraction_distribution[2]),
                resourcepool,
                rand(max_reserve_distribution[1]:max_reserve_distribution[2]),
            20
        )
            
end

function survivalcheck(agent)
    if agent.reserve<0 
        kill_agent!
    end
end