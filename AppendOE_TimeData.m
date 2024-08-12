function OE_Data = AppendOE_TimeData(OE_Data,fullTimestamps)

% This function mirrors the functionality of the PrependOE_TimeData
% function. Currently I don't know of any cases where this is needed, but
% seemed a good thing to have.

% GWDiehl Aug 2024

lastTime = OE_Data.Timestamps(end);

[~,lastIdx] = max(fullTimestamps==lastTime);


if isempty(firstIdx) || ~isequal(OE_Data.Timestamps,fullTimestamps(1:lastIdx))
    error('Your timestamps sequences do not match. You have a major problem')
end

% Populate the full timestamps and backfill the data with zeros
OE_Data.Timestamps = fullTimestamps;
nSamples = length(fullTimestamps);
nChan = size(OE_Data.Data,1);
OE_Data.Data = cat(2,OE_Data.Data,zeros(nChan,nSamples - lastIdx));
