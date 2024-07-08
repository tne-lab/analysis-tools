function  [indxOfInterest,pluginName, nodeName] = IdentifyOE_SignalNode(settings_data,nodeOfInterest)

% Takes a OE settings table as loaded with the import_OE_signal_chain and
% identifies the index in the signal chain that contains the not of
% interest. A nodeOfInterest string or cell array can be entered to
% directly identify the specific indx within the signal chain that has the
% plugin node of interest. A sting sill search the plugin names and return
% all those containing the requested string. A cell array will search
% pluginNames for the first element and nodeNumber for the second. This is
% useful if you know BOTH the plugin name and its node number (uncommon).

% GWDiehl July 2024

if iscell(nodeOfInterest)
    nodeName = nodeOfInterest{1};
    nodeNumber = nodeOfInterest{2};

    indxOfInterest = cellfun(@(x,y) contains(x,nodeName) & strcmp(y,nodeNumber),settings_data.pluginName,settings_data.nodeName);
else
    indxOfInterest = cellfun(@(x) contains(x,nodeOfInterest),settings_data.pluginName);
end

indxOfInterest = find(indxOfInterest);

pluginName = arrayfun(@(x) settings_data.pluginName{x},indxOfInterest,'un',0);
nodeName = arrayfun(@(x) settings_data.nodeName{x},indxOfInterest,'un',0);
