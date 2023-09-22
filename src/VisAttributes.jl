    #---Set visualization attributes---------------------------------------------------------------
    function initVisAttributes(world)
        # Create vis attributes
        # 
        CALOVisAttr = G4VisAttributes()         # CALO::CALO invisible
        SetVisibility(CALOVisAttr, false)

        TileTBEnvVisAttr = G4VisAttributes()    # Tile::TileTBEnv invisible
        SetVisibility(TileTBEnvVisAttr, false )

        # TileVisAttr = G4VisAttributes()       # Tile::Scintillator blue
        # SetForceSolid(TileVisAttr, true)
        # SetColor(TileVisAttr, G4Colour!Blue() )
        # SetDaughtersInvisible(TileVisAttr, true)

        FingerVisAttr = G4VisAttributes()       # Tile::Finger grey
        SetForceSolid(FingerVisAttr,  true)     # Tile::EFinger grey
        SetColor(FingerVisAttr, G4Colour!Grey() )    # Tile::GirderMother grey
        SetDaughtersInvisible(FingerVisAttr, true)

        AbsorberVisAttr = G4VisAttributes()     # Tile::Absorber magenta
        SetForceSolid(AbsorberVisAttr,true )
        SetColor(AbsorberVisAttr, G4Colour!Cyan())
        SetDaughtersInvisible(AbsorberVisAttr, true)
    
        # Assign vis attributes
        LVStore = G4LogicalVolumeStore!GetInstance()
        for vol in LVStore
            (vol |> GetName |> String) == "CALO::CALO"  &&  SetVisAttributes( vol, CALOVisAttr)
            (vol |> GetName |> String) == "Tile::TileTBEnv"  &&  SetVisAttributes(vol, TileTBEnvVisAttr)
            # i(vol |> GetName |> String) =="Tile::Scintillator"  &&  SetVisAttributes(vol, TileVisAttr)
            (vol |> GetName |> String) == "Tile::Finger"  &&  SetVisAttributes(vol,  FingerVisAttr)
            (vol |> GetName |> String) == "Tile::EFinger"  && SetVisAttributes(vol,  FingerVisAttr)
            (vol |> GetName |> String) == "Tile::GirderMother"  && SetVisAttributes(vol,  FingerVisAttr)
            (vol |> GetName |> String) == "Tile::Absorber"  &&  SetVisAttributes(vol, AbsorberVisAttr)
        end
    end