using Geant4
using Geant4.SystemOfUnits
using GLMakie, Rotations, IGLWrap_jll # to force loading G4Vis extension

include(joinpath(@__DIR__, "Parameters.jl"))
include(joinpath(@__DIR__, "Geometry.jl"))
include(joinpath(@__DIR__, "VisAttributes.jl"))

#---Detector read from GDML------------------------------------------------------------------------
const detGDML = "$(@__DIR__)/../TileTB_2B1EB_nobeamline.gdml"
detector = G4JLDetectorGDML(detGDML, validate_schema=false,
                                  init_method=initVisAttributes)

#---Particle Gun initialization--------------------------------------------------------------------
const primaryAngle = 76*deg  # set TB angle as on ATLAS reference paper
particlegun = G4JLGunGenerator(particle = "pi+", 
                               energy = 18GeV, 
                               direction = G4ThreeVector(sin(primaryAngle),0,cos(primaryAngle)), 
                               position = G4ThreeVector(2298.,0.,0.))
#---Event Display----------------------------------------------------------------------------------
evtdisplay = G4JLEventDisplay(joinpath(@__DIR__, "../VisSettings.jl"))

#---Create the Application-------------------------------------------------------------------------
app = G4JLApplication(detector     = detector,                  # detector defined with a GDML file
                      generator    = particlegun,               # primary generator to instantiate
                      physics_type = FTFP_BERT,                 # what physics list to instantiate
                      evtdisplay   = evtdisplay                 # event display
                     )

configure(app)
initialize(app)
display(evtdisplay.figure)

#---Event Display is anow ready display events---------------------------------------------------
beamOn(app, 1)

