function varargout = DistanceMeasurement(varargin)
%      DISTANCEMEASUREMENT, by itself, creates a new DISTANCEMEASUREMENT or raises the existing
%      singleton*.
%
%      H = DISTANCEMEASUREMENT returns the handle to a new DISTANCEMEASUREMENT or the handle to
%      the existing singleton*.
%
%      DISTANCEMEASUREMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISTANCEMEASUREMENT.M with the given input arguments.
%
%      DISTANCEMEASUREMENT('Property','Value',...) creates a new DISTANCEMEASUREMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DistanceMeasurement_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DistanceMeasurement_OpeningFcn via varargin.

example1 = 'ParkingSensor'; 
example2 = 'MuseumArtifactSensor';
global sFlag;
sFlag = 1;

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       example1, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DistanceMeasurement_OpeningFcn, ...
                   'gui_OutputFcn',  @DistanceMeasurement_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code


% --- Executes just before the figure is made visible.
function DistanceMeasurement_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DistanceMeasurement (see VARARGIN)

% global temp;
% global i;
% i = 0;
% Choosing default command line output for figure
handles.output = hObject;
% Delete any opened ports in MATLAB
delete(instrfind)
% Create a Serial Object
% Update: Registering new error on Ardunio IDE, check pins before launch
handles.ser = serial('COM7','BaudRate',115200,'Terminator','LF','Timeout',10);
% Associate Serial Event, whenever Terminal Character is recived
handles.ser.BytesAvailableFcn = {@SerialEvent, hObject};
% Open Serial Port
fopen(handles.ser);
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line i.e. the
% figure
function varargout = DistanceMeasurement_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data

% Get default command line output from handles structure
varargout{1} = handles.output;

function SerialEvent(sObject, eventdata, hGui)
global sFlag;
% get the updated handle
handles = guidata(hGui);

% get data from serial port
tmp_c = fscanf(sObject);
% convert string data to scalar numerical data
temp = str2num(tmp_c);
if sFlag == 1
    % conditions for diplaying output and messages
    if temp < 7
        set(handles.alertsText, 'String', 'Danger! Too close!', 'ForegroundColor', 'r')
    end
    if temp > 7 && temp < 15
        set(handles.alertsText, 'String', 'Warning!', 'ForegroundColor', [0.93 0.69 0.13])
    end
    if temp > 15 && temp < 50
        set(handles.alertsText, 'String', 'Safe', 'ForegroundColor', [0.39 0.83 0.07])
    end
    if temp > 50
        set(handles.alertsText, 'String', 'Safe. No objects nearby', 'ForegroundColor', [0.39 0.83 0.07])
    end
    if temp == 0
        set(handles.alertsText, 'String', 'IMPACT!!', 'ForegroundColor', 'r')
    end
end
% display distance output value
set(handles.textDistance, 'String', tmp_c)

% FUTURE WORK
% Trying out the plot and logging system
% pp = str2num(tmp_c);
% temp(i) = pp;
% i=i+1;
% x = 1:5;
% y = 6:10;
% plot(x,y)
% xlsappend('./text.csv',temp,'String')
% plot and logging system ends here

% Updates handle structure
guidata(hGui, handles)


% --- Executes on closing figure window
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data
fclose(handles.ser);
delete(handles.ser);

% delete object when window is closed
delete(hObject);
