; Warm water volume (WWV) defined as the integral of warm water above 20°C isotherm depth, D20
; Here we use the whole basin wide 5S–5N, 120E–80W
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "./func/replace_nan.ncl"
begin

diri = "/glade/work/chenxing/geog/"
dirip = "/glade/u/home/chenxing/geog/"

diri1 = "/glade/work/chenxing/geog/E3SM/"
diri2 = "/gpfs/fs1/collections/cdg/data/CLIVAR_LE/"

diri_cesm1 = "/glade/campaign/cesm/collections/cesmLE/CESM-CAM5-BGC-LE/"
diri_cesm2 = "/glade/campaign/cgd/cesm/CESM2-LE/"

diri_arise = "/glade/campaign/cesm/collections/ARISE-SAI-1.5/b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT"
diri_waccm = "/glade/campaign/cesm/collections/CESM2-WACCM-SSP245/b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM"
diri_glens = "/glade/campaign/cesm/collections/GLENS/"
diri_cesm2_pi = "/glade/campaign/collections/cmip/CMIP6/timeseries-cmip6/b.e21.B1850.f09_g17.CMIP6-piControl.001/"
diri_waccm_pi = "/glade/campaign/collections/cmip/CMIP6/timeseries-cmip6/b.e21.BW1850.f09_g17.CMIP6-piControl.001/"

; diri_mcb = "/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245smbb.f09_g17.MCB-050PCT"
diri_mcb = "/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245smbb.f09_g17.MCB-050PCT"
;/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245smbb.f09_g17.MCB-050PCT.002/atm/proc/tseries/month_1
;b.e21.BSSP245smbb.f09_g17.MCB-050PCT.002.cam.h0.U.203501-206912.nc
diri_cam_ssp = "/glade/campaign/cesm/development/cvcwg/cvwg/b.e21.BSSP245smbb.f09_g17/"
diri_walkermcb = "/glade/work/chenxing/geog/MCB/Walker_MCB/"

MODEL_NAME = (/"MCB-feed","MCB-feed"/) 
diriall = (/diri_walkermcb,diri_walkermcb/)
EXPA = (/"MCB-feedback-1DOF","MCB-feedforward-1DOF"/)

; MODEL_NAME = (/"CAM" ,"MCB","CESM2-WACCM","ARISE-SAI-1.5","CESM2","CESM2-WACCM"/);  ;(/"CESM2","CESM2-WACCM"/) ;(/"CESM2-WACCM","ARISE-SAI-1.5","GLENS","GLENS"/) ; ;
; diriall = (/diri_cam_ssp, diri_mcb,diri_waccm,diri_arise,diri_cesm2_pi,diri_waccm_pi/);diri_cesm1 ;(/diri_cam_ssp, diri_mcb/) ;  ;(/diri_cesm2_pi,diri_waccm_pi/)  ;(/diri_waccm,diri_arise,diri_glens,diri_glens/); diri_arise
; EXPA = (/"SSP245" ,"SSP245","SSP245" ,"SSP245","piControl","piControl"/) ; ;(/"piControl","piControl"/) ;(/"SSP245","SSP245","feedback","control"/) ;"feedback" ; the first 50 ens or the last 50 ens

VAR = "TEMP" ;"PRECC" ;"PRECT" ; CESM1 doesn't have PRECT?
LONGNAME = "WWV" ;"nino3pr" ;"zonalgradient" ;"nino4" ; "merigradient" ;"nino3pr" ;

yrsa = (/2035,2035,2035,2035,1,1/);400;(/2035,2035/);  (/1,1/); (/2015,2035,2020,2010 /);
yrla = (/2069,2069,2069,2069,499,499/);2100;yrsa+34 ;2069; (/499,499/); (/2069,2069,2099,2097 /)

NLAT =  5.
SLAT = -5.
WLON =  120. 
ELON =  360.-80.

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

    diri3 = diria+"*/ocn/proc/tseries/month_1/"

  ; b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM.010.cam.h0.TS.201501-206412.nc
  ; b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT.001.cam.h0.TS.203501-206912.nc
  locs = systemfunc("ls "+diri3+"*"+EXP+"*."+VAR+".*.nc")
