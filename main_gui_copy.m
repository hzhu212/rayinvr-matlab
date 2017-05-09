function varargout = main_gui(varargin)
% MAIN_GUI MATLAB code for main_gui.fig
%      MAIN_GUI, by itself, creates a new MAIN_GUI or raises the existing
%      singleton*.
%
%      H = MAIN_GUI returns the handle to a new MAIN_GUI or the handle to
%      the existing singleton*.
%
%      MAIN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_GUI.M with the given input arguments.
%
%      MAIN_GUI('Property','Value',...) creates a new MAIN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main_gui

% Last Modified by GUIDE v2.5 30-Apr-2017 23:55:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
				   'gui_Singleton',  gui_Singleton, ...
				   'gui_OpeningFcn', @main_gui_OpeningFcn, ...
				   'gui_OutputFcn',  @main_gui_OutputFcn, ...
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


% --- Executes just before main_gui is made visible.
function main_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main_gui (see VARARGIN)

% Choose default command line output for main_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_select_folder_Callback(hObject, eventdata, handles)
% hObject    handle to edit_select_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_select_folder as text
%        str2double(get(hObject,'String')) returns contents of edit_select_folder as a double


% --- Executes during object creation, after setting all properties.
function edit_select_folder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_select_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_select_folder.
function btn_select_folder_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	folder_name = uigetdir('./','选择输入文件所在目录');
	set(handles.edit_select_folder,'String',folder_name);


% --- Executes on button press in chkbox_single_file.
function chkbox_single_file_Callback(hObject, eventdata, handles)
% hObject    handle to chkbox_single_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkbox_single_file
	enable_single_file_select = get(hObject,'Value');
	files = {'rin','vin','txin','vmin','din'};
	status = 'on';
	if ~enable_single_file_select
		status = 'off';
	end
    for ii = 1:length(files)
        eval(sprintf('set(handles.edit_select_%s,''Enable'',''%s'')',files{ii},status));
        eval(sprintf('set(handles.btn_select_%s,''Enable'',''%s'')',files{ii},status));
    end



function edit_select_xin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_select_xin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_select_xin as text
%        str2double(get(hObject,'String')) returns contents of edit_select_xin as a double


% --- Executes during object creation, after setting all properties.
function edit_select_xin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_select_xin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_select_xin.
function btn_select_xin_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_xin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_select_din_Callback(hObject, eventdata, handles)
% hObject    handle to edit_select_din (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_select_din as text
%        str2double(get(hObject,'String')) returns contents of edit_select_din as a double


% --- Executes during object creation, after setting all properties.
function edit_select_din_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_select_din (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_select_din.
function btn_select_din_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_din (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_select_vmin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_select_vmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_select_vmin as text
%        str2double(get(hObject,'String')) returns contents of edit_select_vmin as a double


% --- Executes during object creation, after setting all properties.
function edit_select_vmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_select_vmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_select_vmin.
function btn_select_vmin_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_vmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_select_txin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_select_txin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_select_txin as text
%        str2double(get(hObject,'String')) returns contents of edit_select_txin as a double


% --- Executes during object creation, after setting all properties.
function edit_select_txin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_select_txin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_select_txin.
function btn_select_txin_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_txin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_select_vin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_select_vin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_select_vin as text
%        str2double(get(hObject,'String')) returns contents of edit_select_vin as a double


% --- Executes during object creation, after setting all properties.
function edit_select_vin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_select_vin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_select_vin.
function btn_select_vin_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_vin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_select_rin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_select_rin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_select_rin as text
%        str2double(get(hObject,'String')) returns contents of edit_select_rin as a double


% --- Executes during object creation, after setting all properties.
function edit_select_rin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_select_rin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_select_rin.
function btn_select_rin_Callback(hObject, eventdata, handles)
% hObject    handle to btn_select_rin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in chkbox_plot.
function chkbox_plot_Callback(hObject, eventdata, handles)
% hObject    handle to chkbox_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkbox_plot


% --- Executes on button press in btn_run.
function btn_run_Callback(hObject, eventdata, handles)
% hObject    handle to btn_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	folder_name = get(handles.edit_select_folder,'String');
	main(folder_name);
