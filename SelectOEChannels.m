function data_OE = SelectOEChannels(data_OE,chanType,chanNum)

% Subsample your Open Ephys data structure down into a subset of prefered
% channels. There are multiple ways of doing this currently implemented.
% These are:
%
% Data by Name: Find the data channel by its given number/name
% Data by Idx: Find the data by total count (only counts data)
%
% IO by Name: Find the IO board channel by its given number/name
% IO by Idx: Find the IO channel by total count (only counts IO)
%
% Raw Idx: Selects the raw indx count ignoring all other factors
%
% Note that any duplicates will only be included once so redundant
% selection of channels of interest is fine.

% GWDiehl July 2024


dataPrefix = {'CH' 'AI'}; % Possible prefixes for raw data signals
IOPrefix = {'ADC'}; % Possible prefixes for IO board inputs

selectChan = [];
nTypes = length(chanType);

% Grab all of the channel names
allNames = arrayfun(@(x) x.channel_name,data_OE.Header.channels,'un',0);

for iT = 1:nTypes
    switch chanType{iT}
        % Go through and find the appropraite channels for each grouping of
        % data
        case {'DataNumber'}
            for iC = 1:length(chanNum{iT})
                candidateChan = find(any(cell2mat(cellfun(@(x) ismember(allNames,[x,num2str(chanNum{iT}(iC))]),dataPrefix,'un',0)),2));
                assert(~isempty(candidateChan),'One of your requested channels does not exist: %s - %d',chanType{iT},chanNum{iT}(iC))

                selectChan = [selectChan,candidateChan];
            end
        case {'DataName'}
            for iC = 1:length(chanNum{iT})
                candidateChan = find(any(cell2mat(cellfun(@(x) ismember(allNames,[x,chanNum{iT}{iC}]),dataPrefix,'un',0)),2));
                assert(~isempty(candidateChan),'One of your requested channels does not exist: %s - %d',chanType{iT},chanNum{iT}{iC})

                selectChan = [selectChan,candidateChan];
            end
        case {'DataIdx'}
            candidateChan = find(cellfun(@(x) any(cellfun(@(y) contains(x,y),dataPrefix)),allNames))';
            assert(length(candidateChan) >= max(chanNum{iT}), 'One of your requested channels does not exist')

            selectChan = [selectChan,candidateChan(chanNum{iT})];


        case {'IONumber'}
            for iC = 1:length(chanNum{iT})
                candidateChan = find(any(cell2mat(cellfun(@(x) ismember(allNames,[x,num2str(chanNum{iT}(iC))]),IOPrefix,'un',0)),2));
                assert(~isempty(candidateChan),'One of your requested channels does not exist: %s - %d',chanType{iT},chanNum{iT}(iC))

                selectChan = [selectChan,candidateChan];
            end
        case {'IOName'}
            for iC = 1:length(chanNum{iT})
                candidateChan = find(any(cell2mat(cellfun(@(x) ismember(allNames,[x,chanNum{iT}{iC}]),IOPrefix,'un',0)),2));
                assert(~isempty(candidateChan),'One of your requested channels does not exist: %s - %d',chanType{iT},chanNum{iT}{iC})

                selectChan = [selectChan,candidateChan];
            end
        case {'IOIdx'}
            candidateChan = find(cellfun(@(x) any(cellfun(@(y) contains(x,y),IOPrefix)),allNames))';
            assert(length(candidateChan) <= max(chanNum{iT}), 'One of your requested channels does not exist')

            selectChan = [selectChan,candidateChan(chanNum{iT})];

        case {'RawIdx'}
            selectChan = [selectChan,chanNum{iT}];

    end
end

% Boil down to the unique set of channels and extract out the data of
% interest
selectChan = unique(selectChan);

data_OE.Header.channels = data_OE.Header.channels(selectChan);
data_OE.Data = data_OE.Data(selectChan,:);
% Note that the Channel Number in the header is remaining unchanged from
% the original total of data.

