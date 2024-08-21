function data_OE = ConvertOESampleToTime(data_OE,checkSamples,bypassSampleMatch)

% Converts Open Ephys data from samples into seconds based on the sampling
% rate listed in the header and/or that the data come in as integers. These
% checks can be bypassed if requested. If we are already have a sampling
% rate in our timestamps that matches (within 5%) of the listed header
% sample rate, we can bypass the conversion.

% GWDiehl July 2024

if nargin < 2 || isempty(checkSamples)
    checkSamples = 1;
end
if nargin < 3
    bypassSampleMatch = 1;
end

if checkSamples
    % Verify that the time stamps are in sec (not frames)

    % Note, this check of sample rate will only work for continuous data, not for event times.
    % Those will still catch if they have remained as integers, but if you
    % have already converted the samples into a double you have to manually
    % bipass this check.
    timestamps = double(data_OE.Timestamps);
    ts_rate = 1/median(diff(timestamps));

    if ts_rate == 1 || isa(data_OE.Timestamps,'integer')
        % All good to continue, we have integer samples that will convert
        % to seconds

    elseif bypassSampleMatch && (ts_rate < data_OE.Header.sample_rate*1.05 && ts_rate > data_OE.Header.sample_rate*.95) % We are already in seconds, and they match the reported sample rate. Bail out of the function
        % Note that this only works is we are dealing with continuous data.
        % Data are already in seconds matching the sample rate. Bail out
        % of the function
        return
        
    else 
        % Verify that we still want to do the conversion even though there
        % are no assurances it is warrented. If you dont want to be
        % prompted here, bypass the check.
        convertData = questdlg('Your "timestamps" do not seem to be in samples. Do you still want to continue?','Continue?','No','Yes','No');
        if strcmp(convertData,'No')
            fprintf('Not converting your data to timestamps. Returning as is. \n')
            return
        end
    end
end

data_OE.Timestamps = double(data_OE.Timestamps) / data_OE.Header.sample_rate; % Convert to seconds as a double

% Convert any metadata (Crossing Detector) to seconds if it exists
if isfield(data_OE,'MetaData')
    temp = arrayfun(@(x) double(x.Crossing_Point)/data_OE.Header.sample_rate,data_OE.MetaData,'un',0);
    [data_OE.MetaData.Crossing_Point] = temp{:}; % I guess this is how you deal these into this formating of strucutre. OOF
end