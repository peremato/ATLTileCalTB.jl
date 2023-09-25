using StaticArrays

using .ATLTileCalTBConstants
using .ATLTileCalTBGeometry

#---ATLTileCalTBHit--------------------------------------------------------------------------------
mutable struct ATLTileCalTBHit
    fEdep::Float64
    # Vectors containing the binned signal
    fSdepUp::Vector{Float64}
    fSdepDown::Vector{Float64}
    ATLTileCalTBHit() = new(0., zeros(frames), zeros(frames))
end

function clean!(h::ATLTileCalTBHit)
    h.fEdep = 0.
    fill!(h.fSdepUp, 0.)
    fill!(h.fSdepDown, 0.)
end

function Base.setindex!(array::Vector{Float64}, data::Float64, time::Float64)
    if time < frame_time_window
        indx = ceil(Int, time/frame_bin_time)
        array[indx] = data
    else
        throw("Time time is above the total time window")
    end
end

const ATLTileCalTBHits = SVector{numberOfCells, ATLTileCalTBHit}
