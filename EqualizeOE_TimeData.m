function OE_Data = EqualizeOE_TimeData(OE_Data,templateTime)

% Takes in a set of OE_Data and adds additional zeros at the front end in
% order to account for intial lost timestamps. Or removes data in the event
% of excess timestamps.This behavior comes about because later record nodes
% have an initial lag in data collection reletive to the first record node.
% Or sometimes the later record nodes start before the early record nodes.
% After things start collecting everything is working in the same
% timestamps (I AM PRETTY SURE THAT THIS IS TRUE BUT IF THIS ASSUMPTION
% FALLS APART THERE ARE ***BIG BIG BIG*** PROBLEMS).
%
% This will look at both the front and the back end of timestamps to verify
% that everything matches an input template time. Things that are too long
% will be dropped, things that are too short will be filled with zeros.Zeros
% are used to prefect any propigation of NaNs. This should be a overall
% very small amount of data (<10ms) so should not impact much.
% 
% 
% NOTE, the fuction will error out if there is not perfect correspondence
% within the timestamps as this would be indicative of a major problem.

% GWDiehl Aug 2024


%% Look at the start of the time

[~,dataLag] = max(templateTime==OE_Data.Timestamps(1)); % Template time existed before data 
[~,templateLag] = max(OE_Data.Timestamps==templateTime(1)); % Data time existed before template

assert(~isempty(dataLag) & ~isempty(templateLag), 'Your timestamps sequences do not match. You have a major problem')

if templateLag > dataLag 
    % Your current data is long, remove the excess
    OE_Data.Timestamps = OE_Data.Timestamps(templateLag:end);
    OE_Data.Data = OE_Data.Data(:,templateLag:end);

elseif templateLag < dataLag 
    % Your current data is short, backfill with zeros
    OE_Data.Timestamps = cat(1,templateTime(1:dataLag-1),OE_Data.Timestamps);
    nChan = size(OE_Data.Data,1);
    OE_Data.Data = cat(2,zeros(nChan,dataLag-1),OE_Data.Data);

else 
    % Starts are equal, move along.
end


%% Look at the end of time

offset = length(templateTime) - length(OE_Data.Timestamps);

if offset < 0
    % Your current data is long, remove the excess
    OE_Data.Timestamps = OE_Data.Timestamps(1:length(templateTime));
    OE_Data.Data = OE_Data.Data(:,1:length(templateTime));

elseif offset > 0
    % Your current data is short, backfill with zeros
    
    OE_Data.Timestamps = cat(1,OE_Data.Timestamps,templateTime(length(OE_Data.Timestamps)+1:end));
    nChan = size(OE_Data.Data,1);
    OE_Data.Data = cat(2,OE_Data.Data,zeros(nChan,offset));
else 
    % Ends are equal, move along.
end

%% Verify that all of the timestamps now match

assert(isequal(OE_Data.Timestamps,templateTime),'Your timestamps sequences do not match. You have a major problem')

