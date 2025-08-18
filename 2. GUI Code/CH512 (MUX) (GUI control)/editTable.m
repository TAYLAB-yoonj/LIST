function editTable(src,evt)
global GUI 
    pushCol=evt.Indices;
    if pushCol(2)==5 & size(src.Data,1)>1
                src.Data(pushCol(1),:)=[];
    end

end


%     % Set width and height
%     t.Position(3) = t.Extent(3);
%     t.Position(4) = t.Extent(4);
% 
% 
%         function  modifyPopup(src)
%             id_group_1 = {'A.1';'A.2';'A.3'};
%             id_group_2 = {'B.1';'B.2';'B.3'};
%             id_group_3 = {'C.1';'C.2';'C.3'};
%             id_group_4 = {'D.1';'D.2';'D.3'};
%             id_group_5 = {'E.1';'E.2';'E.3'};
%             id_default = {'CheckBox'};
% 
%             config_data = get(src,'Data');
%             selector = config_data(1:5,1);
%             selector = cell2mat(selector);
% 
% 
% 
%             config_format = get(src,'ColumnFormat');
%             if isequal(selector(1),1)
%                 config_format{3} = id_group_1';
%             elseif  isequal(selector(2),1)
%                 config_format{3} = id_group_2';
%                elseif  isequal(selector(3),1)
%                 config_format{3} = id_group_3';
%                 elseif  isequal(selector(4),1)
%                 config_format{3} = id_group_4';
%                elseif  isequal(selector(5),1)
%                 config_format{3} = id_group_5';
%             else
%                 config_format{3} = id_default;
%             end
% 
%             set(src,'Data',config_data);
%             set(src,'ColumnFormat',config_format);
% end
