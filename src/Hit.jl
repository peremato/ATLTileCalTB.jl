
using StaticArrays
using .ATLTileCalTBConstants
using .ATLTileCalTBGeometry

const FSA = SizedVector{frames,Float64}

#---ATLTileCalTBHit--------------------------------------------------------------------------------
mutable struct ATLTileCalTBHit
    fEdep::Float64
    # Vectors containing the binned signal
    fSdepUp::FSA
    fSdepDown::FSA
    ATLTileCalTBHit() = new(0., zeros(FSA), zeros(FSA))
end

function clean!(h::ATLTileCalTBHit)
    h.fEdep = 0.
    h.fSdepUp = zeros(FSA)
    h.fSdepDown = zeros(FSA)
end

function Base.setindex!(array::FSA, data::Float64, time::Float64)
    if time < frame_time_window
        indx = ceil(Int, time/frame_bin_time)
        array[indx] = data
    else
        throw("Time time is above the total time window")
    end
end

const ATLTileCalTBHits = SVector{numberOfCells, ATLTileCalTBHit}
