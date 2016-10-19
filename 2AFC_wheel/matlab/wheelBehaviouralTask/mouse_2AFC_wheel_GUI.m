function varargout = mouse_2AFC_wheel_GUI(varargin)
% MOUSE_2AFC_WHEEL_GUI MATLAB code for mouse_2AFC_wheel_GUI.fig
%      MOUSE_2AFC_WHEEL_GUI, by itself, creates a new MOUSE_2AFC_WHEEL_GUI or raises the existing
%      singleton*.
%
%      H = MOUSE_2AFC_WHEEL_GUI returns the handle to a new MOUSE_2AFC_WHEEL_GUI or the handle to
%      the existing singleton*.
%
%      MOUSE_2AFC_WHEEL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOUSE_2AFC_WHEEL_GUI.M with the given input arguments.
%
%      MOUSE_2AFC_WHEEL_GUI('Property','Value',...) creates a new MOUSE_2AFC_WHEEL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mouse_2AFC_wheel_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mouse_2AFC_wheel_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mouse_2AFC_wheel_GUI

% Last Modified by GUIDE v2.5 19-Oct-2016 14:01:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mouse_2AFC_wheel_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mouse_2AFC_wheel_GUI_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before mouse_2AFC_wheel_GUI is made visible.
function mouse_2AFC_wheel_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mouse_2AFC_wheel_GUI (see VARARGIN)

% Choose default command line output for mouse_2AFC_wheel_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);




% UIWAIT makes mouse_2AFC_wheel_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mouse_2AFC_wheel_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1. START BUTTON
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global wb
wb.run=1;
if strcmp(wb.dev,'nidaq')
    wheel_behaviour;
else
    wheel_behaviour_soundCard;
end


% --- Executes on button press in pushbutton2. STOP BUTTON
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global wb
wb.run=2;



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
global wb
contents = cellstr(get(hObject,'String'));
wb.dev=contents{get(hObject,'Value')};



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global wb
contents = cellstr(get(hObject,'String'));
wb.dev=contents{get(hObject,'Value')};
