load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "./func/hb_atm_terms_el.ncl"
load "./func/hb_atm_terms_extreme_el.ncl"
; load "./func/get_anom_moving_climo.ncl"
load "./func/get_moving_climo.ncl"
load "./func/hb_atm_terms_la.ncl"
load "./func/replace_nan.ncl"
begin
diri = "/glade/derecho/scratch/chenxing/geog/heatbudget/"
dirip = "/glade/work/chenxing/geog/"
diri2 = "/glade/derecho/scratch/chenxing/geog/"
diri4 =  "/glade/p/cesm/community/CESM-LE/data/CESM-CAM5-BGC-LE/ocn/proc/tseries/monthly/"
diri5 =  "/glade/p/cesm/community/CESM-LE/data/CESM-CAM5-BGC-LE/atm/proc/tseries/monthly/"
diri6 = "/glade/campaign/cgd/cesm/CESM2-LE/ocn/proc/tseries/month_1/"
diri_arise = "/glade/campaign/cesm/collections/ARISE-SAI-1.5/b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT"
diri_waccm = "/glade/campaign/cesm/collections/CESM2-WACCM-SSP245/b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM"
diri_glens = "/glade/campaign/cesm/collections/GLENS/"
diri_mcb = "/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245smbb.f09_g17.MCB-050PCT"
diri_cam_ssp = "/glade/campaign/cesm/development/cvcwg/cvwg/b.e21.BSSP245smbb.f09_g17/"
diri_cesm2_pi = "/glade/campaign/collections/cmip/CMIP6/timeseries-cmip6/b.e21.B1850.f09_g17.CMIP6-piControl.001/"
diri_waccm_pi = "/glade/campaign/collections/cmip/CMIP6/timeseries-cmip6/b.e21.BW1850.f09_g17.CMIP6-piControl.001/"

PI  = get_pi("float" )   ; type float ; 3.141593
RE = 6378388
C_TIME_MO_S = 30.*24.*3600. ;s --> mon
rho=1025;      ; Mean density of seawater at 20C, 35 psu: kg/m^2
cp=3993;       ; Specific heat of seawater at 20C, 35 psu, J/kg/K
lamda = rho*cp;and*hmxl ;1000.*4000.*dep   ;density*Cp*depth?!

; Area Box
; maybe check 5-10 for meridional changes as well?
NLAT =  10.
SLAT = -10.
WLON = 90.
ELON = 300. 

;specify mixed layer depth or using the HMXL in the model
SPE_MX = False ;

; High pass filter
FILTER = False

; Calculate not El Nino years or yes
NOTENSOYEAR = False ;True ;
; Use climatology based on historical run; mostly for the initial transition phase analysis
CLIMATE_HIST = False ; True ;False ; 

MODEL_NAME = (/"CESM2-WACCM","ARISE-SAI-1.5","MCB","CAM" /) ;, ,"GLENS","GLENS","CESM2","CESM2-WACCM"/) ; ;
diriall = (/diri_waccm,diri_arise,diri_mcb,diri_cam_ssp/);,,diri_glens,diri_glens,diri_cesm2_pi,diri_waccm_pi/); diri_arise
EXPA = (/"SSP245","SSP245","SSP245","SSP245"/);,"feedback","control","piControl","piControl"/) ;"feedback" ; the first 50 ens or the last 50 ens

yrsa = (/2035,2035,2035,2035 /);(/2035,2035/);,2020,2020,400,400 /);(/2015,2035,2020,2010 /);
; yrla = (/2069,2069,2055,2055,499,499 /);(/2069,2069,2069,2069 /)
yrla = yrsa + 34

; target period
yrstrt2a = yrsa+5 ;ispan(2035+1,2067,1) ;;+20;+11;   ;yrs (/2035/);
yrlast2a = yrla;ispan(2035+2,2068,1) ;yrstrt2a+3;+10;yrl ; 

; climatology based period
yrs_clm = 2035 + 5
yrl_clm = 2069

