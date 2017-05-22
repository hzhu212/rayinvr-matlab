function fun_update_all_panel_display(src,tag,uidisplay)
% src:  a 1x1 structure of OBS or SCS
% tag: a string, 'OBS' or 'SCS'
% uidisplay: a cell of handles

switch tag
    case 'OBS'
        [obsp,obsdisplayp]=deal(uidisplay{:});
        handle=get(obsp,'Children');
        set(handle(1),'Data',src.offsettable); % obsofftableh
        phasenumber=get(handle(3),'Value'); % obspop2
        obsnumber=get(handle(5),'Value'); % obspop1
        handle=get(obsdisplayp,'Children');
        if isempty(src.phase)
            set(handle(1),'Data',[]);
            set(handle(2),'String','Source file: "   "; REMARKS: ""');
            set(handle(3),'String','Phase # is selected');% obsphasetexth
        else
            set(handle(1),'Data',src.phase{phasenumber}); % obsphaseh
            if isempty(src.remarks)
                remarks='';
            else
                remarks=src.remarks{phasenumber};
            end
            set(handle(2),'String',['Source file: "',src.phasefile{phasenumber},'"; REMARKS: ',remarks]);
            [ray,wave]=deal('');
            switch src.phase{phasenumber}(1,8);
                case 1
                    ray='Refraction';
                case 2
                    ray='Reflection';
                case 3
                    ray='Head';
            end
            switch src.phase{phasenumber}(1,9);
                case 1
                    wave='P-wave';
                case 2
                    wave='S-wave';
            end
            set(handle(3),'String',['Phase #',num2str(phasenumber),' (ID ',num2str(src.phaseID(1,phasenumber)),', Time group ',...
                num2str(src.phaseID(2,phasenumber)),') is selected (',ray,' ',wave,')']);% obsphasetexth
        end
        set(handle(4),'String',['OBS #',num2str(obsnumber),': ',src.name,' (',num2str(src.moffset),' km)']);
        handle=get(handle(5),'Children'); % obsgeneralp
        set(handle(2),'String',['Shot number vs. model distance table source file: "',src.tablefile,'"']);
        if ~isempty(src.XYZ);
            xyz=src.XYZ(1:3)/src.XYZ(4);
            set(handle(4),'String',['X: ',num2str(xyz(1)),'; Y: ',num2str(xyz(2)),'; Z: ',num2str(xyz(3)),' (m)']);
        end
        if ~isempty(src.LatLon);
            set(handle(5),'String',['Latitude: ',num2str(src.LatLon(1)),'; Longitude: ',num2str(src.LatLon(2)),' (degree)']);
        end
        pcount=0;
        scount=0;
        total=length(src.phase);
        for i=1:total;
            phasenumber=i;
            if src.phase{phasenumber}(1,9)==1;
                pcount=pcount+1;
            elseif src.phase{phasenumber}(1,9)==2;
                scount=scount+1;
            end
        end
        set(handle(7),'String',['Phase number: ',num2str(total),' (P: ',num2str(pcount),'; S: ',num2str(scount),')']);
        set(handle(8),'String',['Distance in model: ',num2str(src.moffset),' (km)']);
        set(handle(9),'String',['Name: ',src.name]);
        set(handle(10),'String',['OBS # : ',num2str(obsnumber)]);
    case 'SCS'
        [scsp,scsdisplayp]=deal(uidisplay{:});
        handle=get(scsp,'Children');
        set(handle(1),'Data',src.offsettable); % scsofftableh
        phasenumber=get(handle(3),'Value'); % scspop2
        scsnumber=get(handle(5),'Value'); % scspop1
        handle=get(scsdisplayp,'Children');
        if isempty(src.phase);
            set(handle(1),'Data',[]);
        else
            set(handle(1),'Data',src.phase{phasenumber}); % scsphaseh
        end
        if isempty(src.remarks)
            remarks='';
        else
            remarks=src.remarks{phasenumber};
        end
        if isempty(src.phasefile);
            set(handle(2),'String','Source file: ""; REMARKS: ');
        else
            set(handle(2),'String',['Source file: "',src.phasefile{phasenumber},'"; REMARKS: ',remarks]);
        end
        if isempty(src.phaseID);
            set(handle(3),'String',['Phase #',num2str(phasenumber),' (ID , Time group ',...
                ') is selected']);% scsphasetexth
        else
            set(handle(3),'String',['Phase #',num2str(phasenumber),' (ID ',num2str(src.phaseID(1,phasenumber)),', Time group ',...
                num2str(src.phaseID(2,phasenumber)),') is selected']);% scsphasetexth
        end
        set(handle(4),'String',['Survey #',num2str(scsnumber),': ',src.name]);
        handle=get(handle(5),'Children'); % scsgeneralp
        set(handle(2),'String',['Shot number vs. model distance table source file: "',src.tablefile,'"']);
        total=length(src.phase);
        set(handle(5),'String',['P-wave reflection phase number: ',num2str(total)]);
        set(handle(6),'String',['Name: ',src.name]);
        set(handle(7),'String',['Survey # : ',num2str(scsnumber)]);
end