function  [indxOfInterest,pluginName, nodeName] = IdentifyOE_SignalNode(pluginName,nodeName,nodeOfInterest)

% Takes a OE plugin and node name data as loaded with the import_OE_Settings and
% identifies the index in the signal chain that contains the node of
% interest. A nodeOfInterest string or cell array can be entered to
% directly identify the specific indx within the signal chain that has the
% plugin node of interest. A sting will search the plugin names and return
% all those containing the requested string. A cell array will search
% pluginNames for the first element and nodeNumber for the second. This is
% useful if you know BOTH the plugin name and its node number (uncommon).

% GWDiehl July 2024

if iscell(nodeOfInterest)
    OI_nodeName = nodeOfInterest{1};
    OI_nodeNumber = nodeOfInterest{2};

    indxOfInterest = cellfun(@(x,y) contains(x,OI_nodeName) & strcmp(y,OI_nodeNumber),pluginName,nodeName);
else
    indxOfInterest = cellfun(@(x) contains(x,nodeOfInterest),pluginName);
end

indxOfInterest = find(indxOfInterest);

pluginName = arrayfun(@(x) pluginName{x},indxOfInterest,'un',0);
nodeName = arrayfun(@(x) nodeName{x},indxOfInterest,'un',0);
