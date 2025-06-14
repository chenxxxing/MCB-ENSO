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

diri_mcb =          "/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245smbb.f09_g17.MCB-050PCT"
diri_mcb_difseeds = "/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245cmip6.f09_g17.CMIP6-MCB-";025PCT.000"
;/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245smbb.f09_g17.MCB-050PCT.002/atm/proc/tseries/month_1
;b.e21.BSSP245smbb.f09_g17.MCB-050PCT.002.cam.h0.U.203501-206912.nc
diri_mcb_reduceseeds = "/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245smbb.f09_g17.MCB-80PCT";
;b.e21.BSSP245smbb.f09_g17.MCB-80PCT-40PCT.001
diri_cam_ssp = "/glade/campaign/cesm/development/cvcwg/cvwg/b.e21.BSSP245smbb.f09_g17/"
diri_INJANN = "/glade/derecho/scratch/chenxing/geog/cesm/proc/"
diri_walkermcb = "/glade/work/chenxing/geog/MCB/Walker_MCB/"

MODEL_NAME = (/"CAM" ,"MCB","CESM2-WACCM","ARISE-SAI-1.5"/);"MCB"; "MCB-difseeds" ; "MCB-reduceseeds" ; ,"CESM2","CESM2-WACCM"/); ;(/"CESM2","CESM2-WACCM"/) ;(/"CESM2-WACCM","ARISE-SAI-1.5","GLENS","GLENS"/) ; ;
diriall =(/diri_cam_ssp, diri_mcb,diri_waccm,diri_arise/); diri_mcb ;diri_mcb_difseeds; diri_mcb_reduceseeds; ,diri_cesm2_pi,diri_waccm_pi/);   ;diri_cesm1 ;(/diri_cam_ssp, diri_mcb/) ;  ;(/diri_cesm2_pi,diri_waccm_pi/)  ;(/diri_waccm,diri_arise,diri_glens,diri_glens/); diri_arise
EXPA = (/"SSP245","SSP245","SSP245","SSP245"/);,"piControl","piControl"/) ;"SSP245" ; ;(/"piControl","piControl"/) ;(/"SSP245","SSP245","feedback","control"/) ;"feedback" ; the first 50 ens or the last 50 ens

; MODEL_NAME = (/"MCB-feed","MCB-feed"/) 
; diriall = (/diri_walkermcb,diri_walkermcb/)
; EXPA = (/"MCB-feedback-1DOF","MCB-feedforward-1DOF"/)

; MODEL_NAME = (/"INJANN0N","INJANN15N","INJANN15S","INJANN30N","INJANN30S"/)
; diriall = (/diri_INJANN,diri_INJANN,diri_INJANN,diri_INJANN,diri_INJANN/) 
; EXPA = (/"INJANN0N_SSP245" ,"INJANN15N_SSP245","INJANN15S_SSP245" ,"INJANN30N_SSP245","INJANN30S_SSP245"/)

VAR = "TREFHT" ;"TS" ;"SST" ;"photoC_TOT_zint_100m" ;"U10" ;"OMEGA" ;"CLDLOW";"FSNS" ;"PRECT" ;"PRECC" ;"TS" ;"PRECT" ; CESM1 doesn't have PRECT?
OCN = False
LONGNAME = "TREFHTgmst" ;"nino34" ;"SST.WP" ;"FSNS.SEP" ;"gmst" ;"TS.WP" ;"gmst" ;"FSNS.nino3" ; "nino3pr" ;"nino3pr" ;"zonalgradient" ;"nino4" ; "merigradient" ;"nino3pr" ;

yrsa = (/2035,2035,2035,2035,2035,1,1/);400;(/2035,2035/);  (/1,1/); (/2015,2035,2020,2010 /);
yrla = (/2069,2069,2069,2069,499,499/);2044,2044,2044,2044,2044/);2100;yrsa+34 ;2069; (/499,499/); (/2069,2069,2099,2097 /)

nm = dimsizes(MODEL_NAME)

if(OCN.eq.True) then
ATMorOCN = "ocn"
else
ATMorOCN = "atm"
end if

do im = 0,nm-1
EXP = EXPA(im)
MODEL = MODEL_NAME(im)
diria = diriall(im)
yrs = yrsa(im)
yrl = yrla(im)
ymstrt = yrs*100+2
ymlast = (yrl+1)*100+1

if(MODEL.eq."MCB-difseeds") then 
  diri3 = diria+"*.000/"+ATMorOCN+"/proc/tseries/month_1/"