if(MODEL.eq."GLENS") then 
delete(locs)
  diri3 = diri_glens+str_capital(EXP)+"/ocn/proc/tseries/monthly/"+VAR+"/"
  locs = systemfunc("ls "+diri3+"*"+EXP+"*."+VAR+".202001*.nc")
end if 
if(EXP.eq."piControl") then 
delete(locs)
  if(MODEL.eq."CESM1") then 
    diri3 = diria+"ocn/proc/tseries/monthly/"
    locs = systemfunc("ls "+diri3+VAR+"/*B1850C5CN*."+VAR+"*.nc")
  else 
    diri3 = diria+"ocn/proc/tseries/month_1/"
    locs = systemfunc("ls "+diri3+"*"+EXP+"*."+VAR+"*.nc")
  end if 
end if 


if (MODEL.eq."MCB-feed") then
  delete(locs)
    diri3 = diria
    locs = systemfunc("ls "+diri3+"*."+EXP+".*."+VAR+".*.nc")
end if 

  printVarSummary(locs)
  print(locs)
  nsa = dimsizes(locs)


istart = 0
do ie = istart,nsa-1

 locs_str = str_split(locs(ie), "/")
 print("'" + locs_str + "'")
 aa = str_split(locs_str(5), ".")
 print(aa)
 if(MODEL.eq."ARISE-SAI-1.5") then 
  ENSN  = aa(5)
  else if (MODEL.eq."MCB") then 
  delete(aa)
  aa = str_split(locs_str(6), ".")
  ENSN  = aa(5)

 else if(MODEL.eq."CESM2-WACCM".and.EXP.eq."SSP245")
  ENSN  = aa(6)
  else if(MODEL.eq."GLENS")
  delete(aa)
  aa = str_split(locs_str(11), ".")
  ENSN  = aa(5)
  else if(EXP.eq."piControl")
  ENSN  = "001"
  else if(MODEL.eq."CAM".and.EXP.eq."SSP245")
  delete(aa)
  aa = str_split(locs_str(7), ".")
  ENSN  = aa(4)
  else if (MODEL.eq."MCB-feed") then
  delete(aa)
  aa = str_split(locs_str(6), ".")
  ENSN  = aa(5)
 
  end if 
  end if 
  end if 
  end if 
  end if 
  end if 
  end if 
  print(ENSN)

print(MODEL+" ens "+ENSN)
delete([/aa,locs_str/])

; ;;;!!!! Be cautious
; ;;; temproally unknown problem in data (no variable in it)
; ;;;;;;;;;;;;;
; if(ENSN.eq."LE2-1191.010") then
;   continue
; end if

if (MODEL.eq."CAM".and.EXP.eq."SSP245".and.VAR.eq."PRECT") then 
fils = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*."+VAR+".201501-206412.nc "+diri3+"*"+EXP+"*"+ENSN+"*."+VAR+".206501-210012.nc");
else 
if(MODEL.eq."CESM1".and.EXP.eq."piControl") then 
  fils = systemfunc("ls "+diri3+VAR+"/*B1850C5CN*."+VAR+".*.nc");
else
if(MODEL.eq."MCB".and.ENSN.eq."011") then 
fils = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*."+VAR+".*203501-206912.nc");
else
  fils = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*."+VAR+".*.nc");
end if 
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


; use this way is due to pop variables lack of coordinates info but only stored in their files
; ref: https://www.dkrz.de/up/services/analysis/visualization/sw/ncl/examples/source_code/dkrz-ncl-plot-a-sub-region-of-curvilinear-data-example
lon2d     =  f[:]->TLONG
lat2d     =  f[:]->TLAT

;-- you cannot use "{" and "}" for coordinate subscripting, because
;-- lat2d and lon2d are not 1D coordinate arrays
ij        =  getind_latlon2d(lat2d, lon2d, lats, lons) ;-- retrieve indices of sub-region
print(ij)
ilat1     =  ij(0,0)                                  ;-- indices min lat
ilat2     =  ij(1,0)                                  ;-- indices max lat
ilon1     =  ij(0,1)                                  ;-- indices min lon
ilon2     =  ij(1,1)                                  ;-- indices max lon
print(ilat1+" "+ilat2+" "+ilon1+" "+ilon2)


