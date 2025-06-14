load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
; References: Huang et al. 2010, Graham et al. 2014, Stevenson et al. 2017...
; Kim and Jin 2010
load "./func/replace_nan.ncl"
begin
diri = "/glade/derecho/scratch/chenxing/geog/heatbudget/"
diri2 = "/glade/derecho/scratch/chenxing/geog/"
diri4 =  "/glade/p/cesm/community/CESM-LE/data/CESM-CAM5-BGC-LE/ocn/proc/tseries/monthly/"
diri5 =  "/glade/p/cesm/community/CESM-LE/data/CESM-CAM5-BGC-LE/atm/proc/tseries/monthly/"
diri6 = "/glade/campaign/cgd/cesm/CESM2-LE/ocn/proc/tseries/month_1/"
diri_arise = "/glade/campaign/cesm/collections/ARISE-SAI-1.5/b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT"
diri_waccm = "/glade/campaign/cesm/collections/CESM2-WACCM-SSP245/b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM"
diri_glens = "/glade/campaign/cesm/collections/GLENS/"
diri_mcb = "/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245smbb.f09_g17.MCB-050PCT"
; diri_mcb = "/glade/derecho/scratch/chenxing/MCB/b.e21.BSSP245smbb.f09_g17.MCB-050PCT"
diri_cam_ssp = "/glade/campaign/cesm/development/cvcwg/cvwg/b.e21.BSSP245smbb.f09_g17/"

diri_cesm2_pi = "/glade/campaign/collections/cmip/CMIP6/timeseries-cmip6/b.e21.B1850.f09_g17.CMIP6-piControl.001/"
diri_waccm_pi = "/glade/campaign/collections/cmip/CMIP6/timeseries-cmip6/b.e21.BW1850.f09_g17.CMIP6-piControl.001/"
;b.e21.BHISTcmip6.f09_g17.LE2-1231.006.pop.h.TEMP.185001-185912.nc
;b.e21.BSSP370cmip6.f09_g17.LE2-1021.002.pop.h.TEMP.208501-209412.nc
; only ssp370 in CESM2-LE
; The first set of 50 ensemble members is denoted CMIP6, and the second set of
; 50 SMBB (with a smothing biomass burning; smbb)
; b.e21.BHISTcmip6.f09_g17.LE2-1301.006.cam.h0.TS.192001-192912.nc
; b.e21.BHISTsmbb.f09_g17.LE2-1251.018.cam.h0.TS.198001-198912.nc

; depth from surface to midpoint of layer (cm)
;  500.0       1500.       2500.       3500.       4500.       5500.
;  6500.       7500.       8500.       9500.      0.1050E+05  0.1150E+05
; 0.1250E+05  0.1350E+05  0.1450E+05  0.1550E+05  0.1651E+05  0.1755E+05
; 0.1863E+05  0.1977E+05  0.2097E+05  0.2226E+05  0.2364E+05  0.2514E+05
; 0.2677E+05  0.2855E+05  0.3051E+05  0.3269E+05  0.3511E+05  0.3782E+05
; 0.4088E+05  0.4434E+05  0.4827E+05  0.5277E+05  0.5794E+05  0.6389E+05
; 0.7076E+05  0.7870E+05  0.8788E+05  0.9847E+05  0.1106E+06  0.1245E+06
; 0.1400E+06  0.1574E+06  0.1764E+06  0.1969E+06  0.2186E+06  0.2414E+06
; 0.2649E+06  0.2889E+06  0.3133E+06  0.3380E+06  0.3628E+06  0.3876E+06
; 0.4126E+06  0.4375E+06  0.4625E+06  0.4875E+06  0.5125E+06  0.5375E+06


; Area Box
; maybe check 5-10 for meridional changes as well?
NLAT =  10.
SLAT = -10.
WLON =  90. ;210
ELON =  300.
;-- select lat/lon region
lons      =  (/ 0,  360/)
lats      =  (/ -90,  90/)

MODEL_NAME = (/"CESM2-WACCM","ARISE-SAI-1.5","CAM","MCB"/);"MCB" ; /) ; (/"GLENS","GLENS","CESM2","CESM2-WACCM"/) ; ;
diriall = (/diri_waccm,diri_arise,diri_cam_ssp,diri_mcb/);diri_mcb ;/); (/diri_glens,diri_glens,diri_cesm2_pi,diri_waccm_pi/); diri_arise
EXPA = (/"SSP245","SSP245","SSP245","SSP245"/) ;(/"feedback","control","piControl","piControl"/) ;"feedback" ; the first 50 ens or the last 50 ens

