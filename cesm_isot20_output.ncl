; Thermocline depth: 20°C isotherm dept

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "./func/replace_nan.ncl"
begin

diri = "/glade/work/chenxing/geog/"
dirip = "/glade/u/home/chenxing/geog/"
diris = "/glade/derecho/scratch/chenxing/geog/"

diri1 = "/glade/work/chenxing/geog/E3SM/"
diri2 = "/gpfs/fs1/collections/cdg/data/CLIVAR_LE/"

diri_cesm1 = "/glade/campaign/cesm/collections/cesmLE/CESM-CAM5-BGC-LE/"
diri_cesm2 = "/glade/campaign/cgd/cesm/CESM2-LE/"

diri_arise = "/glade/campaign/cesm/collections/ARISE-SAI-1.5/b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT"
diri_waccm = "/glade/campaign/cesm/collections/CESM2-WACCM-SSP245/b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM"
diri_glens = "/glade/campaign/cesm/collections/GLENS/"
diri_cesm2_pi = "/glade/campaign/collections/cmip/CMIP6/timeseries-cmip6/b.e21.B1850.f09_g17.CMIP6-piControl.001/"
diri_waccm_pi = "/glade/campaign/collections/cmip/CMIP6/timeseries-cmip6/b.e21.BW1850.f09_g17.CMIP6-piControl.001/"

diri_mcb = "/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245smbb.f09_g17.MCB-050PCT"
; diri_mcb = "/glade/scratch/chenxing/MCB/b.e21.BSSP245smbb.f09_g17.MCB-050PCT"
;/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245smbb.f09_g17.MCB-050PCT.002/atm/proc/tseries/month_1
;b.e21.BSSP245smbb.f09_g17.MCB-050PCT.002.cam.h0.U.203501-206912.nc
diri_cam_ssp = "/glade/campaign/cesm/development/cvcwg/cvwg/b.e21.BSSP245smbb.f09_g17/"

MODEL_NAME = (/"CAM" ,"MCB","CESM2-WACCM","ARISE-SAI-1.5","CESM2","CESM2-WACCM"/);  ;(/"CESM2","CESM2-WACCM"/) ;(/"CESM2-WACCM","ARISE-SAI-1.5","GLENS","GLENS"/) ; ;
diriall = (/diri_cam_ssp, diri_mcb,diri_waccm,diri_arise,diri_cesm2_pi,diri_waccm_pi/);diri_cesm1 ;(/diri_cam_ssp, diri_mcb/) ;  ;(/diri_cesm2_pi,diri_waccm_pi/)  ;(/diri_waccm,diri_arise,diri_glens,diri_glens/); diri_arise
EXPA = (/"SSP245" ,"SSP245","SSP245" ,"SSP245","piControl","piControl"/) ; ;(/"piControl","piControl"/) ;(/"SSP245","SSP245","feedback","control"/) ;"feedback" ; the first 50 ens or the last 50 ens

VAR = "TEMP" ;"PRECC" ;"PRECT" ; CESM1 doesn't have PRECT?
ATMorOCN = "ocn"

yrsa = (/2035,2035,2035,2035,1,1/);400;(/2035,2035/);  (/1,1/); (/2015,2035,2020,2010 /);
yrla = (/2069,2069,2069,2069,499,499/);2100;yrsa+34 ;2069; (/499,499/); (/2069,2069,2099,2097 /)

NLAT = 90.
SLAT = 90.
WLON = 0. 
ELON = 360.

;-- select lat/lon region
lons      =  (/ 0,  360/)
lats      =  (/ -90,  90/)

nm = dimsizes(MODEL_NAME)

do im = 0,nm-1
EXP = EXPA(im)
MODEL = MODEL_NAME(im)
diria = diriall(im)
yrs = yrsa(im)
yrl = yrla(im)
ymstrt = yrs*100+2
ymlast = (yrl+1)*100+1

  
; b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM.010.cam.h0.TS.201501-206412.nc
; b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT.001.cam.h0.TS.203501-206912.nc
if(MODEL.eq."ARISE-SAI-1.5") then 
dirit = diri_arise+"*/"+ATMorOCN+"/proc/tseries/month_1/"
locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR+".*203501*.nc")
else if(MODEL.eq."CESM2-WACCM".and.EXP.ne."piControl")
dirit = diri_waccm+"*/"+ATMorOCN+"/proc/tseries/month_1/"
locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR+".206501*.nc")
else if(MODEL.eq."GLENS")
dirit = diri_glen+str_capital(EXP)+"/"+ATMorOCN+"/proc/tseries/monthly/"+VAR+"/"
locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR+".202001*.nc")
else if(MODEL.eq."MCB")
dirit = diri_mcb+"*/"+ATMorOCN+"/proc/tseries/month_1/"
locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR+".*203501*.nc")
else if(MODEL.eq."CAM")
dirit = diri_cam_ssp+"*/"+ATMorOCN+"/proc/tseries/month_1/"
locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR+".*206412.nc")
end if 
end if 
end if 
end if 
end if 

if(EXP.eq."piControl") then 
if(MODEL.eq."CESM1") then 
dirit = diria+""+ATMorOCN+"/proc/tseries/monthly/"
locs = systemfunc("ls "+dirit+VAR+"/*B1850C5CN*."+VAR+"*.nc")
else 
dirit = diria+""+ATMorOCN+"/proc/tseries/month_1/"
locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR+"*000101*.nc")
end if 
end if 


  printVarSummary(locs)
  print(locs)
  nsa = dimsizes(locs)


