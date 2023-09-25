using Revise
using Geant4
using Geant4.SystemOfUnits
using GLMakie, Rotations, IGLWrap_jll  # to force loading G4Vis extension

include(joinpath(@__DIR__, "Parameters.jl"))
include(joinpath(@__DIR__, "Geometry.jl"))
include(joinpath(@__DIR__, "VisAttributes.jl"))

#---Detector read from GDML------------------------------------------------------------------------
const detGDML = "$(@__DIR__)/../TileTB_2B1EB_nobeamline.gdml"
detconstructor = G4JLDetectorGDML(detGDML, validate_schema=false,
                                  init_method=initVisAttributes)

#---Define Simulation Data struct------------------------------------------------------------------
struct Track
    particle::String
    charge::Int
    energy::Float64
    points::Vector{Point3{Float64}}
end
mutable struct VisualizationData <: G4JLSimulationData
    #---Run data-----------------------------------------------------------------------------------
    fParticle::String
    fEkin::Float64
    #---tracks-------------------------------------------------------------------------------------
    tracks::Vector{Track}
    VisualizationData() = new("", 0.0, Track[])
end

#---Actions----------------------------------------------------------------------------------------
#---Step action------------------------------------------------------------------------------------
function stepping!(step::G4Step, app::G4JLApplication)::Nothing
    tracks = getSIMdata(app).tracks
    p = step |> GetPostStepPoint |> GetPosition
    #auxpoints = step |> GetPointerToVectorOfAuxiliaryPoints
    #if auxpoints != C_NULL
    #    for ap in auxpoints
    #        push!(tracks[end].points, Point3{Float64}(x(ap),y(ap),z(ap)))
    #    end
    #end
    push!(tracks[end].points, Point3{Float64}(x(p),y(p),z(p)))
    return
end
#---Tracking pre-action---------------------------------------------------------------------------- 
function pretrackaction!(track::G4Track, app::G4JLApplication)::Nothing
    tracks = getSIMdata(app).tracks
    p = GetPosition(track)[]
    particle = track |> GetParticleDefinition
    name = particle |> GetParticleName |> String
    charge = particle |> GetPDGCharge |> Int
    energy = track |> GetKineticEnergy
    push!(tracks, Track(name, charge, energy, [Point3{Float64}(x(p),y(p),z(p))]))
    return
end
#---Begin-event-action---------------------------------------------------------------------------- 
function beginevent!(::G4Event, app::G4JLApplication)::Nothing
    data = getSIMdata(app)
    empty!(data.tracks)
    return
end
#---Begin Run Action-------------------------------------------------------------------------------
function beginrun!(::G4Run, app::G4JLApplication)::Nothing
    data = getSIMdata(app)
    gun = app.generator.data.gun
    data.fParticle = gun |> GetParticleDefinition |> GetParticleName |> String
    data.fEkin = gun |> GetParticleEnergy
    return
end

#---Particle Gun initialization--------------------------------------------------------------------
const primaryAngle = 76*deg  # set TB angle as on ATLAS reference paper
particlegun = G4JLGunGenerator(particle = "pi+", 
                               energy = 18GeV, 
                               direction = G4ThreeVector(sin(primaryAngle),0,cos(primaryAngle)), 
                               position = G4ThreeVector(2298.,0.,0.))

#---Create the Application-------------------------------------------------------------------------
app = G4JLApplication(detector     = detconstructor,                  # detector defined with a GDML file
                      simdata      = VisualizationData(),             # simlation data structure
                      generator    = particlegun,                     # primary generator to instantiate
                      physics_type = FTFP_BERT,                       # what physics list to instantiate
                      #----Actions--------------------------------
                      stepaction_method = stepping!,                  # step action method
                      pretrackaction_method=pretrackaction!,        # begin-tracking action
                      beginrunaction_method=beginrun!,                    # end-run action (print summary)               
                      begineventaction_method=beginevent!,            # begin-event action (initialize per-event data)
                     )

configure(app)
initialize(app)

#---Draw the detector and event -------------------------------------------------------------------
function draw_detector()
    set_theme!(backgroundcolor = :black)
    fig = Figure(resolution=(1280, 720))
    s = LScene(fig[1,1])
    world = GetWorldVolume()
    draw!(s, world)
    display(fig)
    return s
end

function draw_event(s, app)
    data = app.simdata[1]
    # clear previous plots from previous event
    tobe = [p for p in plots(s) if p isa Lines || p isa Makie.Text]  # The event is made of lines and text 
    for p in tobe
        delete!(s,p)
    end
    lines!(s, data.tracks[1].points, color=:blue)
    # collect points from all tracks
    points = Point3{Float64}[]
    for t in data.tracks[2:end]
        append!(points, t.points)
        push!(points, Point3{Float64}(NaN,NaN,NaN))
    end
    lines!(s, points, color=:yellow, tranparency=false, overdraw=false)
end


s = draw_detector()
beamOn(app, 1)
draw_event(s, app)

#SetParticleEnergy(particlegun, 10GeV)
#SetParticleByName(particlegun, "mu+")
#beamOn(app, 1)
#draw_event(s, app)

#SetParticleEnergy(particlegun, 10GeV)
#SetParticleByName(particlegun, "pi+")

#fig = Figure(resolution=(1280, 720))
#s = LScene(fig[1,1])