yrsa = (/2035,2035,2035,2035/);(/2020,2020,400,400 /);(/2035,2035,2035,2035 /);(/2015,2035,2020,2010 /);
; yrla = (/2069,2069,2069,2069,499,499 /);(/2069,2069,2069,2069 /)
yrla = yrsa + 34
;specify mixed layer depth or using the HMXL in the model
SPE_MX = True ;

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
locs = systemfunc("ls "+diri3+"*"+EXP+"*.TEMP.*.nc")
if(MODEL.eq."GLENS") then 
delete(locs)
diri3 = diri_glens+str_capital(EXP)+"/ocn/proc/tseries/monthly/TEMP/"
locs = systemfunc("ls "+diri3+"*"+EXP+"*.TEMP.202001*.nc")
end if 
if(EXP.eq."piControl") then 
delete(locs)
  diri3 = diria+"ocn/proc/tseries/month_1/"
  locs = systemfunc("ls "+diri3+"*"+EXP+"*.TEMP.*.nc")
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
  aa = str_split(locs_str(6), ".") ;6
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
  
  end if 
  end if 
  end if 
  end if 
  end if 
  end if 
print(MODEL+" ens "+ENSN)
delete([/aa,locs_str/])

if(MODEL.eq."GLENS") then 
locs1 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.TEMP.*.nc");+locs(ie))
locs2 = systemfunc("ls "+diri3+"../UVEL/*"+EXP+"*"+ENSN+"*.UVEL.*.nc");
locs3 = systemfunc("ls "+diri3+"../VVEL/*"+EXP+"*"+ENSN+"*.VVEL.*.nc");
locs4 = systemfunc("ls "+diri3+"../WVEL/*"+EXP+"*"+ENSN+"*.WVEL.*.nc");
; Mixed layer height
locs5 = systemfunc("ls "+diri3+"../HMXL/*"+EXP+"*"+ENSN+"*.HMXL.*.nc");
; Ocean Heat flux
;  Total Surface Heat Flux, Including SW
locs6 = systemfunc("ls "+diri3+"../SHF/*"+EXP+"*"+ENSN+"*.SHF.*.nc");
; Solar Short-Wave Heat Flux
locs7 = systemfunc("ls "+diri3+"../SHF_QSW/*"+EXP+"*"+ENSN+"*.SHF_QSW.*.nc");

else
if(MODEL.eq."MCB".and.ENSN.eq."011") then 
locs1 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.TEMP.*203501-206912.nc");+locs(ie))
locs2 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.UVEL.*203501-206912.nc");
locs3 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.VVEL.*203501-206912.nc");
locs4 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.WVEL.*203501-206912.nc");
; Mixed layer height
locs5 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.HMXL.*203501-206912.nc");
; Ocean Heat flux
;  Total Surface Heat Flux, Including SW
locs6 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.SHF.*203501-206912.nc");
; Solar Short-Wave Heat Flux
locs7 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.SHF_QSW.*203501-206912.nc");

else
locs1 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.TEMP.*.nc");+locs(ie))
locs2 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.UVEL.*.nc");
locs3 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.VVEL.*.nc");
locs4 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.WVEL.*.nc");
; Mixed layer height
locs5 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.HMXL.*.nc");
; Ocean Heat flux
;  Total Surface Heat Flux, Including SW
locs6 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.SHF.*.nc");
; Solar Short-Wave Heat Flux
locs7 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.SHF_QSW.*.nc");
end if 
end if 

f1   = addfiles(locs1, "r")  ;multiple files
ListSetType (f1, "cat")        ; concatenate (=default)

f2   = addfiles(locs2, "r")  ;multiple files
ListSetType (f2, "cat")        ; concatenate (=default)

f3   = addfiles(locs3, "r")  ;multiple files
ListSetType (f3, "cat")        ; concatenate (=default)

f4   = addfiles(locs4, "r")  ;multiple files
ListSetType (f4, "cat")        ; concatenate (=default)

f5   = addfiles(locs5, "r")  ;multiple files
ListSetType (f5, "cat")        ; concatenate (=default)

f6   = addfiles(locs6, "r")  ;multiple files
ListSetType (f6, "cat")        ; concatenate (=default)

f7   = addfiles(locs7, "r")  ;multiple files
ListSetType (f7, "cat")        ; concatenate (=default)

print(locs1)
print(locs2)
print(locs3)
print(locs4)
print(locs5)


TIME2=f3[:]->time
yyyymm2=cd_calendar(TIME2, -1)
printMinMax(yyyymm2, True)

ymstrts = ind(yyyymm2.eq.ymstrt)
ymlasts = ind(yyyymm2.eq.ymlast)
print(ymstrts+" <--start end--> "+ymlasts)
delete([/TIME2,yyyymm2/])


