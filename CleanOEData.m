function data_OE = CleanOEData(data_OE,toDo,srate,OE_Version)

% Overall pre-processing to clean up open ephys continuous data and get it
% into a standardized and read to go state. Note that this should only
% really be used for continuous data. 
% 
% Event data should be handeled independently as downsampling and volt
% converts are inappropriate and the time conversion leverages continuous
% sample assumptions in its checks.

% GWDiehl July 2024

% Defaults
if nargin < 2 || isempty(toDo)
    toDo = {'Time' 'Volts' 'Downsample'};
end
if nargin < 3 || isempty(srate)
    srate = 1000; % New sample rate
end
if nargin < 4
    OE_Version = [];
end

if ismember('Time',toDo)
    % If we are coming from Version 5, convert to time. If we dont know the
    % version or want to be safe, check the step interval

    ts_rate = median(diff(data_OE.Timestamps));

    if any(OE_Version == 5) || ts_rate == 1
        if iscell(data_OE)
            data_OE = cellfun(@(x) ConvertOESampleToTime(x),data_OE,'un',0);
        else
            data_OE = ConvertOESampleToTime(data_OE);
        end
    end
end

% Convert everything to volts
if ismember('Volts',toDo)
    if iscell(data_OE)
        data_OE = cellfun(@(x) ConvertOEBitsToVolts(x),data_OE,'un',0);
    else
        data_OE = ConvertOEBitsToVolts(data_OE);
    end
end

% Downsample the continuous data
if ismember('Downsample',toDo)
    if iscell(data_OE)
        data_OE = cellfun(@(x) DownsampleOE(x,srate),data_OE,'un',0);
    else
        data_OE = DownsampleOE(data_OE,srate);
    end
end