function [fullD,fileNames,OE_Version] = fullData_load_open_ephys_binary(jsonFile,type,selectNames,collapseOuptuts,varargin)

% A generalized shell function that will load in multiple sets of Open
% Ephys data. Can load in multiple sets of file names and will load in all
% of those of a desired name. For example, if your signal chain has
% multiple crossing detectors, this can load data in from all of them at
% once. This shell also allows you to define which file you want to load
% based on the plugin name, not simply by the index in the json file.

% GWDiehl July 2024

if nargin < 4 || isempty(collapseOuptuts)
    collapseOuptuts = 1;
end

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

% Get all of the file names
if iscell(tempNames)
    dataNames=arrayfun(@(x) tempNames{x}.folder_name,1:length(tempNames),'un',0);
else
    dataNames=arrayfun(@(x) tempNames(x).folder_name,1:length(tempNames),'un',0);
end

% Figure out which indices corresponed to the files of interest
if isempty(selectNames)
    selectIdx = 1:length(dataNames);
else
    if ~iscell(selectNames)
        selectNames = {selectNames};
    end
    selectIdx = find(cellfun(@(x) any(cellfun(@(y) contains(x,y),selectNames)),dataNames));
end

% Load up all of the files of interest into a single cell array
nEntries = length(selectIdx);
fullD = cell(1,nEntries);

fileNames = dataNames(selectIdx);

if nEntries == 0
    warning('You have found no files of interest')
    OE_Version =  nan;
    return
end

for iE = 1:nEntries
    if isempty(varargin)
        [fullD{iE},OE_Version] = load_open_ephys_binary(jsonFile, type, selectIdx(iE));
    else
        [fullD{iE},OE_Version] = load_open_ephys_binary(jsonFile, type, selectIdx(iE), varargin);
    end
end

% If only one file of interest, dump it out of the cell array
if nEntries == 1 && collapseOuptuts
    fullD = fullD{1};
end