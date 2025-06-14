;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
begin

;{\displaystyle S=C_{p}\cdot T+g\cdot z+L_{v}\cdot q}


diri = "/glade/work/chenxing/geog/"
dirip = "/glade/u/home/chenxing/geog/"
diris = "/glade/derecho/scratch/chenxing/geog/"

diri2 = "/gpfs/fs1/collections/cdg/data/CLIVAR_LE/"
;from lens_index.ncl
diri3 = "/glade/work/chenxing/geog/"
; diri4 =  "/glade/p/cesm/community/CESM-LE/data/CESM-CAM5-BGC-LE/ocn/proc/tseries/monthly/"
; diri4 =  "/glade/p/cesm/community/CESM-LE/data/CESM-CAM5-BGC-LE/atm/proc/tseries/monthly/"
diri6 = "/glade/campaign/cgd/cesm/CESM2-LE/atm/proc/tseries/month_1/"

diri_arise = "/glade/campaign/cesm/collections/ARISE-SAI-1.5/b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT"
diri_waccm = "/glade/campaign/cesm/collections/CESM2-WACCM-SSP245/b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM"
diri_glen = "/glade/campaign/cesm/collections/GLENS/"
diri_mcb = "/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245smbb.f09_g17.MCB-050PCT"
diri_cam_ssp = "/glade/campaign/cesm/development/cvcwg/cvwg/b.e21.BSSP245smbb.f09_g17/"
diri_cesm2_pi = "/glade/campaign/collections/cmip/CMIP6/timeseries-cmip6/b.e21.B1850.f09_g17.CMIP6-piControl.001/"
diri_waccm_pi = "/glade/campaign/collections/cmip/CMIP6/timeseries-cmip6/b.e21.BW1850.f09_g17.CMIP6-piControl.001/"
diri_mcb_difseeds = "/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245cmip6.f09_g17.CMIP6-MCB-";025PCT.000"

MODELa =(/"CAM","MCB","CESM2-WACCM","ARISE-SAI-1.5"/); "MCB-difseeds" ; (//);,,"CESM2","CESM2-WACCM"/);,/); "GLENS","GLENS"
EXPa = (/"SSP245","SSP245","SSP245","SSP245","piControl","piControl"/);,"SSP245","SSP245", /); "control","feedback","SSP245","SSP245"/);
diriall = (/diri_cam_ssp,diri_mcb,diri_waccm,diri_arise/);diri_mcb_difseeds;(//);,,diri_cesm2_pi,diri_waccm_pi/);

yrsa = (/2035,2035,2035,2035,1,1/) ;2035,2035,2035,2035,(//);2020,2020, (/2035,2047,2059/);(/2020,2032,2044,2020/) ; 
yrla = (/yrsa(0)+34,yrsa(1)+34,yrsa(2)+34,yrsa(3)+34,499,499/) ;,yrsa(2)+34,yrsa(3)+34,yrsa+34;2069;(/2046,2058,2069/);(/2031,2043,2055,2055/) ; 

VAR1 =  "T"
VAR2 =  "Q"
VAR3 =  "Z3"
VAR4 =  "PHIS"

DETREND = False ;False ;True
FILTER = False ;True ;False
MOCLIM = False ;True
; RMMME = False ;True  ;Based on ensemble mean, to remove

;---------read output---------------
; from reg_cmip5.ncl reg_cmip6.ncl
;cmip5_historical_GISS-E2-R_r6i1p1_nino34_1861-2004.nc

nmodl = dimsizes(MODELa)

do ia = 0,nmodl-1
EXP = EXPa(ia)
MODEL = MODELa(ia)
diria = diriall(ia)

yrstrt = yrsa(ia) ;2035; start year
yrlast = yrla(ia) ;2069; end year
ymstrt = yrstrt*100+2
ymlast = (yrlast+1)*100+1
print(yrstrt+"-"+yrlast)

ATMorOCN = "atm"


; b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM.010.cam.h0.TS.201501-206412.nc
; b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT.001.cam.h0.TS.203501-206912.nc
if(MODEL.eq."ARISE-SAI-1.5") then 
    dirit = diri_arise+"*/"+ATMorOCN+"/proc/tseries/month_1/"
    locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR1+".*203501*.nc")
else if(MODEL.eq."CESM2-WACCM".and.EXP.ne."piControl")
    dirit = diri_waccm+"*/"+ATMorOCN+"/proc/tseries/month_1/"
    locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR1+".206501*.nc")
else if(MODEL.eq."GLENS")
    dirit = diri_glen+str_capital(EXP)+"/"+ATMorOCN+"/proc/tseries/monthly/"+VAR1+"/"
    locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR1+".202001*.nc")
else if(MODEL.eq."MCB")
  dirit = diri_mcb+"*/"+ATMorOCN+"/proc/tseries/month_1/"
  locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR1+".*203501*.nc")
else if(MODEL.eq."CAM")
  dirit = diri_cam_ssp+"*/"+ATMorOCN+"/proc/tseries/month_1/"
  locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR1+".*206412.nc")
end if 
end if 
end if 
end if 
end if 

if(MODEL.eq."MCB-difseeds") then 
  dirit = diria+"*.000/"+ATMorOCN+"/proc/tseries/month_1/"
  locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR1+".*.nc")
end if  

if(EXP.eq."piControl") then 
  if(MODEL.eq."CESM1") then 
    dirit = diria+""+ATMorOCN+"/proc/tseries/monthly/"
    locs = systemfunc("ls "+dirit+VAR1+"/*B1850C5CN*."+VAR1+"*.nc")
  else 
    dirit = diria+""+ATMorOCN+"/proc/tseries/month_1/"
    locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR1+"*000101*.nc")
  end if 
