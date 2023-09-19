using Revise
using Geant4
using Geant4.SystemOfUnits

using GLMakie, Rotations, IGLWrap_jll  # to force loading G4Vis extension

#---Detector read from GDML------------------------------------------------------------------------
const detGDML = "$(@__DIR__)/../TileTB_2B1EB_nobeamline.gdml"

#---Particle Gun initialization--------------------------------------------------------------------
particlegun = G4JLGunGenerator(particle = "e-", 
                               energy = 1GeV, 
                               direction = G4ThreeVector(1,0,0), 
                               position = G4ThreeVector(0,0,0))  # temporary position, will update once the detector is constructed

#---Create the Application-------------------------------------------------------------------------
app = G4JLApplication(detector = G4JLDetectorGDML(detGDML),       # detector defined with a GDML file
                      generator    = particlegun,                 # primary generator to instantiate
                      physics_type = FTFP_BERT,                   # what physics list to instantiate
                      #----Actions--------------------------------
                      #stepaction_method = stepaction,             # step action method
                      #pretrackaction_method = pretrackaction,     # pre-tracking action
                      #posttrackaction_method = posttrackaction,   # post-tracking action
                      #beginrunaction_method=beginrun,             # begin-run action (initialize counters and histograms)
                      #endrunaction_method=endrun,                 # end-run action (print summary)               
                      #begineventaction_method=beginevent,         # begin-event action (initialize per-event data)
                      #endeventaction_method=endevent              # end-event action (fill histogram per event data)
                      )
              
configure(app)
initialize(app)

world = GetWorldVolume()
draw(world, maxlevel=5)            