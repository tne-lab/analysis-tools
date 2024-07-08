function data_OE = ConvertOESampleToTime(data_OE,checkSamples)

% Converts Open Ephys data from samples into seconds based on the sampling
% rate listed in the header and/or that the data come in as integers. These
% checks can be bypassed if requested.

% GWDiehl July 2024

if nargin < 2
    checkSamples = 1;
end

if checkSamples
    % Verify that the time stamps are in sec (not frames)

    % Note, this check of sample rate will only work for continuous data, not for event times.
    % Those will still catch if they have remained as integers, but if you
    % have already converted the samples into a double you have to manually
    % bipass this check.
    timestamps = double(data_OE.Timestamps);
    ts_rate = median(diff(timestamps));

    if ts_rate == 1 || isa(data_OE.Timestamps,'integer')
        % All good, we have integer samples
        
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