using Revise
using Geant4
using Geant4.SystemOfUnits

#using GLMakie, Rotations, IGLWrap_jll  # to force loading G4Vis extension
using FHist

include(joinpath(@__DIR__, "Parameters.jl"))
include(joinpath(@__DIR__, "Geometry.jl"))
include(joinpath(@__DIR__, "Hit.jl"))
include(joinpath(@__DIR__, "UserActions.jl"))
include(joinpath(@__DIR__, "SensDet.jl"))

#---Detector read from GDML------------------------------------------------------------------------
const detGDML = "$(@__DIR__)/../TileTB_2B1EB_nobeamline.gdml"

#---Particle Gun initialization--------------------------------------------------------------------
primaryAngle = 76*deg  # set TB angle as on ATLAS reference paper
particlegun = G4JLGunGenerator(particle = "pi-", 
                               energy = 1GeV, 
                               direction = G4ThreeVector(sin(primaryAngle),0,cos(primaryAngle)), 
                               position = G4ThreeVector(2298.,0.,0.))

#---Create SD instance-----------------------------------------------------------------------------
calo_SD = G4JLSensitiveDetector("Calo_SD", ATLTileCalTBSDData();         # SD name an associated data are mandatory
                                    processhits_method=sd_processHits!,  # process hist method (also mandatory)
                                    initialize_method=sd_initialize!,    # intialize method
                                    endofevent_method=sd_endOfEvent!)    # end of event method
#-------------------------------------------------------------------------------------------------

#---Create the Application-------------------------------------------------------------------------
app = G4JLApplication(detector = G4JLDetectorGDML(detGDML),       # detector defined with a GDML file
                      simdata      = ATLTileCalTBSimData(),       # simlation data structure
                      generator    = particlegun,                 # primary generator to instantiate
                      physics_type = FTFP_BERT,                   # what physics list to instantiate
                      #----Actions--------------------------------
                      stepaction_method = stepping!,                  # step action method
                      #pretrackaction_method = pretrackaction,        # pre-tracking action
                      #posttrackaction_method = posttrackaction,      # post-tracking action
                      beginrunaction_method=beginrun!,                # begin-run action (initialize counters and histograms)
                      endrunaction_method=endrun!,                    # end-run action (print summary)               
                      begineventaction_method=beginevent!,            # begin-event action (initialize per-event data)
                      endeventaction_method=endevent!,                # end-event action (fill histogram per event data)
                      sdetectors = ["Tile::Scintillator+" => calo_SD] # mapping of LVs to SDs (+ means multiple LVs with same name)
                     )
              
configure(app)
initialize(app)

#---Draw the detector------------------------------------------------------------------------------
function draw_detector()
    fig = Figure(resolution=(1280, 720))
    s = LScene(fig[1,1])
    set_theme!(backgroundcolor = :black)
    world = GetWorldVolume()
    draw!(s, world, maxlevel=6)
    display(fig)
    return s
end

#draw_detector()

beamOn(app, 1)