; use this way is due to pop variables lack of coordinates info but only stored in their files
; ref: https://www.dkrz.de/up/services/analysis/visualization/sw/ncl/examples/source_code/dkrz-ncl-plot-a-sub-region-of-curvilinear-data-example
lon2d     =  f1[:]->TLONG
lat2d     =  f1[:]->TLAT

;-- you cannot use "{" and "}" for coordinate subscripting, because
;-- lat2d and lon2d are not 1D coordinate arrays
ij        =  getind_latlon2d(lat2d, lon2d, lats, lons) ;-- retrieve indices of sub-region
print(ij)
ilat1     =  ij(0,0)                                  ;-- indices min lat
ilat2     =  ij(1,0)                                  ;-- indices max lat
ilon1     =  ij(0,1)                                  ;-- indices min lon
ilon2     =  ij(1,1)                                  ;-- indices max lon
print(ilat1+" "+ilat2+" "+ilon1+" "+ilon2)

; Read files (Ocean Temperature: temp; Ocean Zonal current: u; Ocean meridional
; current: v; Ocean vertical motion: w)
hmxl  = f5[:]->HMXL(ymstrts:ymlasts,:,:);ilat1:ilat2,ilon1:ilon2);ind_slat:ind_nlat,ind_wlon:ind_elon);{SLAT:NLAT},{WLON:ELON}) ;
printVarSummary(hmxl)
shf  = f6[:]->SHF(ymstrts:ymlasts,:,:);ilat1:ilat2,ilon1:ilon2)
shf_qsw  = f7[:]->SHF_QSW(ymstrts:ymlasts,:,:);ilat1:ilat2,ilon1:ilon2)
uo  = f2[:]->UVEL(ymstrts:ymlasts,:10,:,:);ilat1:ilat2,ilon1:ilon2);ind_slat:ind_nlat,ind_wlon:ind_elon);{SLAT:NLAT},{WLON:ELON})
printVarSummary(uo)
temp  = f1[:]->TEMP(ymstrts:ymlasts,:10,:,:);ilat1:ilat2,ilon1:ilon2);;ind_slat:ind_nlat,ind_wlon:ind_elon);{SLAT:NLAT},{WLON:ELON})
printMinMax(temp,0)
printVarSummary(temp)
vo  = f3[:]->VVEL(ymstrts:ymlasts,:10,:,:);ilat1:ilat2,ilon1:ilon2);ind_slat:ind_nlat,ind_wlon:ind_elon);{SLAT:NLAT},{WLON:ELON})
printVarSummary(vo)
wo  = f4[:]->WVEL(ymstrts:ymlasts,:10,:,:);ilat1:ilat2,ilon1:ilon2);ind_slat:ind_nlat,ind_wlon:ind_elon);{SLAT:NLAT},{WLON:ELON})

TLAT = lat2d(ilat1:ilat2,ilon1:ilon2)
TLONG = lon2d(ilat1:ilat2,ilon1:ilon2)
;seems useless
temp@lon2d   = TLONG
temp@lat2d   = TLAT
uo@lon2d   = TLONG
uo@lat2d   = TLAT
vo@lon2d   = TLONG
vo@lat2d   = TLAT
wo@lon2d   = TLONG
wo@lat2d   = TLAT

; remap files are in /glade/p/cesm/cseg/ncl

;;;; hasn't upload map of gx1v7 for CESM2... don't know whether can version 6 be used
u_remap       = PopLatLon(uo,"gx1v6","1x1d","bilin","da","100716")
v_remap       = PopLatLon(vo,"gx1v6","1x1d","bilin","da","100716")
w_remap       = PopLatLon(wo,"gx1v6","1x1d","bilin","da","100716")
hmxl_remap    = PopLatLon(hmxl,"gx1v6","1x1d","bilin","da","100716")
temp_remap    = PopLatLon(temp,"gx1v6","1x1d","bilin","da","100716")
shf_remap     = PopLatLon(shf,"gx1v6","1x1d","bilin","da","100716")
shf_qsw_remap = PopLatLon(shf_qsw,"gx1v6","1x1d","bilin","da","100716")

u_remap        = replace_nan(u_remap        )
v_remap        = replace_nan(v_remap        )
w_remap        = replace_nan(w_remap        )
hmxl_remap     = replace_nan(hmxl_remap     )
temp_remap     = replace_nan(temp_remap     )
shf_remap      = replace_nan(shf_remap      )
shf_qsw_remap  = replace_nan(shf_qsw_remap )


