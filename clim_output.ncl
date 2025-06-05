; drive from cesm_com_enso.ncl

load "./func/get_anom_moving_climo.ncl"
load "./func/get_moving_climo.ncl"
load "./func/get_ensemble_mean.ncl"
load "./func/get_el_nino_cases.ncl"
; load "./func/get_la_nina_cases.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "./func/replace_nan.ncl"
begin
diri = "/glade/work/chenxing/geog/"
dirip = "/glade/u/home/chenxing/geog/"

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
diri_mcb_difseeds = "/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245cmip6.f09_g17.CMIP6-MCB-";025PCT.000"
diri_mcb_reduceseeds = "/glade/campaign/cgd/projects/cchen/MCB/b.e21.BSSP245smbb.f09_g17.MCB-80PCT";
diri_cam_ssp = "/glade/campaign/cesm/development/cvcwg/cvwg/b.e21.BSSP245smbb.f09_g17/"
diri_cesm2_pi = "/glade/campaign/collections/cmip/CMIP6/timeseries-cmip6/b.e21.B1850.f09_g17.CMIP6-piControl.001/"
diri_waccm_pi = "/glade/campaign/collections/cmip/CMIP6/timeseries-cmip6/b.e21.BW1850.f09_g17.CMIP6-piControl.001/"
diri_walkermcb = "/glade/work/chenxing/geog/MCB/Walker_MCB/"

SEASON = (/"DJF","MAM","JJA","SON" /)

; MODELa = (/"CESM1-CAM5","CanESM2","CSIRO-Mk3-6-0",\;"EC-EARTH",
;   "GFDL-CM3","GFDL-ESM2M","MPI-ESM","CESM2-CAM6"/);,"E3SM-LE" /)
MODELa = (/"CESM2-WACCM","ARISE-SAI-1.5","CAM","MCB"/);"MCB-reduceseeds" ;"MCB-difseeds" ;(/"CESM2-WACCM","ARISE-SAI-1.5","CAM","MCB","CESM2","CESM2-WACCM"/);,/); "GLENS","GLENS"
EXPa = (/"SSP245","SSP245","SSP245","SSP245","piControl","piControl"/);"SSP245" ;,"SSP245","SSP245", /); "control","feedback","SSP245","SSP245"/);
diriall = (/diri_waccm,diri_arise,diri_cam_ssp,diri_mcb,diri_cesm2_pi,diri_waccm_pi/);diri_mcb_reduceseeds ;


; MODELa = (/"MCB-feed","MCB-feed"/) 
; diriall = (/diri_walkermcb,diri_walkermcb/)
; EXPa = (/"MCB-feedback-1DOF","MCB-feedforward-1DOF"/)

yrsa = (/2035,2035,2035,2035,1,1/) ;2035,2035,2035,2035,(//);2020,2020, (/2035,2047,2059/);(/2020,2032,2044,2020/) ; 
yrla = (/yrsa(0)+34,yrsa(1)+34,yrsa(2)+34,yrsa(3)+34,499,499/) ;,yrsa(2)+34,yrsa(3)+34,yrsa+34;2069;(/2046,2058,2069/);(/2031,2043,2055,2055/) ; 

VARa = (/"PRECT","TREFHT"/);(/"TS","PRECC"/);,"FSNS"/) ;"SST" ;(/"TS","PRECC","PSL","FSNT","FLNT","FSNS","FSNSC","CLDLOW","CLDHGH","CLDMED"/);"FSNSC" ;(/"photoC_TOT_zint_100m"/) ;Z3 (//);,"AREL","CLDTOT","CLDLOW","CLDHGH",,"U","V","U","V"/)
OCN = (/False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False/)
D4a = (/False,False,False,False,False,False,False,False,False,False,False,True,True,True,True/) ; 4 dimentions including vertical layers?
ileva1 = (/500,850,200,0,0,0,0,0,0,0,1000,0,0,0,850,850,200,200/) ;if D4 is True, what's the level
ileva2 = (/500,850,200,0,0,0,0,0,0,0,200,0,0,0,0,0,0,850,850,200,200/)

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

; do iya = 0,dimsizes(yrsa)-1

yrstrt = yrsa(ia) ;2035; start year
yrlast = yrla(ia) ;2069; end year
ymstrt = yrstrt*100+2
ymlast = (yrlast+1)*100+1
print(yrstrt+"-"+yrlast)

do iv = 0,dimsizes(VARa)-1 
VAR = VARa(iv)
D4 = D4a(iv)
ilev1 = ileva1(iv)
ilev2 = ileva2(iv)
if (D4) then 
  VAR_name = VAR+ilev1+"-"+ilev2
else 
  VAR_name = VAR
end if 

if(OCN(iv).eq.True) then
ATMorOCN = "ocn"
else
ATMorOCN = "atm"
end if


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
else if(MODEL.eq."MCB-difseeds")
  dirit = diri_mcb_difseeds+"*.000/"+ATMorOCN+"/proc/tseries/month_1/"
  locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR+".*203501*.nc")
