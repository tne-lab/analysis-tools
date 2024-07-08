function data_OE = DownsampleOE(data_OE,srate,params)


% Downsamples continuous OE data from the original sample rate into a lower
% sample rate using the decemate function.
% 
% The params field can be entered as a cell array that will be dumped into
% the decimate function to change any of the default params.

% GWDiehl July 2024


if nargin < 3
    params = [];
end

ds_factor = data_OE.Header.sample_rate / srate;

if ds_factor <= 1
    fprinf('Your data is already below the requested sample rate. Returning as is. \n')
    return
end
nChan = size(data_OE.Data,1);

% Downsample the timestamps 
data_OE.Timestamps = downsample(data_OE.Timestamps,ds_factor);

newArray = nan(nChan,length(data_OE.Timestamps));

% Doing this channel by channel will be less efficent but will protect
% against memory issues with large recordings.
for iC = 1:nChan
    if isempty(params)
        newArray(iC,:) = decimate(data_OE.Data(iC,:),ds_factor);
    else
        newArray(iC,:) = decimate(data_OE.Data(iC,:),ds_factor,params{:});
    end
end

data_OE.Data = newArray;


% Log the new sample rate and any decimate params
data_OE.Header.sample_rate = srate;
data_OE.Header.DecimateParams = params;