; For the ENSO function
usePI = False ;True ; use STD of Pi Control for ENSO metrics
PiModelExpa = (/"CESM2-WACCM_piControl","CESM2-WACCM_piControl","CESM2_piControl","CESM2_piControl"/);(/"MCB_SSP245","CAM_SSP245" /) ;(//)
EXTREME = False
ElorLa = "ElNino";"ElNino","LaNina" ;
IND = "nino3" ;"nino3pr" ;"nino4" ;
diriw = "/glade/work/chenxing/geog/cesm/" ;ENSO index path
RMMME_EL = True; remove ensemble mean for ENSO index?

EXTREME_str = ""
if(EXTREME) then 
EXTREME_str = "extreme"
end if 

if(usePI) then
  OWNSTD = ""
else
  OWNSTD = "OWNSTD"
end if 

nm = dimsizes(MODEL_NAME)

do im = 0,nm-1

EXP = EXPA(im)
MODEL = MODEL_NAME(im)
diria = diriall(im)
yrs = yrsa(im)
yrl = yrla(im)

ymstrt = yrs*100+2
ymlast = (yrl+1)*100+1

diri3 = diria+"*/atm/proc/tseries/month_1/"

PiModelExp = PiModelExpa(im)

;b.e11.BRCP85C5CNBDRD.f09_g16.005.cam.h0.FSNS.208101-210012.nc
locs = systemfunc("ls "+diri3+"*"+EXP+"*.FSNS.*.nc")
if(MODEL.eq."GLENS") then 
delete(locs)
diri3 = diri_glens+str_capital(EXP)+"/atm/proc/tseries/monthly/FSNS/"
locs = systemfunc("ls "+diri3+"*"+EXP+"*.FSNS.202001*.nc")
end if 

if(EXP.eq."piControl") then 
delete(locs)
  diri3 = diria+"atm/proc/tseries/month_1/"
  locs = systemfunc("ls "+diri3+"*"+EXP+"*.FSNS.*.nc")
end if 
printVarSummary(locs)
print(locs)
nsa = dimsizes(locs) ;ensemble number

do ie = 0,nsa-1

locs_str = str_split(locs(ie), "/")
print("'" + locs_str + "'")
aa = str_split(locs_str(5), ".")
print(aa)
if(MODEL.eq."ARISE-SAI-1.5") then 
ENSN  = aa(5)
else if(MODEL.eq."CESM2-WACCM".and.EXP.eq."SSP245")
ENSN  = aa(6)
else if(MODEL.eq."GLENS")
delete(aa)
aa = str_split(locs_str(11), ".")
ENSN  = aa(5)
else if (MODEL.eq."MCB") then 
delete(aa)
aa = str_split(locs_str(6), ".")
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
locs1 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.FSNS.*.nc");
locs2 = systemfunc("ls "+diri3+"../FLNS/*"+EXP+"*"+ENSN+"*.FLNS.*.nc");
locs3 = systemfunc("ls "+diri3+"../SHFLX/*"+EXP+"*"+ENSN+"*.SHFLX.*.nc");
locs4 = systemfunc("ls "+diri3+"../LHFLX/*"+EXP+"*"+ENSN+"*.LHFLX.*.nc");
else
locs1 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.FSNS.*.nc");
locs2 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.FLNS.*.nc");+locs(ie))
locs3 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.SHFLX.*.nc");
locs4 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.LHFLX.*.nc");
end if 

 f1   = addfiles(locs1, "r")  ;multiple files
 ListSetType (f1, "cat")        ; concatenate (=default)

 f2   = addfiles(locs2, "r")  ;multiple files
 ListSetType (f2, "cat")        ; concatenate (=default)

 f3   = addfiles(locs3, "r")  ;multiple files
 ListSetType (f3, "cat")        ; concatenate (=default)

 f4   = addfiles(locs4, "r")  ;multiple files
 ListSetType (f4, "cat")        ; concatenate (=default)

 f5   = addfile(diri+MODEL+"_"+EXP+"."+ENSN+"_heatbudget_var_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc", "r")  ;multiple files

 TIME2=f3[:]->time
 yyyymm2=cd_calendar(TIME2, -1)
 printMinMax(yyyymm2, True)

 ymstrts = ind(yyyymm2.eq.ymstrt)
 ymlasts = ind(yyyymm2.eq.ymlast)
 print(ymstrts+" <--start end--> "+ymlasts)
 delete([/TIME2,yyyymm2/])

fsns1  = f1[:]->FSNS(ymstrts:ymlasts,{SLAT:NLAT},{WLON:ELON});(:,{SLAT:NLAT},{WLON:ELON});
printVarSummary(fsns1)
flns1  = f2[:]->FLNS(ymstrts:ymlasts,{SLAT:NLAT},{WLON:ELON});(:,{SLAT:NLAT},{WLON:ELON});(ymstrts:ymlasts,{SLAT:NLAT},{WLON:ELON})
shflx1  = f3[:]->SHFLX(ymstrts:ymlasts,{SLAT:NLAT},{WLON:ELON});(:,{SLAT:NLAT},{WLON:ELON});(ymstrts:ymlasts,{SLAT:NLAT},{WLON:ELON})
lhflx1  = f4[:]->LHFLX(ymstrts:ymlasts,{SLAT:NLAT},{WLON:ELON});(:,{SLAT:NLAT},{WLON:ELON});(ymstrts:ymlasts,{SLAT:NLAT},{WLON:ELON})

hmxl     = f5->hmxl(:,{SLAT:NLAT},{WLON:ELON}) ;cm
hmxl     = replace_nan(hmxl)
hmxl = hmxl/100.
printVarSummary(hmxl)

fsns_regrid  = linint2_Wrap(fsns1&lon, fsns1&lat, fsns1, False, hmxl&lon, hmxl&lat, 0)
flns_regrid  = linint2_Wrap(flns1&lon, flns1&lat, flns1, False, hmxl&lon, hmxl&lat, 0)
shflx_regrid = linint2_Wrap(shflx1&lon, shflx1&lat, shflx1, False, hmxl&lon, hmxl&lat, 0)
lhflx_regrid = linint2_Wrap(lhflx1&lon, lhflx1&lat, lhflx1, False, hmxl&lon, hmxl&lat, 0)
copy_VarCoords(hmxl,fsns_regrid)
copy_VarCoords(hmxl,flns_regrid)
copy_VarCoords(hmxl,shflx_regrid)
copy_VarCoords(hmxl,lhflx_regrid)
printVarSummary(shflx_regrid)

;-------------------------------------------
; nmean = 30
; ndim = dimsizes(fsns_regrid)
; nyr = ndim(0)/12
depth = 80.
hmxl = where(isnan_ieee(hmxl),depth,hmxl)
hmxl = where(ismissing(hmxl),depth,hmxl)

if (SPE_MX.eq.True) then
  hmxl = depth
end if

; maybe there is something wrong with missing value of hmxl when it is a denominator!
fsnsa     = fsns_regrid/(lamda*hmxl);depth);hmxl);
flnsa     = flns_regrid/(lamda*hmxl);flns1;/(lamda*depth);depth);hmxl);
shflxa    = shflx_regrid/(lamda*hmxl);shflx1;/(lamda*depth);depth);hmxl);
lhflxa    = lhflx_regrid/(lamda*hmxl);hflx1/(lamda*depth);depth);hmxl);