else 
  if(MODEL.eq."MCB-reduceseeds") then 
  diri3 = diria+"*.001/"+ATMorOCN+"/proc/tseries/month_1/"
  else
    diri3 = diria+"*/"+ATMorOCN+"/proc/tseries/month_1/"
end if 
end if 

  ; b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM.010.cam.h0.TS.201501-206412.nc
  ; b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT.001.cam.h0.TS.203501-206912.nc
  locs = systemfunc("ls "+diri3+"*"+EXP+"*."+VAR+".*.nc")
  
  if (isStrSubset(MODEL, "INJANN")) then
  delete(locs)
    diri3 = diria
    locs = systemfunc("ls "+diri3+EXP+"_*."+VAR+".*.nc")
end if 

if (MODEL.eq."MCB-feed") then
  delete(locs)
    diri3 = diria
    locs = systemfunc("ls "+diri3+"*."+EXP+".*."+VAR+".*.nc")
end if 

if(MODEL.eq."GLENS") then 
delete(locs)
  diri3 = diri_glens+str_capital(EXP)+"/"+ATMorOCN+"/proc/tseries/monthly/"+VAR+"/"
  locs = systemfunc("ls "+diri3+"*"+EXP+"*."+VAR+".202001*.nc")
end if 
if(EXP.eq."piControl") then 
delete(locs)
  if(MODEL.eq."CESM1") then 
    diri3 = diria+""+ATMorOCN+"/proc/tseries/monthly/"
    locs = systemfunc("ls "+diri3+VAR+"/*B1850C5CN*.001.*"+VAR+".*.nc")
  else 
    diri3 = diria+""+ATMorOCN+"/proc/tseries/month_1/"
    locs = systemfunc("ls "+diri3+"*"+EXP+"*.001.*"+VAR+"*039912.nc")
  end if 
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
  else if(isStrSubset(MODEL, "INJANN"))
  ENSN  = "001"
  else if(MODEL.eq."CAM".and.EXP.eq."SSP245")
  delete(aa)
  aa = str_split(locs_str(7), ".")
  ENSN  = aa(4)
  else if(MODEL.eq."MCB-difseeds".or.MODEL.eq."MCB-reduceseeds");.and.EXP.eq."SSP245")
  delete(aa)
  aa = str_split(locs_str(6), ".")
  ENSN  = aa(4)+"."+aa(5)
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
  fils = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*."+VAR+".*.nc");
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

if (VAR.eq."PRECC") then 
  x1  = f[:]->$VAR$(ymstrts:ymlasts,:,:)
  if(MODEL.eq."GLENS") then 
  fils2 = systemfunc("ls "+diri3+"../PRECL/*"+EXP+"*"+ENSN+"*.PRECL.*.nc");
  else
  if(MODEL.eq."CESM1".and.EXP.eq."piControl") then 
  fils2 = systemfunc("ls "+diri3+"PRECL/*B1850C5CN*.PRECL.*.nc");
  else
  fils2 = systemfunc("ls "+diri3+"*"+EXP+"*"+ENSN+"*.PRECL.*.nc");
  end if 
  end if 
  f2   = addfiles(fils2, "r")  ;multiple files
  ListSetType (f, "cat")        ; concatenate (=default)
    x2  = f2[:]->PRECL(ymstrts:ymlasts,:,:)
    xx = x1
    xx = x1 + x2 
    delete([/x1,x2,fils2,f2/])
else 
  xx  = f[:]->$VAR$(ymstrts:ymlasts,:,:)  ;{500},  {992}
end if 
printVarSummary(xx)

if(OCN) then 
  ; remap pop grids 
  ;;;; hasn't upload map of gx1v7 for CESM2... don't know whether can version 6 be used
  xxo       = PopLatLon(xx,"gx1v6","1x1d","bilin","da","100716")
  delete(xx)
  xx        = replace_nan(xxo)
  delete(xxo)
end if 

; ;climatology is 1975-2005
; xc = clmMonTLL(f[:]->$VAR$(ycstrts:yclasts,:,:))
; xa = calcMonAnomTLL(xx, xc)
xa = rmMonAnnCycTLL(xx)
; xa = dtrend_msg_n(xa&time, xa, True, False, 0)

xa_sea = xx ;xa
delete([/fils,f,TIME2,yyyymm2/]);,lat,lon

; if(VAR.eq."TREFHT") then 
; ;-------------------------------------
; ;cover land data; do this first!!
; ;mask 0=ocean (land reserved), 1=land, 2=lake, 3=small island, 4=ice shelf.

