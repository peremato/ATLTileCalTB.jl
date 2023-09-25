using StaticArrays

using .ATLTileCalTBConstants
using .ATLTileCalTBGeometry

const nAuxData = 2      # 1->Leakage, 2->Energy Deposited in Calo
const Hist1D64 = Hist1D{Float64, Tuple{StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}, Int64}}}


#---ATLTileCalTBSimData----------------------------------------------------------------------------
mutable struct ATLTileCalTBSimData <: G4JLSimulationData
    #---Event data
    fLeak::Float64
    fEcal::Float64
    fEdepVector::Vector{Float64}
    fSdepVector::Vector{Float64}
    #---Run data (filled every event by the endevent action)
    eleak::Hist1D64
    ecal::Hist1D64
    sdepSum::Hist1D64
    edepSum::Hist1D64
    sdep::Hist1D64
    edep::Hist1D64
    pdgid::Hist1D64
    ebeam::Hist1D64
    ATLTileCalTBSimData() = new(0.,0., 
                                zeros(numberOfCells),
                                zeros(numberOfCells),
                                Hist1D(;bins=0.:400.:20000.), 
                                Hist1D(;bins=0.:400.:20000.), 
                                Hist1D(;bins=0.:2.:100.),
                                Hist1D(;bins=0.:20.:1000.),
                                Hist1D(;bins=0.:1.:50.), 
                                Hist1D(;bins=0.:1.:50.), 
                                Hist1D(;bins=100.:40.:300.),
                                Hist1D(;bins=0.:4000.:20000.))
end
function add!(x::ATLTileCalTBSimData, y::ATLTileCalTBSimData)
    x.eleak += y.eleak
    x.ecal += y.ecal
    x.sdepSum += y.sdepSum
    x.edepSum += y.edepSum
    x.sdep += y.sdep
    x.edep += y.edep
    x.pdgid += y.pdgid
    x.ebeam += y.ebeam
end
#--------------------------------------------------------------------------------------------------
#---User Actions-----------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------

#---Begin Run Action-------------------------------------------------------------------------------
function beginrun!(run::G4Run, app::G4JLApplication)::Nothing
    data = getSIMdata(app)
    runmgr = G4RunManager!GetRunManager()
    SetPrintProgress(runmgr,100) 
    #---init run histograms
    empty!(data.eleak)
    empty!(data.ecal)
    empty!(data.sdepSum)
    empty!(data.edepSum)
    empty!(data.sdep)
    empty!(data.edep)
    empty!(data.pdgid)
    empty!(data.ebeam)
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
    data.fLeak = 0.
    data.fEcal = 0.
    fill!(data.fEdepVector, 0.)
    fill!(data.fSdepVector, 0.)
    return
end

#---End Event Action-------------------------------------------------------------------------------
const sdep_up_v = zeros(frames)
const sdep_down_v = zeros(frames)

function endevent!(evt::G4Event, app::G4JLApplication)
    # Function to convolute signal for PMT response
    # From https://gitlab.cern.ch/allpix-squared/allpix-squared/-/blob/86fe21ad37d353e36a509a0827562ab7fadd5104/src/modules/CSADigitizer/CSADigitizerModule.cpp#L271-L283
    function convolutePMT!(outvec::Vector{Float64}, sdep::Vector{Float64})
        pmt_response_size = length(pmt_response)
        for k in 1:frames
            outsum = 0.
            jmax = k > pmt_response_size ? pmt_response_size : k
            for j in 1:jmax
                outsum += sdep[k - j + 1] * pmt_response[j]
            end
            outvec[k] = outsum
        end
        return
    end
    # Function to get sdep from hit
    function getSdep(hit::ATLTileCalTBHit)::Float64
        # PMT response
        convolutePMT!(sdep_up_v, hit.fSdepUp)
        convolutePMT!(sdep_down_v, hit.fSdepDown)

        # Use maximum as signal
        sdep_up = maximum(sdep_up_v)
        sdep_down = maximum(sdep_down_v)

        # Apply electronic noise
        #sdep_up += G4RandGauss::shoot(0., ATLTileCalTBConstants::signal_noise_sigma);
        #sdep_down += G4RandGauss::shoot(0., ATLTileCalTBConstants::signal_noise_sigma);
        sdep_up += randn() * signal_noise_sigma
        sdep_down += randn() * signal_noise_sigma

        # Return sum if signal is larger than 2 * noise
        sdep_sum = sdep_up + sdep_down
        return sdep_sum > 2 * signal_noise_sigma ? sdep_sum : 0.
    end
 
    data   = getSIMdata(app)
    sddata = getSDdata(app, "Calo_SD")                   # Get the hits from sensitive detector data
    gun = app.generator.data.gun

    for n in 1:numberOfCells
        data.fEdepVector[n] = sddata.hitsCollection[n].fEdep
        data.fSdepVector[n] = getSdep(sddata.hitsCollection[n])
    end

    #  Add sums to Ntuple
    push!(data.eleak, data.fLeak)
    push!(data.ecal, data.fEcal)
    push!(data.edepSum, sum(data.fEdepVector))
    push!(data.sdepSum, sum(data.fSdepVector))
    push!.(data.edep, data.fEdepVector)
    push!.(data.sdep, data.fSdepVector)
    push!(data.pdgid, gun |> GetParticleDefinition |> GetPDGEncoding)
    push!(data.ebeam, gun |> GetParticleEnergy)
    return
end

#---Stepping Action-------------------------------------------------------------------------------
function stepping!(step::G4Step, app::G4JLApplication)::Nothing
    data = getSIMdata(app)

    track = step |> GetTrack

    # Collect out of world leakage
    if track |> GetNextVolume == C_NULL
        data.fLeak += track |> GetKineticEnergy 
    end

    # Collect calo energy deposition (everything but what goes into CALO::CALO and Barrel) 
    # Warning: not exact measurement

    #volname = track |> GetTouchableHandle |> GetVolume |> GetName |> String
    volname = step |> GetPreStepPoint |> GetTouchable |> GetVolume |> GetName |> String
    if volname != "CALO::CALO" || volname != "Barrel"
        data.fEcal += step |> GetTotalEnergyDeposit 
    end
    return
end