else if(MODEL.eq."MCB-reduceseeds")
  dirit = diri_mcb_reduceseeds+"*.001/"+ATMorOCN+"/proc/tseries/month_1/"
  locs = systemfunc("ls "+dirit+"*"+EXP+"*."+VAR+".*203501*.nc")

else  if (MODEL.eq."MCB-feed") then
    dirit = diria
    locs = systemfunc("ls "+dirit+"*."+EXP+".*."+VAR+".*.nc")
end if 

end if 
end if 
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
nle = dimsizes(locs)

; if(EXP.ne."piControl") then

;   ; read MME data for RMMME
;   print(diri3+"cesm/mme/"+MODEL+"_"+EXP+"_"+VAR+"_mme.nc")
;   f_mme = addfile(diri3+"cesm/mme/"+MODEL+"_"+EXP+"_"+VAR+"_mme.nc","r")
;   if (VAR.eq."PRECC") then 
;       x1  = f_mme->$VAR$
;       f_mme2 = addfile(diri3+"cesm/mme/"+MODEL+"_"+EXP+"_PRECL_mme.nc","r")
;       x2  = f_mme2->PRECL
;       xx_mean1 = x1
;       xx_mean1 = x1 + x2 
;       delete([/x1,x2,f_mme2/])
;       VAR_name = "PR"
;   else 
;       if(D4) then 
;           xx_mean1 = f_mme->$VAR$(:,{ilev},:,:)
;       else 
;           xx_mean1 = f_mme->$VAR$
;       end if 
;   end if 
;   printVarSummary(xx_mean1)

; else 
;  xx_mean1 = 0

; end if 

nu_en = 0.0 ; ensemble number

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
  else if(MODEL.eq."MCB-difseeds".or.MODEL.eq."MCB-reduceseeds")
  delete(locs_str)
  locs_str = str_split(locs_str0(6), ".")
  ENSN  = locs_str(4)+"."+locs_str(5)
  else if (MODEL.eq."MCB-feed") then
  aa = str_split(locs_str0(6), ".")
  ENSN  = aa(5)
 
  end if 
  end if 
  end if
  end if
  end if 
  end if 
  end if 
  end if 

    delete([/locs_str0,locs_str/])

    if (MODEL.eq."CAM".and.EXP.eq."SSP245".and.(VAR.eq."PRECC".or.VAR.eq."FSNT".or.VAR.eq."FLNT")) then 
    fils = systemfunc("ls "+dirit+"*"+EXP+"*"+ENSN+"*."+VAR+".201501-206412.nc "+dirit+"*"+EXP+"*"+ENSN+"*."+VAR+".206501-210012.nc");
    else 
      if(MODEL.eq."CESM1".and.EXP.eq."piControl") then 
      fils = systemfunc("ls "+dirit+VAR+"/*B1850C5CN*."+VAR+".*.nc");
      else 
      fils = systemfunc("ls "+dirit+"*"+EXP+"*"+ENSN+"*."+VAR+".*.nc")
      end if 
    end if 
  f   = addfiles(fils, "r")  ;multiple files
    print(fils)
  ListSetType (f, "cat")        ; concatenate (=default)

  print(MODEL+" ens "+ENSN)

  ;-----------------------------------------

  TIME2=f[:]->time
  yyyymm2=cd_calendar(TIME2, -1)
  printMinMax(yyyymm2, True)
  ymstrts = ind(yyyymm2.eq.ymstrt)
  ymlasts = ind(yyyymm2.eq.ymlast)
  print(ymstrts+" <--start end--> "+ymlasts)

  if(D4) then 
    xx = dim_avg_n_Wrap(f[:]->$VAR$(ymstrts:ymlasts,{ilev1:ilev2},:,:),1)
  else 
    if (VAR.eq."PRECC") then 
    x1  = f[:]->$VAR$(ymstrts:ymlasts,:,:)
      if(MODEL.eq."GLENS") then 
      fils2 = systemfunc("ls "+dirit+"../PRECL/*"+EXP+"*"+ENSN+"*.PRECL.*.nc"); 
      else if(MODEL.eq."CESM1".and.EXP.eq."piControl") then 
      fils2 = systemfunc("ls "+dirit+"PRECL/*B1850C5CN*.PRECL.*.nc");
      else if (MODEL.eq."CAM".and.EXP.eq."SSP245") then 
        fils2 = systemfunc("ls "+dirit+"*"+EXP+"*"+ENSN+"*.PRECL.201501-206412.nc "+dirit+"*"+EXP+"*"+ENSN+"*.PRECL.206501-210012.nc");
      else
        fils2 = systemfunc("ls "+dirit+"*"+EXP+"*"+ENSN+"*.PRECL.*.nc");
    end if 
  end if 
  end if 

    f2   = addfiles(fils2, "r")  ;multiple files
    ListSetType (f, "cat")        ; concatenate (=default)
      x2  = f2[:]->PRECL(ymstrts:ymlasts,:,:)
      xx = x1
      xx = x1 + x2 
      delete([/x1,x2,fils2,f2/])
    else 
      xx  = f[:]->$VAR$(ymstrts:ymlasts,:,:);;(:,{100000},:,:);ce;
    end if
  end if   

