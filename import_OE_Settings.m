
function [settings,nodeName,pluginName] = import_OE_Settings(filename)

% Loads in Open Ephys settings files using the matlab table format. Find
% the plugin name and node idx info that are used for folder saving
% formats. This should be able to handle both OE v5 and v6 based on their
% differnet column names. Any additional naming variations could be added
% below and covered as well.

% GWDiehl Sept 2024

% Possible columnNames for the two nodes of interest
nodeNameField = {'NodeIdAttribute' 'nodeIdAttribute'};
pluginNameField = {'pluginNameAttribute'};

% Get the settings
settings = readtable(filename);
allColumns = fieldnames(settings);

% Find which column has the data of interest
nodeIdx = find(cellfun(@(x) ismember(x,nodeNameField),allColumns));
pluginIdx = find(cellfun(@(x) ismember(x,pluginNameField),allColumns));

assert(length(nodeIdx)==1,'You dont have a unique hit on the Node Info')
assert(length(pluginIdx)==1,'You dont have a unique hit on the Plugin Name')

% Extract the info
temp = num2cell(settings.(allColumns{nodeIdx}));
nodeName = cellfun(@(x) num2str(x),temp,'un',0);
pluginName = settings.(allColumns{pluginIdx});

