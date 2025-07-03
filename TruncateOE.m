function data_OE = TruncateOE(data_OE,timeRange)

% Takes a set of OE data (any form) and restricts the entries to only those
% within a selected time range. This requires that the OE data has been
% converted into seconds (use ConvertOESampleToTime as needed) and will
% restrict the data to only the samples/events within the provided time
% range. 
%
% Time Range/time from start/end should be calculated outside of this
% function as some OE data is continuous and others are event based so
% don't follow the same time conventions.

% CURRENTLY NOT KNOWN IF THIS HANDLES SPIKES DATA CORRECTLY

% GWDiehl July 2025

inputTimes = data_OE.Timestamps;
nTimes = length(inputTimes);

if isnan(timeRange(1))
    timeRange(1) = -inf;
end
if isnan(timeRange(2))
    timeRange(2) = inf;
end

validTimes = inputTimes >= timeRange(1) & inputTimes <= timeRange(2);

entries = fieldnames(data_OE);

for iX = 1:length(entries)
    if strcmp(entries{iX},'Header')
        continue
    end

    % Time is in axis 2 (not 1); Continuous Data
    if size(data_OE.(entries{iX}),2)==nTimes & size(data_OE.(entries{iX}),1)==data_OE.Header.num_channels
        data_OE.(entries{iX}) = data_OE.(entries{iX})(:,validTimes);

        % Time is in axis 1; Full Timestamps or Events Data
    else
        data_OE.(entries{iX}) = data_OE.(entries{iX})(validTimes,:);
    end

end