xx  = f[:]->$VAR$(ymstrts:ymlasts,{:30000},:,:)
printVarSummary(xx)

TLAT = lat2d(ilat1:ilat2,ilon1:ilon2)
TLONG = lon2d(ilat1:ilat2,ilon1:ilon2)
;seems useless
xx@lon2d   = TLONG
xx@lat2d   = TLAT

; remap files are in /glade/p/cesm/cseg/ncl

;;;; hasn't upload map of gx1v7 for CESM2... don't know whether can version 6 be used
x_remap       = PopLatLon(xx,"gx1v6","1x1d","bilin","da","100716")

x_remap        = replace_nan(x_remap        )

x1 = x_remap(:,:,{SLAT:NLAT},{WLON:ELON})

delete([/xx,x_remap,lon2d,lat2d/])
delete([/fils,f,TIME2,yyyymm2/])
printVarSummary(x1)

;----------------------------------------------------------------
; Find i20 level

if (x1@units.eq."K") then 
    x1 = x1 - 273.15
    x1@units = "degC"
end if 

TARGET_temp = 20.; find 20 degree C level

ndim = dimsizes(x1)

x2 = x1
x2 = 0. ; wgt_vertical_n no missing data allowed
levels = x1&z_t 
print(levels)
l2 = x1(:,0,:,:)
l2 = 0. 

do it = 0,ndim(0)-1
do ix = 0,ndim(2)-1
do iy = 0,ndim(3)-1
    i20level_ind = minind(abs(x1(it,:,ix,iy)-TARGET_temp))
    ; print(i20level_ind+"")
    if(.not.ismissing(i20level_ind)) then
        x2(it,:i20level_ind,ix,iy) = x1(it,:i20level_ind,ix,iy)
        l2(it,ix,iy) = levels(i20level_ind)
    end if 
    delete(i20level_ind)
end do 
end do 
end do 
printVarSummary(x2)

l2 = l2 / 100. ; from cm to m
l2@units = "m"
printVarSummary(l2)
delete([/levels/])

; ; depth thickness between layers
; aa = levels(1:) - levels(:dimsizes(levels)-2)
; bb = array_append_record (levels(0)-0, aa, 0)
; print(bb)

; bb = bb / 100. ; from cm to m
; bb@units = "m"


; dp = conform(x2,bb,1)
; vopt  = 1     ; vertically weighted sum (integral)
; xp  = wgt_vertical_n(x2, dp, vopt, 1)
; copy_VarCoords(x1(:,0,:,:),xp)

; delete([/aa,bb,levels/])
;-------------------------
; Calculating index
; 

  lat = x1&lat 
  lon = x1&lon 

  re   = 6.37122e06 ;earth radius (m)
  rad  = 4.0 * atan(1.0) / 180.
  con  = re * rad    ; The length of one degree on the equator, which is around 111,139 meters      
  clat = cos(lat * rad)           ; cosine of latitude
  
  ; resolutions
  dlon = (lon(2) - lon(1))        ; assume dlon is constant
  dlat = (lat(2) - lat(1))        ; assume dlat is constant

  dx   = con * dlon * clat        ; dx at each latitude
  dy   = con * dlat               ; dy is constant
  dydx = dy * dx                  ; dydx(nlat) area
  
  wgt  = new((/dimsizes(lat), dimsizes(lon)/), typeof(l2))
  wgt  = conform(wgt, dydx, 0)
  
  ; xSum = wgt_areasum2(xp, wgt, 0) 
  xSum = wgt_areasum2(l2, wgt, 0) 

  xSum@long_name = LONGNAME 
  xSum@units = "m^3" 

  printVarSummary(xSum)
  delete([/lat,lon,clat,dx,dy,wgt/])

  copy_VarCoords(x1(:,0,0,0),xSum)
;--------output-------------
fon=diri+"cesm/"+xSum@long_name+"/"+MODEL+"_"+EXP+"."+ENSN+"_"+xSum@long_name+"_"+yrs+"-"+yrl+".nc";
system("rm -f "+fon)
fo=addfile(fon,"c")
fo->index = xSum

delete([/x1,l2,xSum/]);xp

end do
delete([/ENSN,locs /]);gmst2,
end do
end