if(OCN(iv)) then 
  ; remap pop grids 
  ;;;; hasn't upload map of gx1v7 for CESM2... don't know whether can version 6 be used
  xxo       = PopLatLon(xx,"gx1v6","1x1d","bilin","da","100716")
  delete(xx)
  xx        = replace_nan(xxo)
  delete(xxo)
end if 
  printVarSummary(xx)

  xx1 = xx

  x_clim = clmMonTLL(xx1)
  x_std = x_clim
  do imon = 0,11
    x_std(imon,:,:) = dim_stddev_n_Wrap(xx1(imon::12,:,:),0)
  end do 

  if(DETREND)then
    ; a seperated detrend for historical and future RCP periods
    ; xx = dtrend_msg_n(xx&time, xx, True, False, 1)

    yy = 199001;200512
    ymrcps = ind(yyyymm2.eq.yy)
    tt = xx&time
    xx1(:,ymrcps:) = dtrend_msg_n(tt(ymrcps:),xx1(:,ymrcps:),True,True,1)
    xx1(:,:ymrcps) = dtrend_msg_n(tt(:ymrcps),xx1(:,:ymrcps),True,True,1)
    delete(tt)
    copy_VarMeta(xx,xx1)
  end if

  if(FILTER)then
  ; band filter
  fyr   = 50.
  ihp   = 1                             ; low-pass filter: ihp = 0; high-pass ihp = 1; band-pass ihp = 2.
  sigma = 1.0                           ; Lanczos sigma
  nWgt  = 31;toint(fyr*12+1) ;fyr)+1 ;                           ; odd only
  fca   = 1./(fyr*12););
  fcb   = -999.;1./(18.);
  wgt  = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )
  xx1 = wgt_runave_n_Wrap( xx1, wgt,  0, 1 )   ;opt < 0 : utilize cyclic conditions
  end if

    ndim = dimsizes(xx1)

    if(MOCLIM) then
    do ie = 0,ndim(0)-1
      nmean = 10;30 ;moving window
      nyr = ndim(1)/12
      ISMON = True
      xxc = get_moving_climo(xx,nmean,nyr,ISMON)
      xx1 = xx1 - xxc
    end do
    delete([/xxc/])

    end if

    ; if(RMMME) then 

    ;   ; ;Method one using my function to calculate
    ;   ; if (ie.eq.0) then 
    ;   ;     dirik = ""
    ;   ;     print(VAR)
    ;   ;     xx_mean = get_ensemble_mean(dirik,f_name,VAR,True,20*12+1)
    ;       ;  xx_mean1 = conform(xx, xx_mean, (/1,2/))
    ;       ; copy_VarCoords(xx,xx_mean1)

    ;   ; delete(xx_mean)
    ;   ; end if 

    ;   ;Method 2 using pre-calculated MME data based on cdo_mme.ncl 
    ;     ; from cdo_mme.ncl

    ;   ; ; filter
    ;   ; fyr   = 8.
    ;   ; ihp   = 1                             ; low-pass filter: ihp = 0; high-pass ihp = 1; band-pass ihp = 2.
    ;   ; sigma = 1.0                           ; Lanczos sigma
    ;   ; nWgt  = 121;toint(fyr*12+1) ;fyr)+1 ;                           ; odd only
    ;   ; fca   = 1./(fyr*12););
    ;   ; fcb   = -999.;1./(18.);
    ;   ; wgt  = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )
    ;   ; xx_mean1 = wgt_runave_n_Wrap( xx_mean1, wgt,  1,0 )   ;opt < 0 : utilize cyclic conditions

    ;   xx1 = xx1 - xx_mean1(ymstrts:ymlasts,:,:)

    ; end if 

  delete(ndim)

  nf = dimsizes(fils) ; file number


  if (VAR.eq."PRECC".or.VAR.eq."PRECL".or.VAR.eq."PRECT") then
  xx1 = xx1 *1000 * 3600 *24
  xx1@units = "mm/day"
  x_clim = x_clim *1000 * 3600 *24
  x_clim@units = "mm/day"
  x_std = x_std *1000 * 3600 *24
  x_std@units = "mm/day"
  end if
  if (VAR.eq."PSL") then
  xx1 = xx1 /100
  xx1@units = "hPa"
  x_clim = x_clim /100
  x_clim@units = "hPa"
  x_std = x_std /100
  x_std@units = "hPa"
