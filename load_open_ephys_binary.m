function [D,OE_Version] =load_open_ephys_binary(jsonFile, type, index, varargin)
%function D=load_open_ephys_binary(oebinFile, type, index)
%
%Loads data recorded by Open Ephys in Binary format
%  oebinFile: The path for the structure.oebin json file
%  type: The type of data to load. Can be 'continuous', 'events' or
%  'spikes'
%  index: The index of the recorded element as appears in the oebin file
%(See also list_open_ephys_binary to extract recorded elements and indexes)
%
%Returns a structure with the header and relevant loaded data
%
%Example:
%D=load_open_ephys_binary('recording_1/structure.oebin','spikes',2)
%
%When loading continuous data, an optional fourth argument 'mmap' can be
%used:
%D=load_open_ephys_binary('recording_1/structure.oebin','continuous',1,'mmap')
%In this case, the Data member from the returned structure contains not an
%array with the data itself but a memory-mapped object of the file, which
%can be used to access its contents. This helps loading big-sized files, as
%it does not require loading the entire file in memory.
%In this case, the data may be accessed using the field D.Data.Data(1).mapped
%For example: D.Data.Data(1).mapped(chan,startSample:endSample)
%
%
%Limitations:
%-TEXT events are not supported by the NPY reading library, so their data
%will not load, but all other fields will.
%-Some metadata structures might not be supported by the NPY reading
%library. In this case the metadata will not be loaded
%In both cases a warning message will be displayed but the program will not
%fail
%
%
%This functions requires the functions readNPY and readNPYHeader 
%from npy-matlab package from kwik-team
%(https://github.com/kwikteam/npy-matlab)
%Requires minimum MATLAB version: R2016b

if (exist('readNPY.m','file') == 0)
    error('OpenEphys:loadBinary:npyLibraryNotfound','readNPY not found. Please be sure that npy-matlab is accessible');
end

if (exist('readNPYheader.m','file') == 0)
    error('OpenEphys:loadBinary:npyLibraryNotfound','readNPYheader not found. Please be sure that npy-matlab is accessible');
end
if (nargin > 3 && strcmp(varargin{1},'mmap'))
    continuousmap = true;
else
    continuousmap = false;
end


json=jsondecode(fileread(jsonFile));

switch json.GUIVersion(1:3)
    case '0.5'
        OE_Version = 5;
    case '0.6'
        OE_Version = 6;
    otherwise
        error('Unknown OE Version')
end

%Load appropriate header data from json
switch type
    case 'continuous'
        header=json.continuous(index);
    case 'spikes'
        header=json.spikes(index);
    case 'events'
        if (iscell(json.events))
            header=json.events{index}; 
        else
            header=json.events(index);
        end
    otherwise
        error('Data type not supported');
end

%Look for folder
f=java.io.File(jsonFile);
if (~f.isAbsolute())
    f=java.io.File(fullfile(pwd,jsonFile));
end
f=java.io.File(f.getParentFile(),fullfile(type, header.folder_name));
if(~f.exists())
    error('Data folder not found');
end
folder = char(f.getCanonicalPath());
D=struct();
D.Header = header;

switch type
    case 'continuous'
        D.Timestamps = readNPY(fullfile(folder,'timestamps.npy'));
        contFile=fullfile(folder,'continuous.dat');
        if (continuousmap)
            file=dir(contFile);
            samples=file.bytes/2/header.num_channels;
            D.Data=memmapfile(contFile,'Format',{'int16' [header.num_channels samples] 'mapped'});
        else
            file=fopen(contFile);
            D.Data=fread(file,[header.num_channels Inf],'int16');
            fclose(file);
        end
    case 'spikes'
        D.Timestamps = readNPY(fullfile(folder,'spike_times.npy'));
        D.Waveforms = readNPY(fullfile(folder,'spike_waveforms.npy'));
        D.ElectrodeIndexes = readNPY(fullfile(folder,'spike_electrode_indices.npy'));
        D.SortedIndexes = readNPY(fullfile(folder,'spike_clusters.npy'));
    case 'events'

        % NOTE THAT THIS PORTION OF V5/V6 WAS WRITEN BASED ON CROSSING DETECTOR
        % OUTPUTS. OTHER EVENT PLUGINS MAY LOOK DIFFERENT

        % Common fields v5 and v6.
        % Note that in v5 timestamps is SAMPLES and in v6 is SECONDS!!
        D.Timestamps = readNPY(fullfile(folder,'timestamps.npy')); 

        switch OE_Version
            case 5
                D.ChannelIndex = readNPY(fullfile(folder,'channels.npy'));
                D.SampleNumber = D.Timestamps;
            case 6
                D.ChannelIndex = nan(size(D.Timestamps)); % Field removed in V6 *Maybe*
                D.SampleNumber = readNPY(fullfile(folder,'sample_numbers.npy'));                
        end       
        
        % Update this section to check for specific npy files. Things got
        % renamed in v6 of OE so better to check for specific files.

        if isfile(fullfile(folder,'text.npy')) % Check to see if this exists
            D.Data = readNPY(fullfile(folder,'text.npy'));
        elseif isfile(fullfile(folder,'channel_states.npy')) || isfile(fullfile(folder,'states.npy'))            
            switch OE_Version
                case 5
                    D.Data = readNPY(fullfile(folder,'channel_states.npy'));
                case 6
                    D.Data = readNPY(fullfile(folder,'states.npy'));
            end
            
            wordfile = fullfile(folder,'full_words.npy');
            if (isfile(wordfile))
                D.FullWords = readNPY(wordfile);
            end

        elseif isfile(fullfile(folder,'data_array.npy'))
           D.Data = readNPY(fullfile(folder,'data_array.npy'));
        end       
end

% Load metadata will now work via a python loader to a csv save to a matlab
% structure.
metadatafile = fullfile(folder,'metadata.npy');
if isfile(metadatafile)
    D.MetaData = readMetadataNPY(metadatafile);
end

% Replaced with above code
% % % 
% % % if (isfile(metadatafile))
% % %     try
% % %     D.MetaData = readNPY(metadatafile);
% % %     catch EX
% % %         warning(EX.identifier,'WARNING: cannot read metadata file.\nData structure might not be supported.\n\nError message: %s\nTrace:\n',EX.message);
% % %         for i=1:length(EX.stack)
% % %             % frintf('File: %s Function: %s Line: %d\n',EX.stack(i).file,EX.stack(i).name,EX.stack(i).line);
% % %         end
% % %     end
% % % end
end