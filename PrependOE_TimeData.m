function OE_Data = PrependOE_TimeData(OE_Data,fullTimestamps)

% Takes in a set of OE_Data and adds additional zeros at the front end in
% order to account for intial lost timestamps. This behavior comes about
% because later record nodes have an initial lag in data collection
% reletive to the first record node. After things start collecting
% everything is working in the same timestamps (I AM PRETTY SURE THAT THIS
% IS TRUE BUT IF THIS ASSUMPTION FALLS APART THERE ARE ***BIG BIG BIG***
% PROBLEMS).
%
% This will take the initial timestamp of the input OE data and find the
% matched index of the full timestamp data. It will then backfill the
% timestamps accordingly and add in zeros for the respective data. Zeros
% are used to prefect any propigation of NaNs. This should be a overall
% very small amount of data (<10ms) so should not impact much.
% 
% NOTE, the fuction will error out if there is not perfect correspondence
% within the timestamps as this would be indicative of a major problem.

% GWDiehl Aug 2024

firstTime = OE_Data.Timestamps(1);

[~,firstIdx] = max(fullTimestamps==firstTime);

if isempty(firstIdx) || ~isequal(OE_Data.Timestamps,fullTimestamps(firstIdx:end))
    error('Your timestamps sequences do not match. You have a major problem')
end

% Populate the full timestamps and backfill the data with zeros
OE_Data.Timestamps = fullTimestamps;
nChan = size(OE_Data.Data,1);
OE_Data.Data = cat(2,zeros(nChan,firstIdx-1),OE_Data.Data);
