function [settings_data, indxOfInterest] = ExtractOE_SignalChain(dataRootDir,nodeOfInterest)

% Take a settings file or data root directory of interest and extract out
% the signal chain of the recordings. Note that for a root directory, this
% must contain the recording node folders which internally have a settings
% file. Setting files are identified as containing 'settings.xml' in the
% file name.
%
% Additionally, a nodeOfInterest string or cell array can be entered to
% directly identify the specific indx within the signal chain that has the
% plugin node of interest. A sting sill search the plugin names and return
% all those containing the requested string. A cell array will search
% pluginNames for the first element and nodeNumber for the second. This is
% useful if you know BOTH the plugin name and its node number (uncommon).
% This functionality can also be done independently in the
% IdentifyOE_SignalNode function.

% GWDiehl July 2024

if contains(dataRootDir,'.xml')
    settingsFile = dataRootDir;
    assert(isfile(settingsFile),'Your settings file does not seem to exist');
else
    subDirs = dir(dataRootDir);
    recNodeIdx = find(arrayfun(@(x) contains(x.name,'Record Node'),subDirs));

    assert(~isempty(recNodeIdx),'You dont have a record node in this directory')
    allFiles = dir([dataRootDir,'\',subDirs(recNodeIdx(1)).name]);
    candidates = arrayfun(@(x) contains(x.name,'.xml'),allFiles);
    assert(any(candidates),'You do not have a settings file in the listed directory')
    settingsFN = allFiles(find(candidates,1)).name;


    settingsFile = [dataRootDir,'\',subDirs(recNodeIdx(1)).name,'\',settingsFN];
end

settings_data=import_OE_SignalChain(settingsFile);

if nargin > 1 & ~isempty(notOfInterest)
    indxOfInterest = IdentifyOE_SignalNode(settings_data,nodeOfInterest);
else
    indxOfInterest = [];
end