fsns  = fsnsa
flns  = flnsa
shflx = shflxa
lhflx = lhflxa

if (FILTER.eq.True) then

  ; band filter
  fyr   = 8.
  ihp   = 1                             ; low-pass filter: ihp = 0; high-pass ihp = 1; band-pass ihp = 2.
  sigma = 1.0                           ; Lanczos sigma
  nWgt  = toint(fyr*12+1) ;fyr)+1 ;                           ; odd only
  fca   = 1./(fyr*12););
  fcb   = -999. ;1./(18.);
  wgt  = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

  fsns = wgt_runave_n_Wrap( fsnsa, wgt,  0, 0 )   ;opt < 0 : utilize cyclic conditions
  flns = wgt_runave_n_Wrap( flnsa, wgt,  0, 0 )   ;opt < 0 : utilize cyclic conditions
  shflx = wgt_runave_n_Wrap( shflxa, wgt,  0, 0 )   ;opt < 0 : utilize cyclic conditions
  lhflx = wgt_runave_n_Wrap( lhflxa, wgt,  0, 0 )   ;opt < 0 : utilize cyclic conditions
end if

copy_VarCoords(hmxl,fsns) ;hmxl
copy_VarCoords(hmxl,flns)
copy_VarCoords(hmxl,shflx)
copy_VarCoords(hmxl,lhflx)
;------output org files--------------
fon=diri+MODEL+"_"+EXP+"."+ENSN+"_heating_var_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc";
system("rm -f "+fon)
fo=addfile(fon,"c")
fo->fsns  = fsns
fo->flns  = flns
fo->shflx = shflx
fo->lhflx = lhflx

