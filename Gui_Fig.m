function varargout = Gui_Fig(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Gui_Fig_OpeningFcn, ...
                   'gui_OutputFcn',  @Gui_Fig_OutputFcn, ...
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

function Gui_Fig_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% add a continuous value change listener
 if ~isfield(handles,'hListener')
    handles.hListener = ...
        addlistener(handles.slider,'ContinuousValueChange',@slider_Callback);
 end

% Update handles structure
guidata(hObject, handles);

function varargout = Gui_Fig_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

% ************************ BROWSER ****************************************
function browser_Callback(hObject, eventdata, handles)

[ video_file_name,video_file_path ] = uigetfile({'*.tif'},'Pick a video file');      %;*.png;*.yuv;*.bmp;*.tif'},'Pick a file');
if(video_file_path == 0)
    return;
end

FileTif = [video_file_path,video_file_name];
InfoImage = imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
FinalImage=zeros(nImage,mImage,3,NumberImages,'uint8');
TifLink = Tiff(FileTif, 'r');

set(handles.address_line,'String',FileTif);

% Acquiring video
f = waitbar(0,'1','Name','Loading tiff file',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(f,'canceling',0);

for i = 1 : NumberImages
    if getappdata(f,'canceling')
        break
    end
    waitbar(i/NumberImages,f,sprintf('%d/%d',i,NumberImages))
    
    TifLink.setDirectory(i);
    FinalImage(:,:,:,i) = TifLink.read();
    

end
TifLink.close();
delete(f);


% Display first frame
frame_1 = imread(FileTif,1);
axes(handles.video_axes);
imshow(frame_1);
drawnow;
% Display Frame Number
set(handles.text1,'String','1');
set(handles.text2,'String',[' / ',num2str(NumberImages)]);
set(handles.text1,'Visible','on');
set(handles.text2,'Visible','on');
set(handles.start,'Enable','on');
%Update handles
handles.FinalImage = FinalImage;

% set the slider range and step size
set(handles.slider, 'Value', 1);
set(handles.slider, 'Min', 1);
set(handles.slider, 'Max', NumberImages);
set(handles.slider, 'SliderStep', [1/(NumberImages-1) , 1/(NumberImages-1) ]);

% save the current/last slider value
handles.lastSliderVal = get(handles.slider,'Value');
guidata(hObject,handles);

function address_line_Callback(hObject, eventdata, handles)

function address_line_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text2_CreateFcn(hObject, eventdata, handles)

function text1_CreateFcn(hObject, eventdata, handles)

% ************************ START ******************************************
function start_Callback(hObject, eventdata, handles)
% Reset handels
set(handles.slider, 'Value', 1);
set(handles.play_pause ,'String', 'Pause');
set(handles.play_pause,'Enable','on');
set(handles.start,'Enable','on');
moveX = handles.moveX;

while handles.slider.Value <= size(handles.FinalImage,4) - 1
    % Display frames
    handles.slider.Value = handles.slider.Value + 1;
    i = handles.slider.Value;
    set(handles.text1,'String',num2str(i));
    axes(handles.video_axes);                                            %maybe change to setter
    imshow(handles.FinalImage(:,:,:,i));
    drawnow;
    
    axes(handles.behaviour_axes);                                        %maybe change to setter
    axis([moveX(i) moveX(i + 200) 0 170]);
    xlim([moveX(i) + (moveX(i)- moveX(i + 200)) moveX(i + 200)]);
    hold on;
    set(handles.vert,'XData',[moveX(i) moveX(i)],'YData',[0 170]);
    drawnow;
    
end
set(handles.play_pause,'Enable','off');
set(handles.slider,'Enable','on');

function start_CreateFcn(hObject, eventdata, handles)

% ************************ PLAY / PAUSE ***********************************
function play_pause_Callback(hObject, eventdata, handles)

if(strcmp(get(handles.play_pause,'String'),'Pause'))
    set(handles.play_pause,'String','Play')
    uiwait();
else
    set(handles.play_pause ,'String', 'Pause');
    uiresume();
end    
    
function play_pause_CreateFcn(hObject, eventdata, handles)


% ************************ EXIT *******************************************

function exit_Callback(hObject, eventdata, handles)
delete(handles.figure1);

% *********************** BEHAVIOUR ***************************************

function load_trail_Callback(hObject, eventdata, handles)

[ trail_file_name,trail_file_path ] = uigetfile({'*.fig'},'Pick a trail file');      
if(trail_file_path == 0)
    return;   
end

fig = openfig([trail_file_path, trail_file_name]);
axObjs = fig.Children;
dataObjs = axObjs.Children;
handles.moveX = dataObjs(5).XData;
handles.moveY = dataObjs(5).YData;
handles.stopX = dataObjs(4).XData; 
handles.stopY = dataObjs(4).YData;
handles.irX = dataObjs(3).XData;
handles.irY = dataObjs(3).YData;
handles.rewardX = dataObjs(2).XData;
handles.rewardY = dataObjs(2).YData;
axes(handles.behaviour_axes);

p = plot(handles.moveX,handles.moveY,'ob', handles.stopX,handles.stopY,'or',...
    handles.rewardX,handles.rewardY,'xk', handles.irX,  handles.irY,'^k');

p(1).MarkerFaceColor = p(1).Color;
p(2).MarkerFaceColor = p(2).Color;
p(3).MarkerSize = 15;
p(3).LineWidth = 2;
p(4).MarkerSize = 15;
p(4).LineWidth = 2;
xlim([-handles.moveX(200) handles.moveX(200)]);
ylim([0 170]);
hold on 
handles.vert = plot(handles.behaviour_axes,[0 0],[0 170]);
handles.vert.Tag = 'Vert';
guidata(hObject,handles);

% *********************** SLIDER ******************************************

function slider_Callback (hObject, eventdata, handles)
handles = guidata(hObject);
 % get the slider value and convert it to the nearest integer that is less
 % than this value
 newVal = floor(get(hObject,'Value'));
 % set the slider value to this integer which will be in the set {1,2,3,...,12,13}
 set(hObject,'Value',newVal);
 % now only do something in response to the slider movement if the 
 % new value is different from the last slider value
 if newVal ~= handles.lastSliderVal
     % it is different, so we have moved up or down from the previous integer
     % save the new value
     handles.lastSliderVal = newVal;
     guidata(hObject,handles);
    % display the current value of the slider
    disp(['at slider value ' num2str(get(hObject,'Value'))]);
 end


function slider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