end if 

printVarSummary(locs)
print(locs)
nle = dimsizes(locs)

istart = 0
do ie = istart,nle-1

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
  else if(MODEL.eq."MCB-difseeds".and.EXP.eq."SSP245")
  delete(locs_str)
  locs_str = str_split(locs(ie), "/")
  aa = str_split(locs_str(6), ".")
  ENSN  = aa(4)+"."+aa(5)
  
  end if 
  end if
  end if
  end if 
  end if 
  end if 
  end if 

    delete([/locs_str0,locs_str/])


      if(MODEL.eq."CESM1".and.EXP.eq."piControl") then 
      fils1 = systemfunc("ls "+dirit+VAR1+"/*B1850C5CN*."+VAR1+".*.nc");
      fils2 = systemfunc("ls "+dirit+VAR2+"/*B1850C5CN*."+VAR2+".*.nc");
      fils3 = systemfunc("ls "+dirit+VAR3+"/*B1850C5CN*."+VAR3+".*.nc");
      fils4 = systemfunc("ls "+dirit+VAR4+"/*B1850C5CN*."+VAR4+".*.nc");
      else 
      fils1 = systemfunc("ls "+dirit+"*"+EXP+"*"+ENSN+"*."+VAR1+".*.nc")
      fils2 = systemfunc("ls "+dirit+"*"+EXP+"*"+ENSN+"*."+VAR2+".*.nc")
      fils3 = systemfunc("ls "+dirit+"*"+EXP+"*"+ENSN+"*."+VAR3+".*.nc")
      fils4 = systemfunc("ls "+dirit+"*"+EXP+"*"+ENSN+"*."+VAR4+".*.nc")
      end if 

      f1   = addfiles(fils1, "r")  ;multiple files
      ListSetType (f1, "cat")        ; concatenate (=default)
      f2   = addfiles(fils2, "r")  ;multiple files
      ListSetType (f2, "cat")        ; concatenate (=default)
      f3   = addfiles(fils3, "r")  ;multiple files
      ListSetType (f3, "cat")        ; concatenate (=default)
      f4   = addfiles(fils4, "r")  ;multiple files
      ListSetType (f4, "cat")        ; concatenate (=default)
            print(fils1)

  print(MODEL+" ens "+ENSN)

  ;-----------------------------------------

  TIME2=f1[:]->time
  yyyymm2=cd_calendar(TIME2, -1)
  printMinMax(yyyymm2, True)
  ymstrts = ind(yyyymm2.eq.ymstrt)
  ymlasts = ind(yyyymm2.eq.ymlast)
  print(ymstrts+" <--start end--> "+ymlasts)

  T  = f1[:]->$VAR1$(ymstrts:ymlasts,:,:,:)  ; K         iounit(0)=1   (time,lev,lat,lon)
  Q  = f2[:]->$VAR2$(ymstrts:ymlasts,:,:,:) ; kg/kg     iounit(1)=0
  ZG  = f3[:]->$VAR3$(ymstrts:ymlasts,:,:,:) ; m         Geopotential Height (above sea level)
  PHIS  = f4[:]->$VAR4$(ymstrts:ymlasts,:,:) ; m2/s2     Surface geopotential (time,lat,lon) 

delete([/fils1,fils2,fils3,fils4,f1,f2,f3,f4,TIME2,yyyymm2/])

;==========Moist static energy MSE======================================================

PHIS = PHIS/9.8          ; m
phis = conform(ZG, PHIS, (/0,2,3/))        ;  (time,lev,lat,lon)
Z    = ZG-phis           ; m         Height above the surface
copy_VarCoords(ZG, Z)

SE = static_energy_atm(T, Q, Z, (/1,0 /)) ; (time,lev,lat,lon)

; for clarity: explicitly extract each variable from list
MSE = SE[0]
DSE = SE[1]
LSE = SE[2]

printVarSummary(MSE)
printMinMax(MSE,0)

printVarSummary(DSE)
printMinMax(DSE,0)

printVarSummary(LSE)
printMinMax(LSE,0)

;==========Moist static stability MSS======================================================

MSS  = static_stability(T&lev * 100,T, 1, 0)

printVarSummary(MSS)
printMinMax(MSS,0)

delete([/ZG,T,Q,PHIS,SE,phis,Z/])   ; no longer needed

;--------output-------------
setfileoption("nc","Format","NetCDF4")
fon1=diris+"cesm/MSE/"+MODEL+"_"+EXP+"_"+ENSN+"_MSE_"+yrstrt+"-"+yrlast+".nc";
fon2=diris+"cesm/MSE/"+MODEL+"_"+EXP+"_"+ENSN+"_DSE_"+yrstrt+"-"+yrlast+".nc";
fon3=diris+"cesm/MSE/"+MODEL+"_"+EXP+"_"+ENSN+"_LSE_"+yrstrt+"-"+yrlast+".nc";
fon4=diris+"cesm/MSE/"+MODEL+"_"+EXP+"_"+ENSN+"_MSS_"+yrstrt+"-"+yrlast+".nc";
system("rm -f "+fon1)
system("rm -f "+fon2)
system("rm -f "+fon3)
fo1=addfile(fon1,"c")
fo1->MSE = MSE
fo2=addfile(fon2,"c")
fo2->DSE = DSE
fo3=addfile(fon3,"c")
fo3->LSE = LSE
fo4=addfile(fon4,"c")
fo4->MSS = MSS

delete([/MSE,  DSE,  LSE,MSS/])

end do 
delete(locs)
end do 


end