function data_OE = OE_RemoveDCOffset(data_OE)

% Takes Open Ephys data and removes and recording wide DC offset. In theory
% this should be neglegable but in some cases it seems like certain
% hardware introduces a DC offset.

% GWDiehl May 2025

nChan = size(data_OE.Data,1);

% Doing this channel by channel will be less efficent but will protect
% against memory issues with large recordings.
for iC = 1:nChan
    data_OE.Data(iC,:) = data_OE.Data(iC,:) - nanmedian(data_OE.Data(iC,:));
end