; ;---------------------------------
; ndim = dimsizes(fsns)
; nyr = ndim(0)/12
; nmean = 30
; fsnsc = get_moving_climo(fsns,nmean,nyr,True)
; flnsc = get_moving_climo(flns,nmean,nyr,True)
; shflxc = get_moving_climo(shflx,nmean,nyr,True)
; lhflxc = get_moving_climo(lhflx,nmean,nyr,True)

if(CLIMATE_HIST) then 

fc1 = addfile(dirip+"clim/CESM2-CAM6_cmip6_ensemblemean_clim_FSNS_1985-2014.nc","r")
fc2 = addfile(dirip+"clim/CESM2-CAM6_cmip6_ensemblemean_clim_FLNS_1985-2014.nc","r")
fc3 = addfile(dirip+"clim/CESM2-CAM6_cmip6_ensemblemean_clim_SHFLX_1985-2014.nc","r")
fc4 = addfile(dirip+"clim/CESM2-CAM6_cmip6_ensemblemean_clim_LHFLX_1985-2014.nc","r")
fsnsc0 = fc1->clim
flnsc0 = fc2->clim
shflxc0 = fc3->clim
lhflxc0 = fc4->clim

fsnsc1  = linint2_Wrap(fsnsc0&lon, fsnsc0&lat, fsnsc0, False, hmxl&lon, hmxl&lat, 0)
flnsc1  = linint2_Wrap(flnsc0&lon, flnsc0&lat, flnsc0, False, hmxl&lon, hmxl&lat, 0)
shflxc1 = linint2_Wrap(shflxc0&lon, shflxc0&lat, shflxc0, False, hmxl&lon, hmxl&lat, 0)
lhflxc1 = linint2_Wrap(lhflxc0&lon, lhflxc0&lat, lhflxc0, False, hmxl&lon, hmxl&lat, 0)
copy_VarCoords(hmxl(0,:,:),fsnsc1(0,:,:))
copy_VarCoords(hmxl(0,:,:),flnsc1(0,:,:))
copy_VarCoords(hmxl(0,:,:),shflxc1(0,:,:))
copy_VarCoords(hmxl(0,:,:),shflxc1(0,:,:))

fsnsc     = fsnsc1/(lamda*hmxl(:11,:,:));depth);hmxl);
flnsc     = flnsc1/(lamda*hmxl(:11,:,:));flns1;/(lamda*depth);depth);hmxl);
shflxc    = shflxc1/(lamda*hmxl(:11,:,:));shflx1;/(lamda*depth);depth);hmxl);
lhflxc    = lhflxc1/(lamda*hmxl(:11,:,:));hflx1/(lamda*depth);depth);hmxl);

else 

fsnsc = clmMonTLL(fsns ((yrs_clm-yrs)*12:(yrl_clm-yrs)*12-1,:,:)) 
flnsc = clmMonTLL(flns ((yrs_clm-yrs)*12:(yrl_clm-yrs)*12-1,:,:))
shflxc =clmMonTLL(shflx((yrs_clm-yrs)*12:(yrl_clm-yrs)*12-1,:,:))
lhflxc =clmMonTLL(lhflx((yrs_clm-yrs)*12:(yrl_clm-yrs)*12-1,:,:))

end if 