u1 = u_remap(:,:,{SLAT:NLAT},{WLON:ELON})
v1 = v_remap(:,:,{SLAT:NLAT},{WLON:ELON})
w1 = w_remap(:,:,{SLAT:NLAT},{WLON:ELON})
temp1 = temp_remap(:,:,{SLAT:NLAT},{WLON:ELON})
hmxl1 = hmxl_remap(:,{SLAT:NLAT},{WLON:ELON})
shf1 = shf_remap(:,{SLAT:NLAT},{WLON:ELON})
shf_qsw1 = shf_qsw_remap(:,{SLAT:NLAT},{WLON:ELON})
printVarSummary(temp1)
printVarSummary(hmxl1)
delete([/u_remap, v_remap  ,w_remap  ,hmxl_remap  ,temp_remap  ,shf_remap,shf_qsw_remap /])
delete([/uo, vo  ,wo  ,hmxl  ,temp  ,shf,shf_qsw /])

; ps: no coordinates info in them

;---------Extract portions in or on Mixed Layer-------------------------
;
dep_height = conform_dims(dimsizes(u1),u1&z_t,1)
hmxl_expand = conform_dims(dimsizes(u1),hmxl1,(/0,2,3/));6500;

if (SPE_MX) then
  u_mld = dim_avg_n_Wrap(u1(:,{0:8000},:,:),1) ;{0:8000}
  v_mld = dim_avg_n_Wrap(v1(:,{0:8000},:,:),1)
  w_mld = dim_avg_n_Wrap(w1(:,{0:8000},:,:),1)
  temp_mld = dim_avg_n_Wrap(temp1(:,{0:8000},:,:),1)
  u_sub = u1(:,{9000},:,:) ;{9000}
  v_sub = v1(:,{9000},:,:)
  w_sub = w1(:,{9000},:,:)
  temp_sub = temp1(:,{9000},:,:)

else
  u_mld = dim_avg_n_Wrap(where(dep_height.le.hmxl_expand,u1,u1@_FillValue),1)
  u_sub = dim_avg_n_Wrap(where(dep_height.gt.hmxl_expand.and.dep_height.le.hmxl_expand+1000,u1,u1@_FillValue),1)
  v_mld = dim_avg_n_Wrap(where(dep_height.le.hmxl_expand,v1,v1@_FillValue),1)
  v_sub = dim_avg_n_Wrap(where(dep_height.gt.hmxl_expand.and.dep_height.le.hmxl_expand+1000,v1,v1@_FillValue),1)
  w_mld = dim_avg_n_Wrap(where(dep_height.le.hmxl_expand,w1,w1@_FillValue),1)
  w_sub = dim_avg_n_Wrap(where(dep_height.gt.hmxl_expand.and.dep_height.le.hmxl_expand+1000,w1,w1@_FillValue),1)
  temp_mld = dim_avg_n_Wrap(where(dep_height.le.hmxl_expand,temp1,temp1@_FillValue),1)
  temp_sub = dim_avg_n_Wrap(where(dep_height.gt.hmxl_expand.and.dep_height.le.hmxl_expand+1000,temp1,temp1@_FillValue),1)

end if
printVarSummary(u_mld)
printVarSummary(u_sub)

copy_VarMeta(u1(:,0,:,:),u_mld)
copy_VarMeta(u1(:,0,:,:),u_sub)
copy_VarMeta(v1(:,0,:,:),v_mld)
copy_VarMeta(v1(:,0,:,:),v_sub)
copy_VarMeta(w1(:,0,:,:),w_mld)
copy_VarMeta(w1(:,0,:,:),w_sub)
copy_VarMeta(temp1(:,0,:,:),temp_mld)
copy_VarMeta(temp1(:,0,:,:),temp_sub)
delete([/hmxl_expand,dep_height/])

;------output files--------------
;  Variables averaged in mixed layer and just below mixed layer
fon=diri+MODEL+"_"+EXP+"."+ENSN+"_heatbudget_var_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc";
system("rm -f "+fon)
fo=addfile(fon,"c")
fo->u_mld = u_mld
fo->v_mld = v_mld
fo->w_mld = w_mld
fo->t_mld = temp_mld
fo->u_sub = u_sub
fo->v_sub = v_sub
fo->w_sub = w_sub
fo->t_sub = temp_sub
fo->hmxl = hmxl1
fo->shf = shf1
fo->shf_qsw = shf_qsw1
; fo->TLAT = TLAT
; fo->TLONG = TLONG

delete([/temp1,u1,v1,w1,hmxl1,shf1,shf_qsw1 /]);tempa,ua,va,wa,tempc,uc,vc,wc,
delete([/u_mld,u_sub,v_mld,v_sub,w_mld,w_sub,temp_mld,temp_sub/])
delete([/locs1,locs2,locs3,locs4,locs5,f1,f2,f3,f4,f5,locs6,locs7/])
delete([/lon2d,lat2d/])
end do
delete([/locs/])
end do

end