end if

; make space for all ensembles
ndimx = dimsizes(x_clim)

if(ie.eq.0) then 
xclm_a = conform_dims((/nle,12,ndimx(1),ndimx(2)/),x_clim,(/1,2,3/))
xclm_a = x_clim@_FillValue
xclm_a(0,:,:,:) = x_clim
xstd_a = conform_dims((/nle,12,ndimx(1),ndimx(2)/),x_std,(/1,2,3/))
xstd_a = x_std@_FillValue
xstd_a(0,:,:,:) = x_std
end if 

if (MODEL.eq."MCB-difseeds".or.MODEL.eq."MCB-reduceseeds") then 
;--------output-------------
fon=diri+"cesm/clim/"+MODEL+"_"+EXP+ENSN+"_clim_"+VAR_name+"_"+yrstrt+"-"+yrlast+".nc";
system("rm -f "+fon)
fo=addfile(fon,"c")
fo->xclm_em = x_clim
fo->xstd_em = x_std
end if 

; put ensemble results in it
xclm_a(ie,:,:,:) = x_clim
printVarSummary(xclm_a)
xstd_a(ie,:,:,:) = x_std
printVarSummary(xstd_a)

; the last ensemble, calculate ensemble mean
if (ie.eq.nle-1) then 
copy_VarCoords(xx1(0,:,:),xclm_a(0,0,:,:))
xclm_em = dim_avg_n_Wrap(xclm_a,0)
copy_VarCoords(xx1(0,:,:),xstd_a(0,0,:,:))
xstd_em = dim_avg_n_Wrap(xstd_a,0)
xclm_std = dim_stddev_n_Wrap(xclm_a,0)
end if 

nu_en = nu_en + 1.0

delete([/fils,TIME2,yyyymm2,xx,xx1/])

end do
printVarSummary(xclm_em)

; xel1!0 = "ens"
; xel1!1 = "time"
; xel2!0 = "ens"
; xel2!1 = "time"
; printVarSummary(xel1)

; xel1_em = dim_avg_n_Wrap(xel1,0)
; xel2_em = dim_avg_n_Wrap(xel2,0)

print(nu_en)


;--------output-------------
if (MODEL.ne."MCB-difseeds".or.MODEL.ne."MCB-reduceseeds") then 
fon=diri+"cesm/clim/"+MODEL+"_"+EXP+"_clim_"+VAR_name+"_"+yrstrt+"-"+yrlast+".nc";
system("rm -f "+fon)
fo=addfile(fon,"c")
fo->xclm_em = xclm_em
fo->xstd_em = xstd_em
fo->xclm_std = xclm_std
end if 

delete([/xclm_em,xclm_a,xstd_em,xstd_a,xclm_std/])

delete(locs)
; end do 
end do 
end do 

end