;  lland = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
;  lsm0 = landsea_mask(lland->LSMASK,xx&lat,xx&lon)
;  xa_sea = mask(xx,lsm0.eq.1, False)      ; mask out land points
;  copy_VarMeta(xx, xa_sea)

; delete(lsm0)
; end if 

;-------------------------
; Calculating index
; Nino 1+2 (0-10S, 90W-80W), Nino 3 (5N-5S, 150W-90W),
; Nino 3.4/ONI (5N-5S, 170W-120W) and Nino 4 (5N-5S, 160E-150W)
; TNI is Nino 1+2 - Nino 4
; warm pool maybe 5S-5N, 130-160E or 150-180E? or 100-130E
; cold tongue maybe 5S-5N, 140-80W
; zonal wind 150ºE-150ºW, 10ºS-10ºN
; CP index = Nino4_normalized - 0.5*Nino3_normalized (or maybe not normalize)

; The meridional SST gradient is defined as the average SST over the off- equatorial 
; region (10S–5S, 155E–120W) minus the average over the equatorial region 
; (5S-0u, 155E–120W). (Cai et al. 2012)

; Zonal SST gradient: surface temperature gradients between the 
; Maritime continent region (5S–5N, 100E–125E) and the central Pacific (5S–5N, 160E–150W) (Cai et al. 2015)

;MCB forcing regions:
; north east Pacific (0 to 30N, 150W to 110W):
; b.e21.BSSP245smbb_MCB600cm_R1.f09_g17.LE2-1011.001.pop.h.2015-2024.top150m.bgc.nc
; south east Pacific (30S to 0, 110W to 70W)
; b.e21.BSSP245smbb_MCB600cm_R2.f09_g17.LE2-1011.001.pop.h.2015-2024.top150m.bgc.nc
; south east Atlantic (30S to 0, 15W to 25E)
; b.e21.BSSP245smbb_MCB600cm_R3.f09_g17.LE2-1011.001.pop.h.2015-2024.top150m.bgc.nc

  lat = xa_sea&lat
  rad    = 4.0*atan(1.0)/180.0
  clat   = cos(lat*rad)
  copy_VarCoords(xa_sea(0,:,0), clat)
  ; go = wgt_areaave_Wrap(x,clat, 1.0, 1)

  NLAT1 =  90.;5.;0;
  SLAT1 =  -90.;-5.;-30;
  WLON1 =  0.;360.-170.;160;150;;110;130.;100.;360.-150.;
  ELON1 =  360.;360.-120.;150;90;160.;125.;90.;

  NLAT2 =  5.
  SLAT2 =  -5.
  WLON2 =  160.;100.;155.;360.-170.;5.;160.
  ELON2 =  360-150.;125.;360.-120.;90.;160.;210.;

  gmst1 = wgt_areaave_Wrap(xa_sea(:,{SLAT1:NLAT1},{WLON1:ELON1}),clat({SLAT1:NLAT1}), 1.0, 1)
  gmst2 = wgt_areaave_Wrap(xa_sea(:,{SLAT2:NLAT2},{WLON2:ELON2}),clat({SLAT2:NLAT2}), 1.0, 1)

  gmst = gmst1
  ; gmst = gmst2 - gmst1 ;0.5*gmst1
  gmst@long_name = LONGNAME ;"cpi"; "CP index = Nino4 - 0.5*Nino3" ; "nino3pr" ;

;--------output-------------
fon=diri+"cesm/"+gmst@long_name+"/"+MODEL+"_"+EXP+"."+ENSN+"_"+gmst@long_name+"_"+yrs+"-"+yrl+".nc";
system("rm -f "+fon)
fo=addfile(fon,"c")
fo->index = gmst

if(MODEL.eq."MCB-difseeds") then 
  system("rename SSP245.CMIP6 SSP245-CMIP6 "+diri+"cesm/"+gmst@long_name+"/MCB-difseeds_SSP245.CMIP6-MCB-*.nc")
end if 

if(MODEL.eq."MCB-reduceseeds") then 
  system("rename SSP245.MCB SSP245-MCB "+diri+"cesm/"+gmst@long_name+"/MCB-reduceseeds_SSP245.MCB-*.nc")
end if 

delete([/xx, xa,xa_sea,clat,lat,gmst1,gmst,gmst2/])

end do
delete([/ENSN,locs /]);gmst2,
end do
end
