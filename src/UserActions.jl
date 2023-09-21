using StaticArrays

using .ATLTileCalTBConstants
using .ATLTileCalTBGeometry

const nAuxData = 2      # 1->Leakage, 2->Energy Deposited in Calo
const Hist1D64 = Hist1D{Float64, Tuple{StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}, Int64}}}


#---ATLTileCalTBSimData----------------------------------------------------------------------------
mutable struct ATLTileCalTBSimData <: G4JLSimulationData
    #---Event data
    fAux::SizedVector{nAuxData, Float64}
    fEdepVector::SizedVector{numberOfCells, Float64}
    fSdepVector::SizedVector{numberOfCells, Float64}
    #---Run data
    sdepSumHisto::Hist1D64
    edepSumHisto::Hist1D64
    ATLTileCalTBSimData() = new(zeros(nAuxData), 
                                zeros(numberOfCells),
                                zeros(numberOfCells))
end
function add!(x::ATLTileCalTBSimData, y::ATLTileCalTBSimData)
    x.sdepSumHisto += y.sdepSumHisto
    x.edepSumHisto += y.edepSumHisto
end
#--------------------------------------------------------------------------------------------------
#---User Actions-----------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------

#---Begin Run Action-------------------------------------------------------------------------------
function beginrun!(run::G4Run, app::G4JLApplication)::Nothing
    data = getSIMdata(app)
    #---init run histograms
    data.edepSumHisto = Hist1D(;bins=200.:5.:500.)
    data.sdepSumHisto = Hist1D(;bins=200.:5.:500.)
    nothing
end
#---End Run Action---------------------------------------------------------------------------------
function endrun!(run::G4Run, app::G4JLApplication)::Nothing
    #---end run action is called for each workwer thread and the master one
    if G4Threading!G4GetThreadId() == -1   
        data = app.simdata[1]
        #---This is the master thread, so we need to add all the simuation results-----------------
        for d in app.simdata[2:end]
            add!(data, d)
        end
        nEvt = GetNumberOfEvent(run)
        G4JL_println("Run ended with a total of $nEvt events") 
    end
end

#---Begin Event Action-----------------------------------------------------------------------------
function beginevent!(evt::G4Event, app::G4JLApplication)::Nothing
    data = getSIMdata(app)
    fill!(data.fAux, 0.)
    fill!(data.fEdepVector, 0.)
    fill!(data.fSdepVector, 0.)
    return
end

#---End Event Action-------------------------------------------------------------------------------
function endevent!(evt::G4Event, app::G4JLApplication)
    # Function to convolute signal for PMT response
    # From https://gitlab.cern.ch/allpix-squared/allpix-squared/-/blob/86fe21ad37d353e36a509a0827562ab7fadd5104/src/modules/CSADigitizer/CSADigitizerModule.cpp#L271-L283
    function convolutePMT(sdep::FSA)
        pmt_response_size = length(pmt_response)
        outvec = zeros(FSA)
        for k in 1:frames
            outsum = 0.
            jmax = k > pmt_response_size ? pmt_response_size : k
            for j in 1:jmax
                outsum += sdep[k - j + 1] * pmt_response[j]
            end
            outvec[k] = outsum
        end
        return outvec
    end
    # Function to get sdep from hit
    function getSdep(hit::ATLTileCalTBHit)::Float64
        # PMT response
        sdep_up_v = convolutePMT(hit.fSdepUp)
        sdep_down_v = convolutePMT(hit.fSdepDown)

        # Use maximum as signal
        sdep_up = maximum(sdep_up_v)
        sdep_down = maximum(sdep_down_v)

        # Apply electronic noise
        #sdep_up += G4RandGauss::shoot(0., ATLTileCalTBConstants::signal_noise_sigma);
        #sdep_down += G4RandGauss::shoot(0., ATLTileCalTBConstants::signal_noise_sigma);
        sdep_up += randn()*signal_noise_sigma
        sdep_down += randn()*signal_noise_sigma

        # Return sum if signal is larger than 2 * noise
        sdep_sum = sdep_up + sdep_down
        return sdep_sum > 2 * signal_noise_sigma ? sdep_sum : 0.
    end
 
    data   = getSIMdata(app)
    sddata = getSDdata(app, "Calo_SD")                   # Get the hits from sensitive detector data

    for n in 1:numberOfCells
        data.fEdepVector[n] = sddata.hitsCollection[n].fEdep
        data.fSdepVector[n] = getSdep(sddata.hitsCollection[n])
    end

    #  Add sums to Ntuple
    push!(data.edepSumHisto, sum(data.fEdepVector))
    push!(data.sdepSumHisto, sum(data.fSdepVector))
    return
end

#---Stepping Action-------------------------------------------------------------------------------
function stepping!(step::G4Step, app::G4JLApplication)::Nothing
    data = getSIMdata(app)

    track = step |> GetTrack

    # Collect out of world leakage
    if track |> GetNextVolume == C_NULL
        data.fAux[1] += track |> GetKineticEnergy 
    end

    # Collect calo energy deposition (everything but what goes into CALO::CALO and Barrel) 
    # Warning: not exact measurement

    #volname = track |> GetTouchableHandle |> GetVolume |> GetName |> String
    volname = step |> GetPreStepPoint |> GetTouchable |> GetVolume |> GetName |> String
    if volname != "CALO::CALO" || volname != "Barrel"
        data.fAux[1] += step |> GetTotalEnergyDeposit 
    end
    return
end
