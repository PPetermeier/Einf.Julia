using Agents, Plots

# Agentendefinition mit Werten: Need = Energiebedarf / Zyklus, extraction = maximal extrahierte Energie / Zyklus, reserve = maximale Reserve, threshhold = Wert bis zur Duplizierung, restliche reserve wird geteilt, 
mutable struct BasicConsumer<: AbstractAgent
    id:: Int
    pos::Dims{2}
    age:: Int
    max_age::Int
    need::Int
    extraction::Int
    reserve::Float16
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
    space = GridSpace(dims)
    properties = Dict(
        :N => N,
        :need_distribution => need_distribution ,
        :extraction_distribution => extraction_distribution,
        :max_age_distribution => max_age_distribution,
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


#---------------------- Ab hier experimental

# Addiere den begrenzenden Extraktionswert für den Agenten und subtrahiere den Need
function harvest!(agent, model)
    placesugarvalue=model.sugar_capacities[agent.pos[1],agent.pos[2]] 
    
    if agent.extraction > placesugarvalue
        agent.reserve += ((model.sugar_capacities[agent.pos[1],agent.pos[2]]) - agent.need)
    else 
        agent.reserve += (agent.extraction - agent.need)    
    end
    #amount = min(agent.extraction, model.sugar_values[place])
    #agent.reserve += (amount - agent.need)
end

# Wenn Grenzwert zur Reproduktion überschritten und Platz frei ist, "Zellteilung" auf eine der freien Nachbarorten, Reserve: 1/4 jeweils an Kinder, 1/2 Aufwand für Reproduktion
function populate!(agent,model)
   if agent.reserve>agent.threshhold
        birthplace = []
        empty_space = collect(empty_positions(model))
        for i in nearby_positions(agent.pos, model, 2)
            if i in empty_space
                push!(birthplace, i)
            end
        end    
        if length(birthplace) > 0
                resourcepool = (1/4)*(agent.reserve) 
                agent.reserve*=resourcepool
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
    end        
end

# Letzer Funktionscall sollte seperat am Ende in einer Schleife laufen, weil evtl. vorher geteilt wird
function survivalcheck!(agent)
    if agent.reserve <= 0 || agent.age >= agent.max_age
        kill_agent!
    end
end

function agent_step!(agent, model)
    harvest!(agent, model)
    populate!(agent, model)
    survivalcheck!(agent)
end

heatmap(model.sugar_capacities)

anim = @animate for i in 1:50
    step!(model, agent_step!, 1)
    p1= plotabm(model, as = 3, am = :square, ac = :blue)
    title!(p1, "Agents\n Step $i")
    p = plot(p1)
end
gif(anim, "sugar.gif", fps = 8)



#adata, _ = run!(model, agent_step!, 60, adata = [:reserve])

#anim = @animate for i in 1:50
#    step!(model, agent_step!, 1)
#    p1 = heatmap(model.sugar_values)
#    p2 = plotabm(model, as = 3, am = :square)
#    title!(p1, "Energiepotential")
#    title!(p2, "Agents \n Step $i" )
#   p = plot(p1, p2)
#end 
#gif(anim, "testgif.gif", fps=8)

#anim2 =  @animate for i in 0:60
#    histogram(
#   adata[adata.step .== i, :reserve],
#   legend = false,
#color = :black,
#    nbins = 15,

#title = "step $i",
#)
#end
#gif(anim2, fps = 3)