istart = 0
do ie = istart,nsa-1

 
locs_str0 = str_split(locs(ie), "/")
locs_str = str_split(locs_str0(5), ".")
print("'" + locs_str + "'")
if(MODEL.eq."ARISE-SAI-1.5") then 
  ENSN  = locs_str(5)
else if (MODEL.eq."MCB") then 
delete(locs_str)
locs_str = str_split(locs_str0(6), ".")
ENSN  = locs_str(5)
else if(MODEL.eq."CESM2-WACCM".and.EXP.ne."piControl")
  ENSN  = locs_str(6)
else if(MODEL.eq."GLENS")
delete(locs_str)
locs_str = str_split(locs_str0(11), ".")
ENSN  = locs_str(5)
else if(EXP.eq."piControl")
ENSN  = "001"
else if(MODEL.eq."CAM".and.EXP.eq."SSP245")
delete(locs_str)
locs_str = str_split(locs_str0(7), ".")
ENSN  = locs_str(4)
end if
end if
end if 
end if 
end if 
end if 

  delete([/locs_str0,locs_str/])

  if(ENSN.eq."011".and.MODEL.eq."MCB")then
  continue
  end if  

  if (MODEL.eq."CAM".and.EXP.eq."SSP245".and.(VAR.eq."PRECC".or.VAR.eq."FSNT".or.VAR.eq."FLNT")) then 
  fils = systemfunc("ls "+dirit+"*"+EXP+"*"+ENSN+"*."+VAR+".201501-206412.nc "+dirit+"*"+EXP+"*"+ENSN+"*."+VAR+".206501-210012.nc");
  else 
    if(MODEL.eq."CESM1".and.EXP.eq."piControl") then 
    fils = systemfunc("ls "+dirit+VAR+"/*B1850C5CN*."+VAR+".*.nc");
    else 
    fils = systemfunc("ls "+dirit+"*"+EXP+"*"+ENSN+"*."+VAR+".*.nc")
    end if 
  end if 
  print(fils)
  f   = addfiles(fils, "r")  ;multiple files
  ListSetType (f, "cat")        ; concatenate (=default)

TIME2=f[:]->time
yyyymm2=cd_calendar(TIME2, -1)
printMinMax(yyyymm2, True)
ymstrts = ind(yyyymm2.eq.ymstrt)
ymlasts = ind(yyyymm2.eq.ymlast)
print(ymstrts+" <--start end--> "+ymlasts)


x  = f[:]->$VAR$(ymstrts:ymlasts,{:40000},:,:)
printVarSummary(x)
z_t = x&z_t ;cm
z_t = z_t/100
z_t@units = "m"

;************************************************
; Interpolate to specific [constant] TEMP levels
; The default returned vertical coordinate is Z_T but change to 'tlev'
;************************************************

if (x@units.eq."K") then 
    x = x - 273.15
    x@units = "degC"
end if 

tlev    = 20    ; same units [here, C] as TEMP
tlev@units = x@units
tlev!0     = "tlev"

depth   = conform(x, z_t, 1)
copy_VarCoords(x, depth)
printVarSummary(depth)

isot0    = int2p_n_Wrap(x,depth, tlev, 0, 1)
printVarSummary(isot0) 
printMinMax(isot0, True) 

;----------------------------------------------------------------
; ; use this way is due to pop variables lack of coordinates info but only stored in their files
; ; ref: https://www.dkrz.de/up/services/analysis/visualization/sw/ncl/examples/source_code/dkrz-ncl-plot-a-sub-region-of-curvilinear-data-example
; lon2d     =  f[:]->TLONG
; lat2d     =  f[:]->TLAT

; ;-- you cannot use "{" and "}" for coordinate subscripting, because
; ;-- lat2d and lon2d are not 1D coordinate arrays
; ij        =  getind_latlon2d(lat2d, lon2d, lats, lons) ;-- retrieve indices of sub-region
; print(ij)
; ilat1     =  ij(0,0)                                  ;-- indices min lat
; ilat2     =  ij(1,0)                                  ;-- indices max lat
; ilon1     =  ij(0,1)                                  ;-- indices min lon
; ilon2     =  ij(1,1)                                  ;-- indices max lon
; print(ilat1+" "+ilat2+" "+ilon1+" "+ilon2)


; TLAT = lat2d(ilat1:ilat2,ilon1:ilon2)
; TLONG = lon2d(ilat1:ilat2,ilon1:ilon2)
; ;seems useless
; x@lon2d   = TLONG
; x@lat2d   = TLAT

; remap files are in /glade/p/cesm/cseg/ncl

;;;; hasn't upload map of gx1v7 for CESM2... don't know whether can version 6 be used
x_remap       = PopLatLon(isot0,"gx1v6","1x1d","bilin","da","100716")

x_remap        = replace_nan(x_remap        )

isot = x_remap(:,0,:,:);{SLAT:NLAT},{WLON:ELON})
copy_VarMeta(x_remap(:,0,:,:),isot)
delete([/x_remap/]) ;,lon2d,lat2d

isot0@units = "m"
isot@long_name = tlev+" C isothem depth"

printVarSummary(isot)
;--------output-------------
fon=diri+"cesm/isot"+tlev+"/"+MODEL+"_"+EXP+"."+ENSN+"_isot"+tlev+"_"+yrs+"-"+yrl+".nc";
system("rm -f "+fon)
fo=addfile(fon,"c")
fo->isot = isot

delete([/x,isot,isot0,depth/])
delete([/fils,f,TIME2,yyyymm2/])

end do
delete([/ENSN,locs /]);gmst2,
end do
end
