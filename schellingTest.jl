# This is just the implementation of the Schelling Model out of the Agents.jl Doc to get a feeling for the Agents.jl pkg, 
# also commenting in english cause its cool and to keep the file english :D
using Agents, InteractiveDynamics, CairoMakie

#= # struct for the SchellingAgent, best practice is using the @agent makro like below which will do the same
mutable struct SchellingAgent <: AbstractAgent
    id::Int # The identifier number of the Agents
    pos::Dims{2} # The x, y location of the agent on a 2D grid
    mood::Bool # whether the agent is happy in its postion. (true = happy)
    group::Int # the group of the agent, determines mood as it interacts with neighbors
end
=#
@agent SchellingAgent GridAgent{2} begin
    mood::Bool
    group::Int
end

#space = GridSpace((5,5), periodic = false) # Grid Space which is used to simulate the neighborhood
#properties = Dict(:min_to_be_happy => 3) # defining the number of like-minded neighbors requiered to turn the happy boolean true 
#schelling = ABM(SchellingAgent, space; properties) # defining  the AgentBaseModel to build the fundation so we can use the Agents.jl pkg for our Schelling Usecase, using default scheduler

function initialize(; numagents = 290, griddims = (20, 20), min_to_be_happy = 3)
    space = GridSpace(griddims, periodic = false)
    properties = Dict(:min_to_be_happy => min_to_be_happy)
    model = ABM(SchellingAgent, space; properties = properties, scheduler = random_activation)
    
    # populate the model with agents, adding equal amount of the two types of agents at random positions in the model
    for n in 1:numagents
        agent = SchellingAgent(n, (1, 1), false, n < numagents / 2 ? 1 : 2)
        add_agent_single!(agent, model)
    end
    return model
end

function agent_step!(agent, model)
    agent.mood == true && return # do nothing if allready happy
    minhappy = model.min_to_be_happy
    neighbor_positions = nearby_positions(agent, model)
    count_neighbors_same_group = 0
    # For each neighbor, get group and compare to current agent's group and increment count_neighbors_same_group as appropriately.
    for neighbor in nearby_agents(agent, model)
        if agent.group ==  neighbor.group
            count_neighbors_same_group += 1
        end
    end
    # After counting the neighbors, decide whether or not to move the agent.
    # If count_neighbors_same_group is at least the min_to_be_happy, set the mood to true. Otherwise, move the agnet to a random postion.
    if count_neighbors_same_group >= minhappy
        agent.mood = true
    else
        move_agent_single!(agent, model)
    end
    return
end

# preparing a Dataframe to collect data
adata = [:pos, :mood, :group]

# initializing and stepping the model
model = initialize()

# Run and collect data
data, _ = run!(model, agent_step!, 5; adata)
#print(data[1:10, :]) # print only a few rows

# Visualize the data with Plots - plotabm
#plotabm()
groupcolor(a) = a.group == 1 ? :blue : :orange
groupmarker(a) = a.group == 1 ? :circle : :rect

#schellingplot = plotabm(model; ac = groupcolor, am = groupmarker, as = 4) 
# there is a strange warning here: 
#┌ Warning: Plots.jl recipes have been superseded by InteractiveDynamics.jl 
#└ @ Agents C:\Users\Tim\.julia\packages\Agents\h9Ls1\src\visualization\plot-recipes.jl:61

#gui() # shows the Plot in a standalone window
#readline() # Using readline to pause the programm exit on enter

#=
# showing plot with plots.jl
plotabm(model; ac = groupcolor, am = groupmarker, as = 4) # show the updated plot
gui()
readline()
step!(model, agent_step!, 3) # advancing the model number of steps
plotabm(model; ac = groupcolor, am = groupmarker, as = 4)
gui()
readline()
=#

#=
# Animated Visualization with plots.jl
anim = @animate for i in 0:10
    pl = plotabm(model; ac = groupcolor, am = groupmarker, as = 4)
    title!(pl, "step $(i)")
    step!(model, agent_step!, 1)
end

#gif(anim, "schelling.gif", fps = 2)
=#

# showing plot with InteractiveDynamics
#CairoMakie.activate!() # activating the CairoMakie Backend
#figure, _ = abm_plot(model, ac = groupcolor, am = groupmarker, as = 4) # Creating plot figure with InteractiveDynamics
#figure # returning the figure to display the plot

#readline()
#scene = abm_play(model, agent_step!,ac = groupcolor, am = groupmarker, as = 4)
#show(scene)

abm_video(
    "schelling.mp4", model, agent_step!;
    ac = groupcolor, am = groupmarker, as = 10,
    framerate = 4, frames = 20,
    title = "Schelling's segregation model"
)