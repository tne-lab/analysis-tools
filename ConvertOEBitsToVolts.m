function data_OE = ConvertOEBitsToVolts(data_OE)

% Converts Open Ephys voltage data from bits into microvolts/volts based on
% the header info.

% GWDiehl July 2024

nChan = size(data_OE.Data,1);

% Doing this channel by channel will be less efficent but will protect
% against memory issues with large recordings.
for iC = 1:nChan
    data_OE.Data(iC,:) = data_OE.Data(iC,:) .* data_OE.Header.channels(iC).bit_volts;

    % Update the bit_volts conversion
    data_OE.Header.channels(iC).bit_volts = 1;
end
