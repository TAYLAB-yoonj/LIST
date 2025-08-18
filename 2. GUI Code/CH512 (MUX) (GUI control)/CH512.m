function varargout = CH512(varargin)
% This is the code to control the microfluidic chips in general - Gabriel
% MV
% clearvars; vrclear('-force'); clc;

addpath(genpath('.\Functions\'));
addpath(genpath('.\Functions\ForScript\'));
global GUI vc f 

% Color for the turned-off and -on and toggle buttons
GUI.oncolor=[0    0.4471    0.7412];
GUI.offcolor=[1.0000    0.8431         0];
GUI.menucolor=[0.2039    0.3020    0.4941];

% This will determine the total number of valves
% GUI.xnum=8;
% GUI.ynum=12;
GUI.tot=80;
GUI.tries=10;

% This will determine the total number of programmable pathways
GUI.pxnum=5;
GUI.pynum=10;

GUI.seqStop=0;
GUI.scRunning = 0;
GUI.scStop = 0;
GUI.scPause = 0;
GUI.scPauseStart = 0;
GUI.GUI.p1Running = 0;
GUI.p2Running = 0;
GUI.p3Running = 0;

GUI.scFolder = '.\Scripts\';

f = figure('units','normalized','outerposition',[0 .02 1 .98],'Name','CH512 GUI');

%%
%%% initialize controllers
if libisloaded('ftd2xx')==1
    unloadlibrary ftd2xx
end
set(f,'CloseRequestFcn',@close_GUI_Callback)
%set(f,'OpeningFcn',maximize('all'))

vc.num = 4;
vc.info(1).sn = 'ELZ5LP9Q';
vc.info(1).handle = 0;
vc.info(1).status = 0;
vc.info(1).polarity = true(1, 24);

vc.info(2).sn = 'ELZ5LPCI';
vc.info(2).handle = 0;
vc.info(2).status = 0;
vc.info(2).polarity = true(1, 24);

vc.info(3).sn = 'ELZ5LQB0';
vc.info(3).handle = 0;
vc.info(3).status = 0;
vc.info(3).polarity = true(1, 24);

vc.info(4).sn = 'ELZ5LPFQ';
vc.info(4).handle = 0;
vc.info(4).status = 0;
vc.info(4).polarity = true(1, 8);

vc=vc_open_setup(vc);   % This function assigns the handler and status for each box to vc
disp(['Status of box#1 = ' num2str(vc.info(1).status)]);
disp(['Status of box#2 = ' num2str(vc.info(2).status)]);
disp(['Status of box#3 = ' num2str(vc.info(3).status)]);
disp(['Status of box#4 = ' num2str(vc.info(4).status)]);

check=0;
%%
while (vc.info(1).status==1 || vc.info(2).status==1 || vc.info(3).status==1 || vc.info(4).status==1 ) && check<GUI.tries
    check=check+1;
    vc = vc_close(vc, 1);
    vc.info(1).status = 0;
    vc.info(2).status = 0;
    vc.info(3).status = 0;
    vc.info(4).status = 0;
    vc = vc_open_setup(vc);
    
    if check==GUI.tries
        error('Connecting to control box failed. Replug the Controlbox and restart the GUI');
    end
end

%% Create panels
% close all

% f=figure('Units','normalized','Position',[0.01 0.1 .98 .8]);
p0=uipanel(f,'Title','Individual Control','FontSize',12,'BackgroundColor', [.85 .85 .85],...
    'Units','normalized',...
    'Position',[.01 .25 .405 .75]);
GUI.p1=uipanel(f,'Title','Sequence',...
    'units','normalized','FontSize',12,'BackgroundColor', [.85 .85 .85],...
    'Position',[.42 .01 .5 .99]);

p3=uipanel(f,'Title','Dialog',...
    'units','normalized','FontSize',12,'BackgroundColor', [.85 .85 .85],...
    'Position',[.01 .01 .15 .20]);

p4=uipanel(f,'Title','Script Control','FontSize',12,'BorderType','none','BackgroundColor', [.85 .85 .85],...
    'Units','normalized',...
    'Position',[.165 .01 .25 .20]);

p5=uipanel(f,'FontSize',12,'BorderType','none','BackgroundColor', [.85 .85 .85],...
    'Units','normalized',...
    'Position',[.92 .01 .08 .99]);

GUI.scrt = uicontrol(p3,'style','edit','units','normalized',...
    'HorizontalAlign','left','min',0,'max',100,'enable','inactive',...
    'Units','normalized',...
    'string', 'GUI for CCChip 4.3 initiated',...
    'Position',[.01 .01 .99 .99]);

% %% Create the individual control buttons
valvenum = 0;

% For the first set of inlets
for nrow=1:10
    for ncol=1:8
        valvenum=valvenum+1;
        GUI.button(valvenum)=uicontrol(p0,'Style','Togglebutton',...
            'String',['#',num2str(valvenum-1)],'FontSize',9,...
            'Units', 'Normalized',...
            'Position', [.005+.112*(ncol-1) .995-.1*nrow .11 .1],...
            'Value',1,...
            'BackgroundColor', GUI.offcolor,...
            'UserData', num2str(valvenum-1),...
            'Callback', @valve_toggle_Callback);
    end
end

GUI.button(GUI.tot+2)=uicontrol(p0,'Style','Pushbutton','String','Open All',...
    'Units','Normalized','Position',[.91 .795 .085 .09],'Value',0,...
    'BackgroundColor',GUI.menucolor,...
    'Callback',@open_all_Callback);
GUI.button(GUI.tot+1)=uicontrol(p0,'Style','Pushbutton','String','Close All',...
    'Units','Normalized','Position',[.91 .695 .085 .09],'Value',0,...
    'BackgroundColor',GUI.menucolor,...
    'Callback',@close_all_Callback);
GUI.button(GUI.tot+3)=uicontrol(p0,'Style','Pushbutton','String','Close GUI',...
    'Units','Normalized','Position',[.91 .25 .085 .09],'Value',0,...
    'BackgroundColor',GUI.menucolor,...
    'Callback',@close_GUI_Callback);

GUI.button(GUI.tot+4)=uicontrol(p5,'Style','Pushbutton','String','ADD',...
    'Units','Normalized','Position',[.1 .9 .8 .05],'Value',0,...
    'Callback',@add_seq_Callback);

GUI.button(GUI.tot+5)=uicontrol(p5,'Style','Pushbutton','String','REMOVE',...
    'Units','Normalized','Position',[.1 .85 .8 .05],'Value',0,...
    'Callback',@remove_seq_Callback);

GUI.button(GUI.tot+6)=uicontrol(p5,'Style','Pushbutton','String','Run',...
    'Units','Normalized','Position',[.1 .7 .8 .05],'Value',0,...
    'BackgroundColor','g',...
    'Callback',@run_seq_Callback);

GUI.button(GUI.tot+7)=uicontrol(p5,'Style','Pushbutton','String','Pause',...
    'Units','Normalized','Position',[.1 .64 .8 .05],'Value',0,...
    'Callback',@pause_seq_Callback);

GUI.button(GUI.tot+8)=uicontrol(p5,'Style','Pushbutton','String','Stop',...
    'Units','Normalized','Position',[.1 .58 .8 .05],'Value',0,...
    'Callback',@stop_seq_Callback);

GUI.button(GUI.tot+9)=uicontrol(p5,'Style','Pushbutton','String','Save',...
    'Units','Normalized','Position',[.1 .38 .8 .05],'Value',0,...
    'Callback',@save_seq_Callback);

GUI.button(GUI.tot+10)=uicontrol(p5,'Style','Pushbutton','String','Load',...
    'Units','Normalized','Position',[.1 .28 .8 .05],'Value',0,...
    'Callback',@load_seq_Callback);

% %% Create Script Control
GUI.scT1 = uicontrol(p4,'Style','PushButton', 'String', 'Script Folder: ',...
    'FontSize', 10, 'Units','Normalized','Position',[.05 .7 .25 .25],'HorizontalAlignment','center',...
    'Callback', @scFolder_Callback);
GUI.scF = uicontrol(p4,'Style','Edit', 'String', GUI.scFolder,...
    'FontSize', 9, 'Units','Normalized','Position',[.3 .7 .6 .25],...
    'HorizontalAlignment','left');

GUI.scT2 = uicontrol(p4,'Style','text', 'String', 'Script: ','BackgroundColor', [.85 .85 .85],...
    'FontSize', 10, 'Units','Normalized','Position',[.05 .4 .25 .25],'HorizontalAlignment','right');
GUI.scFName = '   ';
GUI.scFN = uicontrol(p4,'Style','PopUpMenu', 'String', GUI.scFName,...
    'FontSize', 9, 'Units','Normalized','Position',[.3 .4 .6 .25],...
    'HorizontalAlignment','left','Callback', @scFName_Callback);
scUpdate_Callback;

GUI.scUpdate = uicontrol(p4,'Style','PushButton', 'String', 'UPDATE',...
    'Units','Normalized','Position',[.05 .1 .15 .25],...
    'Callback',@scUpdate_Callback);
GUI.scEdit = uicontrol(p4,'Style','PushButton', 'String', 'EDIT',...
    'Units','Normalized','Position',[.25 .1 .15 .25],...
    'Callback',@scEdit_Callback);
GUI.scRun = uicontrol(p4,'Style','PushButton', 'String', 'RUN',...
    'Units','Normalized','Position',[.5 .1 .15 .25],...
    'Callback',@scRun_Callback);
GUI.scStopB = uicontrol(p4,'Style','PushButton', 'String', 'STOP',...
    'Units','Normalized','Position',[.75 .1 .15 .25],...
    'Callback',@scStop_Callback);


GUI.datTable =    { '' '' '' false false };
GUI.datTable=repmat(GUI.datTable,10,1);
GUI.selectRow=[];

% Create the uitable
GUI.tab = uitable(GUI.p1,'Data', GUI.datTable,...
    'Units','Normalized','Position',[.01 .05 .98 .95],...
    'ColumnWidth', {500 50 230 50 50},...
    'ColumnName',{'Valves','Delay','Memo','Run','Delete'},...
    'ColumnEditable', [true true true true true true],...
    'CellSelectionCallback',@selectRow,...
    'CellEditCallback',@editTable);


%% close all valves
nums = 0:GUI.tot-1;
values = zeros(1, GUI.tot);
vc = vc_set_bits_ac(vc, nums, values);
for valvenum=1:GUI.tot
    set(GUI.button(valvenum),'BackgroundColor',GUI.offcolor,...
        'string',['#',get(GUI.button(valvenum),'UserData'),' closed'],'FontSize',10,'value',1);
end

GUI.sig=uicontrol(f,'Style','text','backgroundcolor',[.85 .85 .85],...
    'String','ver 2024-02-23 by Gabriel MV',...
    'Units','Normalized','Position',[.84 .03 .12 .02]);
end