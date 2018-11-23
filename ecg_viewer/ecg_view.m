function varargout = ecg_view(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ecg_view_OpeningFcn, ...
                   'gui_OutputFcn',  @ecg_view_OutputFcn, ...
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


% --- Executes just before ecg_view is made visible.
function ecg_view_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ecg_view (see VARARGIN)

% Choose default command line output for ecg_view
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ecg_view_OutputFcn(~, ~, handles)
varargout{1} = handles.output;


% --- Executes on button press in connect.
function connect_Callback(hObject, ~, handles)
try
    cla(handles.main_figure);
    cla(handles.anomaly_figure);
    [file_name, path_name]=uigetfile({'*' '��ȡ����'});
    data = load([path_name file_name]);
    data = data.data;
    max_y = max(data)+0.1;
    min_y = min(data)-0.1;
    data_len = length(data);
    file_name = split(file_name,'.');
    file_name = file_name{1};
    labels = load([path_name file_name '_pos.txt']);
    setappdata(hObject,'data',data);
    setappdata(hObject,'data_len',data_len);
    
    
    set(handles.data_name,'String',file_name);
    drawnow;
    pos = 1;%��ǰλ��
    ind_detect = 3;
    pos_detect_start = labels(ind_detect,1);%�ӵ�3�����ڿ�ʼ����
    pos_detect_end = labels(ind_detect,2);
    first_paint = 0;
    while 1
        try
            run_flag = get(handles.start_stop,'String');
            if run_flag == "��ʼ"
                pause(1);
                continue;
            end
            if pos+1000 > data_len
                break;
            end
            if first_paint == 0
                first_paint = 1;
                axes(handles.anomaly_figure);
                grid on;
                grid minor;
                set(handles.main_figure,'GridColor',[0 0 1],'XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on')
                ylim([min_y,max_y])
                
                axes(handles.main_figure);
                plot(handles.main_figure,data,'b');
                set(handles.main_figure,'GridColor',[0 0 1],'XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on')
                ylim([min_y,max_y])
                hold on;
            end
            pos=pos+10;
            xlim([pos,pos+1000]); %������Ҫ�޸�y�ķ�Χ
            set(handles.main_figure,'xtick',pos:100:pos+1000);
            pause(0.05);
            %����⵽һ������ʱ���м��
            if pos > pos_detect_start-700
                data_detect = data(pos_detect_start:pos_detect_end);
                model = getappdata(0,'model');
                flag = detect_series(model,data_detect);
                if flag == 1
                    set(handles.anomaly_start,'String',num2str(pos_detect_start));
                    set(handles.anomaly_stop,'String',num2str(pos_detect_end));
                    cla(handles.anomaly_figure);
                    plot(handles.anomaly_figure,data_detect,'r');
                    plot(handles.main_figure,pos_detect_start:pos_detect_end,data_detect,'r');
                    set(handles.anomaly_figure,'XMinorGrid','on','YMinorGrid','on');
                    switch file_name
                        case 'mitdb'
                            set(handles.anomaly_explain,'String','���쳣Ϊ�����粫��bulabulabula')
                        case 'incartdbA'
                            set(handles.anomaly_explain,'String','���쳣Ϊ�����粫��ҽѧ���ͣ���ǰ���ֵ�խQRS��Ⱥ)')
                    end
                end
                ind_detect = ind_detect+1;
                pos_detect_start = labels(ind_detect,1);
                pos_detect_end = labels(ind_detect,2);
            end
        catch
            fprintf('��ӭʹ�ã��ټ�!!\n');
            break;
        end
    end
catch
    
end

% --- Executes on button press in model.
function model_Callback(~, ~, handles)
try
    [model, ~]=uigetfile({'*' 'ѡ��ģ��'});
    model = split(model,'.');
    model = model{1};
    setappdata(0,'model',model);
    set(handles.model_name,'String',model);
catch
end

% --- Executes on button press in start_stop.
function start_stop_Callback(hObject, eventdata, handles)
run_flag = get(handles.start_stop,'String');
if run_flag == "��ʼ"
    set(handles.start_stop,'String','ֹͣ');
else
    set(handles.start_stop,'String','��ʼ');
end
