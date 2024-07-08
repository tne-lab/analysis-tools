function [settings_data, indxOfInterest] = ExtractOE_SignalChain(dataRootDir,nodeOfInterest,settingsFile)

% Take a settings file or data root directory of interest and extract out
% the signal chain of the recordings. Note that for a root directory, this
% must contain the recording node folders which internally have a settings
% file. 
%
% Additionally, a nodeOfInterest string or cell array can be entered to
% directly identify the specific indx within the signal chain that has the
% plugin node of interest.

if ~contains(dataRootDir,'settings.xml')
    subDirs = dir(dataRootDir);
    recNodeIdx = find(arrayfun(@(x) contains(x.name,'Record Node'),subDirs));

    assert(~isempty(recNodeIdx),'You dont have a record node in this directory')

    settingsFile = [dataRootDir,'\',subDirs(recNodeIdx(1)).name,'\settings.xml'];

else
    assert(isfile(settingsFile),'Your settings file does not seem to exist');
end

settings_data=import_OE_SignalChain(settingsFile);

if iscell(nodeOfInterest)
    nodeName = nodeOfInterest{1};
    nodeNumber = nodeOfInterest{2};

    indxOfInterest = cellfun(@(x,y) contains(x,nodeName) & strcmp(y,nodeNumber),settings_data.pluginName,settings_data.nodeName);
else
    indxOfInterest = cellfun(@(x) contains(x,nodeOfInterest),settings_data.pluginName);
end

indxOfInterest = find(indxOfInterest);