fsns = calcMonAnomTLL(fsns ,fsnsc  ) ;rmMonAnnCycTLL(fsns);fsns - fsnsc ;
flns = calcMonAnomTLL(flns ,flnsc  ) ;rmMonAnnCycTLL(flns);flns - flnsc ;
shflx =calcMonAnomTLL(shflx,shflxc ) ; rmMonAnnCycTLL(shflx);shflx - shflxc ;
lhflx =calcMonAnomTLL(lhflx,lhflxc ) ; rmMonAnnCycTLL(lhflx);lhflx - lhflxc ;

; copy_VarCoords(hmxl,fsns) ;hmxl
; copy_VarCoords(hmxl,flns)
; copy_VarCoords(hmxl,shflx)
; copy_VarCoords(hmxl,lhflx)
; printVarSummary(fsns)
; ;------output--------------

;;;;;;; all heat flux terms together
ndim = dimsizes(fsns)
dia   = new((/5,ndim(0),ndim(1),ndim(2)/), float,fsns@_FillValue)
dia(0,:,:,:) = fsns  *C_TIME_MO_S      ; Shortwave radiation K/s --> K/mon
dia(1,:,:,:) = flns  *C_TIME_MO_S      ; Longwave radiation
dia(2,:,:,:) = shflx *C_TIME_MO_S *-1     ; Sensible heat
dia(3,:,:,:) = lhflx *C_TIME_MO_S *-1     ; Latent heat
dia(4,:,:,:)  = dim_sum_n_Wrap(dia(0:3,:,:,:),0) ;summarize all terms in the right side of the equation


copy_VarCoords(fsns,dia(0,:,:,:))

TERM_NAME = (/"SW","LW","SH","LH","Total heat flux" /)
dia!0 = "terms"
dia@terms = TERM_NAME

if (NOTENSOYEAR) then 
yrs2 = 2035
yrl2 = yrs2 + 3
fon1=diri+"/enso/"+MODEL+"_"+ENSN+"_heatbudget_atmswterms_"+yrs2+"-"+yrl2+".nc"
system("rm -f "+fon1)
fo=addfile(fon1,"c")
fo->dia     = dia(:,(yrs2-yrs)*12:(yrl2-yrs)*12-1,:,:)

else 

;------------ setting for El Nino cases-------------
; NLAT2 =  10.
; SLAT2 = -10.
; WLON2 = 90.
; ELON2 = 300.


  EE = EXP+"."+ENSN
  print(EE)


do is = 0,dimsizes(yrstrt2a)-1
yrstrt2 = yrstrt2a(is)
yrlast2 = yrlast2a(is)

hb_el = hb_atm_terms_el(diriw,dia,IND,MODEL,EXP,ENSN,RMMME_EL,usePI,PiModelExp,EXTREME,ElorLa,dia&time,yrstrt2,yrlast2)
; hb_el = hb_atm_terms_extreme_el(dia,MODEL_NAME(im),ENSN,fsns&time,yrstrt2,yrlast2)
; hb_el = hb_atm_terms_la(dia,IND,MODEL_NAME(im),ENSN,fsns&time,yrstrt2,yrlast2)
copy_VarMeta(fsns(0,:,:),hb_el(0,0,0,:,:))

fon1=dirip+"heatbudget/enso/"+MODEL+"_"+EE+"_heatbudget_atmswterms_"+OWNSTD+EXTREME_str+ElorLa+"_"+yrstrt2+"-"+yrlast2+".nc"
system("rm -f "+fon1)
fo=addfile(fon1,"c")
fo->hb_el     = dim_avg_n_Wrap(hb_el,1)
; fo->hb_el     = hb_el(:,1,:,:,:)

delete(hb_el)

end do 

end if 

; delete([/fsnsc ,flnsc ,shflxc,lhflxc/])
delete([/dia/])

delete([/locs1,locs2,locs3,locs4/])
delete([/fsnsa ,fsns  ,flnsa ,flns  ,shflxa,shflx ,lhflxa,lhflx  /])
delete([/fsns1,flns1,shflx1,lhflx1  /])
; delete([/fsns_regrid ,flns_regrid ,shflx_regrid,lhflx_regrid/])
end do
delete([/locs,ENSN/])
end do

end
