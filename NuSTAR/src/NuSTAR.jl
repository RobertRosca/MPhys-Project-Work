__precompile__()

module NuSTAR

using FTPClient
using DataFrames
using CSV
using LightXML

include("ObsLog.jl")
include("ObsXML.jl")

export ObsLog, ObsGenerateXML, ObsGenerateXMLBatch

end
