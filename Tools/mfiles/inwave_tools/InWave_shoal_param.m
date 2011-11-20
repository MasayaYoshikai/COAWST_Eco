% THIS FILE CONTAINS THE DEFINITIONS OF THE PARAMETERS NEEDED TO CREATE THE 
% INPUT FILES FOR THE INWAVE MODEL:
%
% InWave_grd.nc
% InWave_ini.nc
% InWave_bnd.nc
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                DEFINE WHICH FILES TO GENERATE                   %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

make_InWave_grd=1;
make_InWave_ini=1;
make_InWave_bnd=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%        GENERAL PARAMETERS: THESE NEED TO BE DEFINED ALWAYS       %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Lm= 101;                % number of total rho points in the xi direction
Mm= 101;                % number of total rho points in the eta direction
TA= 10;                % representative absolute wave period (sec)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                GRID AND BATHYMETRY DEFINITION                   %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filepath='..\..\..\Projects\Inwave_tests\shoal\';

if (make_InWave_grd)
    
  grd_file=strcat(filepath,'InWave_grd.nc');  % name of the grid file
    
  % Grid characteristics

  dx=50;                % grid cell size in xi direction
  dy=50;                % grid cell size in eta direction 

  % enter x and y coordinates of rho points

  x=[-dx/2:dx:dx*(Lm-1)];
  y=[-dy/2:dy:dy*(Mm-1)];

  x=repmat(x,length(y),1);
  y=repmat(y',1,length(x));

  % Bathymetry characteristics
  depth0= 20.;            % water depth in the study domain (m)

  % set depth 
  depth=zeros(size(x))+depth0;
  
  r1=10.0;
  r2=30.0;

  for j=1:Mm
   for i=1:Lm
	    rad=((i-51)^2.+(j-51)^2.)^0.5;
		if(rad<r1)
          	depth(i,j)=5.0;
        end
		if(rad>=r1 & rad<=r2)
          	depth(i,j)=5.0+(rad-r1)*(20.0-5.0)/(r2-r1);
        end
   end
  end

  % set grid angle
  roms_angle=zeros(size(depth));

  % set masking
  mask_rho=ones(size(depth));
  dum=find(depth<0.1);
  mask_rho(dum)=0;
  
  % set coriolis f
  f=zeros(size(depth))+4.988e-5; %20N

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                 INITIAL CONDITION DEFINITION                    %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (make_InWave_ini || make_InWave_bnd )  

  Nbins= 20;                               % number of directional bins considered in the simulation
  Bindirs = [0:360/Nbins:360-360/Nbins];   % center angles of the directional bins.
  pd=ones(size(Bindirs)).*360./(Nbins);
  Bindirs_c = [0-(360/Nbins)/2:360/Nbins:360-360/Nbins+(360/Nbins)/2];

end  

if (make_InWave_ini)  
    
  ini_file=strcat(filepath,'InWave_ini.nc');  % name of the initial file

  Ac=ones(Nbins,Mm,Lm).*0;
  Cx=ones(Nbins,Mm,Lm-1).*0;
  Cy=ones(Nbins,Mm-1,Lm).*0;
  Ct=ones(Nbins+1,Mm,Lm).*0;
  
  Ac(16,:,:)=100;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                 BOUNDARY CONDITION DEFINITION                   %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (make_InWave_bnd)


  bnd_file=strcat(filepath,'InWave_bnd.nc');  % name of the boundary file

  % Duration of the simulation and time increment for the boundaries
  
  dt= 10;                % time increment for the boundaries (seconds)
  drtn= 3600*3;          % total duration of the simulation (seconds)

  time=[0:dt:drtn];
  
  % Specify by 1 the open boundary: S E N W
  obc=[0 0 0 1];

%    Nbins_bnd= 20;         % number of directional bins with energy at the boundaries
%    dir_bnd= Bindirs;      % center angle (degrees of the bin containing energy at the boudaries
 
 % Specify number of directions at the boundaries (we have to specify at
 % least 2)
 
  Nbins_bnd= 3;         % number of directional bins with energy at the boundaries
  dir_bnd= [252,270,288];         % center angle (degrees of the bin containing energy at the boudaries)

  if sum(ismember(dir_bnd,Bindirs)) ~= Nbins_bnd; 
  bin_error=1;
  else
  bin_error=0;
  end      

  if obc(1)==1
    Ac_north=zeros(length(time),Nbins_bnd,Lm);
  end
  if obc(2)==1
    Ac_east=zeros(length(time),Nbins_bnd,Mm);
  end
  if obc(3)==1
    Ac_south=zeros(length(time),Nbins_bnd,Lm);
  end
  if obc(4)==1
    Ac_west=zeros(length(time),Nbins_bnd,Mm);
    
    for i=1:Mm
    Ac_west(:,2,i)=100;
    end
    
  end

  if obc(1)==1
    TA_west=TA;
  end
  if obc(2)==1
    TA_east=TA;
  end
  if obc(3)==1
    TA_south=TA;
  end
  if obc(4)==1
    TA_north=TA;
  end

end



