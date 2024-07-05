function [fullD,fileNames,OE_Version] = fullData_load_open_ephys_binary(jsonFile,type,selectNames,varargin)



if (exist('readNPY.m','file') == 0)
    error('OpenEphys:loadBinary:npyLibraryNotfound','readNPY not found. Please be sure that npy-matlab is accessible');
end

if (exist('readNPYheader.m','file') == 0)
    error('OpenEphys:loadBinary:npyLibraryNotfound','readNPYheader not found. Please be sure that npy-matlab is accessible');
end



json=jsondecode(fileread(jsonFile));

%Load appropriate header data from json
switch type
    case 'continuous'
        tempNames = json.continuous;
    case 'spikes'
        tempNames = json.spikes;
    case 'events'
        tempNames = json.events;
    otherwise
        error('Data type not supported');
end

if iscell(tempNames)
    dataNames=arrayfun(@(x) tempNames{x}.folder_name,1:length(tempNames),'un',0);
else
    dataNames=arrayfun(@(x) tempNames(x).folder_name,1:length(tempNames),'un',0);
end

if isempty(selectNames)
    selectIdx = 1:length(dataNames);
else
    if ~iscell(selectNames)
        selectNames = {selectNames};
    end
    selectIdx = find(cellfun(@(x) any(cellfun(@(y) contains(x,y),selectNames)),dataNames));
end

nEntries = length(selectIdx);
fullD = cell(nEntries);

fileNames = dataNames(selectIdx);

for iE = 3%1:nEntries
    if isempty(varargin)
        [fullD{iE},OE_Version] = load_open_ephys_binary(jsonFile, type, selectIdx(iE));
    else
        [fullD{iE},OE_Version] = load_open_ephys_binary(jsonFile, type, selectIdx(iE), varargin);
    end
end
if nEntries == 1
    fullD = fullD{1};
end