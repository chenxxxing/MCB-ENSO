load "./func/hb_atm_terms_el.ncl"
load "./func/hb_atm_terms_la.ncl"
load "./func/replace_nan.ncl"
load "./func/hb_atm_terms_extreme_el.ncl"
; load "./func/get_anom_moving_climo.ncl"
load "./func/get_moving_climo.ncl"
begin
PI  = get_pi("float" )   ; type float ; 3.141593
; RE = 6378388
C_TIME_MO_S = 3600.*24.*30 ;s --> mon
rho=1025;      ; Mean density of seawater at 20C, 35 psu: kg/m^2
cp=3993;       ; Specific heat of seawater at 20C, 35 psu, J/kg/K
lamda = rho*cp;and*hmxl ;1000.*4000.*dep   ;density*Cp*depth?!

; Area Box
; maybe check 5-10 for meridional changes as well?
NLAT =  10.
SLAT = -10.
WLON = 90.
ELON = 300.

diri = "/glade/derecho/scratch/chenxing/geog/heatbudget/"
diri0 = "/glade/derecho/scratch/chenxing/geog/heatbudget/"
dirip = "/glade/work/chenxing/geog/"

MODEL_NAME = (/"CAM" ,"MCB","CESM2-WACCM","ARISE-SAI-1.5"/) ;,, ,"GLENS","GLENS","CESM2","CESM2-WACCM"/) ; ;
EXPA = (/"SSP245","SSP245","SSP245","SSP245"/);,"feedback","control","piControl","piControl"/) ;"feedback" ; the first 50 ens or the last 50 ens

yrsa = (/2035,2035,2035,2035/);,2020,2020,400,400 /);(/2035,2035,2035,2035 /);(/2015,2035,2020,2010 /);
; yrla = (/2069,2069,2055,2055,499,499 /);(/2069,2069,2069,2069 /)
yrla = yrsa + 34

; target period
yrstrt2a = yrsa+5 ;ispan(2035+1,2067,1) ;;+20;+11;   ;yrs (/2035/);
yrlast2a = yrla;ispan(2035+2,2068,1) ;yrstrt2a+3;+10;yrl ; 

; climatology based period
yrs_clm = 2035 + 5
yrl_clm = 2069

nm = dimsizes(MODEL_NAME)

;specify mixed layer depth or using the HMXL in the model
SPE_MX = False ;

; High pass filter
FILTER = False

; Calculate not El Nino years or yes
NOTENSOYEAR = False; False ;True
; Use climatology based on historical run; mostly for the initial transition phase analysis
CLIMATE_HIST = False; False ;True 

; For the ENSO function
usePI = False ; use STD of Pi Control for ENSO metrics
PiModelExpa = (/"CESM2_piControl","CESM2_piControl","CESM2-WACCM_piControl","CESM2-WACCM_piControl"/);(/"CAM_SSP245","MCB_SSP245" /) ;(//)
EXTREME = False
ElorLa = "ElNino";"LaNina" ;"ElNino"
IND = "nino3" ;"nino3" ;"nino3pr" ;
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

do im = 0,nm-1

EXP = EXPA(im)
MODEL = MODEL_NAME(im)
yrs = yrsa(im)
yrl = yrla(im)

ymstrt = yrs*100+2
ymlast = (yrl+1)*100+1

diri3 = diri0

PiModelExp = PiModelExpa(im)

locs = systemfunc("ls "+diri3+MODEL+"_"+EXP+"*_heatbudget_var_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc")
; locs = systemfunc("ls "+diri3+"/"+MODEL+"_*_test_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc")
; locs = systemfunc("ls "+diri3+"/old/"+MODEL+"_*_heatbudget_var_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc")
print(locs)
nsa = dimsizes(locs) ;ensemble number

; ;read ATM heat flux terms from heatbudget3_atm_sw.ncl
; locs2 = systemfunc("ls "+diri3+"/"+MODEL+"_*_heatbudget_atmswterms_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc")
; f2   = addfiles(locs2, "r")  ;multiple files
; ListSetType (f2, "join")        ; concatenate (=default)

do ie = 0,nsa-1

  locs_str = str_split(locs(ie), "_")
  ENSN = locs_str(1)
  delete(locs_str)
print(ENSN+" ")

;==============================================================================
; Read Files from cesm_hb1_output.ncl
infile01 = addfile(locs(ie),"r");diri+MODEL+"/"+MODEL+"_"+ENSN+"_heatbudget_var_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc","r")
u_mld0    = infile01->u_mld ;cm/s
v_mld0    = infile01->v_mld
w_mld0    = infile01->w_mld ;cm/s
t_mld0    = infile01->t_mld ;C
t_sub0    = infile01->t_sub
u_sub0    = infile01->u_sub
v_sub0    = infile01->v_sub
w_sub0    = infile01->w_sub
hmxl      = infile01->hmxl ;cm
shf       = infile01->shf ;W/m2
shf_qsw   = infile01->shf_qsw
printVarSummary(w_sub0)
printVarSummary(t_mld0)

u_mld0    = where(isnan_ieee(u_mld0 ),u_mld0@_FillValue,u_mld0 );replace_nan(u_mld0    )
v_mld0    = where(isnan_ieee(v_mld0 ),v_mld0@_FillValue,v_mld0 );replace_nan(v_mld0    )
w_mld0    = where(isnan_ieee(w_mld0 ),w_mld0@_FillValue,w_mld0 );replace_nan(w_mld0    )
t_mld0    = where(isnan_ieee(t_mld0 ),t_mld0@_FillValue,t_mld0 );replace_nan(t_mld0     )
t_sub0    = where(isnan_ieee(t_sub0 ),t_sub0@_FillValue,t_sub0 );replace_nan(t_sub0     )
u_sub0    = where(isnan_ieee(u_sub0 ),u_sub0@_FillValue,u_sub0 );replace_nan(u_sub0    )
v_sub0    = where(isnan_ieee(v_sub0 ),v_sub0@_FillValue,v_sub0 );replace_nan(v_sub0    )
w_sub0    = where(isnan_ieee(w_sub0 ),w_sub0@_FillValue,w_sub0 );replace_nan(w_sub0    )
hmxl      = where(isnan_ieee(hmxl   ),hmxl@_FillValue,hmxl   );replace_nan(hmxl     )
shf       = where(isnan_ieee(shf    ),shf@_FillValue,shf    );replace_nan(shf      )
shf_qsw   = where(isnan_ieee(shf_qsw),shf_qsw@_FillValue,shf_qsw);replace_nan(shf_qsw  )

; from cm -> m
u_mld0 = u_mld0 / 100.
v_mld0 = v_mld0 / 100.
w_mld0 = w_mld0 / 100.
u_sub0 = u_sub0 / 100.
v_sub0 = v_sub0 / 100.
w_sub0 = w_sub0 / 100.
hmxl  = hmxl  / 100.
u_mld0@units = "m/s"
v_mld0@units = "m/s"
w_mld0@units = "m/s"
u_sub0@units = "m/s"
v_sub0@units = "m/s"
w_sub0@units = "m/s"
hmxl@units = "m"

print(any(isnan_ieee(hmxl)))
print(any(ismissing(hmxl)))
;avoid missing values are token as denominator
depth = 80.
hmxl = where(ismissing(hmxl),depth,hmxl)
hmxl = where(isnan_ieee(hmxl),depth,hmxl)
print(any(isnan_ieee(hmxl)))
print(any(ismissing(hmxl)))

if (SPE_MX.eq.True) then
  hmxl = depth
end if

u_mld = u_mld0
v_mld = v_mld0
w_mld = w_mld0
u_sub = u_sub0
v_sub = v_sub0
w_sub = w_sub0
t_mld = t_mld0
t_sub = t_sub0

;--------------climatology & anomoly-------------------------

; band filter
fyr   = 8.
ihp   = 1                             ; low-pass filter: ihp = 0; high-pass ihp = 1; band-pass ihp = 2.
sigma = 1.0                           ; Lanczos sigma
nWgt  = toint(fyr*12+1) ;fyr)+1 ;                           ; odd only
fca   = 1./(fyr*12););
fcb   = -999. ;1./(18.);
wgt  = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

if (FILTER.eq.True) then
  u_mld = wgt_runave_n_Wrap( u_mld0, wgt,  0, 0 )   ;opt < 0 : utilize cyclic conditions
  v_mld = wgt_runave_n_Wrap( v_mld0, wgt,  0, 0 )   ;opt < 0 : utilize cyclic conditions
  w_mld = wgt_runave_n_Wrap( w_mld0, wgt,  0, 0 )   ;opt < 0 : utilize cyclic conditions
  t_mld = wgt_runave_n_Wrap( t_mld0, wgt,  0, 0 )   ;opt < 0 : utilize cyclic conditions
  u_sub = wgt_runave_n_Wrap( u_sub0, wgt,  0, 0 )   ;opt < 0 : utilize cyclic conditions
  v_sub = wgt_runave_n_Wrap( v_sub0, wgt,  0, 0 )   ;opt < 0 : utilize cyclic conditions
  w_sub = wgt_runave_n_Wrap( w_sub0, wgt,  0, 0 )   ;opt < 0 : utilize cyclic conditions
  t_sub = wgt_runave_n_Wrap( t_sub0, wgt,  0, 0 )   ;opt < 0 : utilize cyclic conditions
end if

printVarSummary(t_mld)

ndim = dimsizes(u_mld)
nyr = ndim(0)/12
nmean = 30
if(CLIMATE_HIST) then 

fc1 = addfile(dirip+"clim/CESM2-CAM6_cmip6_ensemblemean_clim_UVEL_1985-2014.nc","r")
fc2 = addfile(dirip+"clim/CESM2-CAM6_cmip6_ensemblemean_clim_VVEL_1985-2014.nc","r")
fc3 = addfile(dirip+"clim/CESM2-CAM6_cmip6_ensemblemean_clim_WVEL_1985-2014.nc","r")
fc4 = addfile(dirip+"clim/CESM2-CAM6_cmip6_ensemblemean_clim_TEMP_1985-2014.nc","r")
; fc5 = addfile(dirip+"clim/CESM2-CAM6_cmip6_ensemblemean_clim_HMXL_1985-2014.nc","r")
uc = fc1->clim(:,:,{SLAT:NLAT},{WLON:ELON})
vc = fc2->clim(:,:,{SLAT:NLAT},{WLON:ELON})
wc = fc3->clim(:,:,{SLAT:NLAT},{WLON:ELON})
tc = fc4->clim(:,:,{SLAT:NLAT},{WLON:ELON})
; hc = fc5->clim(:,{SLAT:NLAT},{WLON:ELON})

uc    = where(isnan_ieee(uc ),uc@_FillValue,uc );replace_nan(u_mld0    )
vc    = where(isnan_ieee(vc ),vc@_FillValue,vc );replace_nan(v_mld0    )
wc    = where(isnan_ieee(wc ),wc@_FillValue,wc );replace_nan(w_mld0    )
tc    = where(isnan_ieee(tc ),tc@_FillValue,tc );replace_nan(t_mld0     )
; hc    = where(isnan_ieee(hc ),hc@_FillValue,hc );replace_nan(hmxl     )

; from cm -> m
uc = uc / 100.
vc = vc / 100.
wc = wc / 100.
uc@units = "m/s"
vc@units = "m/s"
wc@units = "m/s"

uc_mld = dim_avg_n_Wrap(uc(:,{0:8000},:,:),1) 
uc_sub = uc(:,{9000},:,:)
vc_mld = dim_avg_n_Wrap(vc(:,{0:8000},:,:),1) 
vc_sub = vc(:,{9000},:,:)
wc_mld = dim_avg_n_Wrap(wc(:,{0:8000},:,:),1) 
wc_sub = wc(:,{9000},:,:)
tc_mld = dim_avg_n_Wrap(tc(:,{0:8000},:,:),1) 
tc_sub = tc(:,{9000},:,:)

delete([/uc,vc,wc,tc/])

else 
uc_mld = clmMonTLL(u_mld((yrs_clm-yrs)*12:(yrl_clm-yrs)*12-1,:,:));get_moving_climo(u_mld,nmean,nyr,True) ;
vc_mld = clmMonTLL(v_mld((yrs_clm-yrs)*12:(yrl_clm-yrs)*12-1,:,:));get_moving_climo(v_mld,nmean,nyr,True) ;
wc_mld = clmMonTLL(w_mld((yrs_clm-yrs)*12:(yrl_clm-yrs)*12-1,:,:));get_moving_climo(w_mld,nmean,nyr,True) ;
tc_mld = clmMonTLL(t_mld((yrs_clm-yrs)*12:(yrl_clm-yrs)*12-1,:,:));get_moving_climo(t_mld,nmean,nyr,True) ;
uc_sub = clmMonTLL(u_sub((yrs_clm-yrs)*12:(yrl_clm-yrs)*12-1,:,:));get_moving_climo(u_sub,nmean,nyr,True) ;
vc_sub = clmMonTLL(v_sub((yrs_clm-yrs)*12:(yrl_clm-yrs)*12-1,:,:));get_moving_climo(v_sub,nmean,nyr,True) ;
wc_sub = clmMonTLL(w_sub((yrs_clm-yrs)*12:(yrl_clm-yrs)*12-1,:,:));get_moving_climo(w_sub,nmean,nyr,True) ;
tc_sub = clmMonTLL(t_sub((yrs_clm-yrs)*12:(yrl_clm-yrs)*12-1,:,:));get_moving_climo(t_sub,nmean,nyr,True) ;
end if 

ua_mld = calcMonAnomTLL(u_mld,uc_mld ) ;rmMonAnnCycTLL(u_mld); u_mld - uc_mld     ;
va_mld = calcMonAnomTLL(v_mld,vc_mld ) ;rmMonAnnCycTLL(v_mld); v_mld - vc_mld     ;
wa_mld = calcMonAnomTLL(w_mld,wc_mld ) ;rmMonAnnCycTLL(w_mld); w_mld - wc_mld     ;
ta_mld = calcMonAnomTLL(t_mld,tc_mld ) ;rmMonAnnCycTLL(t_mld); t_mld - tc_mld   ;
ua_sub = calcMonAnomTLL(u_sub,uc_sub ) ;rmMonAnnCycTLL(u_sub); u_sub - uc_sub     ;
va_sub = calcMonAnomTLL(v_sub,vc_sub ) ;rmMonAnnCycTLL(v_sub); v_sub - vc_sub     ;
wa_sub = calcMonAnomTLL(w_sub,wc_sub ) ;rmMonAnnCycTLL(w_sub); w_sub - wc_sub     ;
ta_sub = calcMonAnomTLL(t_sub,tc_sub ) ;rmMonAnnCycTLL(t_sub); t_sub - tc_sub  ;


delete([/u_mld0,v_mld0,w_mld0,t_mld0,u_sub0,v_sub0,w_sub0,t_sub0/])

;----------centered finite difference------------------

lat = u_mld&lat
lon = u_mld&lon
time = u_mld&time
nyear = dimsizes(time)/12
; dep = u_mld&z_t

; Center finite differential equation, get Dt/Dx in the heat budget euqation
; the differences between latitude are changing, not the same as longitude or ocean vertical depth
; dTadx --> D(temperature anomaly)/D(x)
; result(n) = (q(n+1)-q(n))/(r(n+1)-r(n))  for the initial value
; result(m) = (q(m)-q(m-1))/(r(m)-r(m-1))  for the last value

dlon = (lon(2)-lon(1))*0.0174533 ; convert to radians
                                 ; pre-allocate space
dTadx = new ( dimsizes(ta_mld), typeof(ta_mld), ta_mld@_FillValue)
dTcdx = new ( dimsizes(tc_mld), typeof(ta_mld), ta_mld@_FillValue)
dHdx = new ( dimsizes(hmxl), typeof(hmxl), hmxl@_FillValue)
do nl=0,dimsizes(lat)-1                      ; loop over each latitude
  dX = 6378388.*cos(0.0174533*lat(nl))*dlon  ; constant at this latitude
  dTadx(:,nl:nl,:) = center_finite_diff_n(ta_mld(:,nl:nl,:), dX, False, 0, 2)
  dTcdx(:,nl:nl,:) = center_finite_diff_n(tc_mld(:,nl:nl,:), dX, False, 0, 2)
  dHdx(:,nl:nl,:) = center_finite_diff_n(hmxl(:,nl:nl,:), dX, False, 0, 2)
end do

dY  = 6378388.*0.0174533
dTady = center_finite_diff_n(ta_mld, dY, False, 0, 1)
dTcdy = center_finite_diff_n(tc_mld, dY, False, 0, 1)
dHdy = center_finite_diff_n(hmxl, dY, False, 0, 1)

 ; ndept = dep(iz) ;interval of vertical grid in ocean
 ; dTadz = -1.*center_finite_diff_n(ta_mld, ndept, False, 0, 1)
 ; dTcdz = -1.*center_finite_diff_n(tc_mld, ndept, False, 0, 1)

copy_VarMeta(ta_mld, dTadx)
copy_VarMeta(ta_mld, dTady)
copy_VarMeta(tc_mld, dTcdy)
copy_VarMeta(tc_mld, dTcdx)
copy_VarMeta(hmxl, dHdx)
copy_VarMeta(hmxl, dHdy)

;------------------------------------------
; Dtemp/Dt
; here the units of time is 1 month
dTadt = center_finite_diff_n(ta_mld,1.,False,0,0)
copy_VarMeta(ta_mld, dTadt)
dTdt = center_finite_diff_n(t_mld,1.,False,0,0)
copy_VarMeta(t_mld, dTdt)
dudt = center_finite_diff_n(u_mld,1.,False,0,0)
copy_VarMeta(u_mld, dudt)
dvdt = center_finite_diff_n(v_mld,1.,False,0,0)
copy_VarMeta(v_mld, dvdt)
dwdt = center_finite_diff_n(w_mld,1.,False,0,0)
copy_VarMeta(w_mld, dwdt)
dHdt = center_finite_diff_n(hmxl,1.,False,0,0)
copy_VarMeta(hmxl, dHdt)
; printVarSummary(dTadt)
; dTadt = dTadt/C_TIME_MO_S
; dHdt = dHdt/C_TIME_MO_S
; dTadt@units = "K/s"
; dHdt@units = "cm/s"

;------------heat flux-----------
; heat flux term should be SW+LW+SH+LH - penertrated(q_pen)
q_pen = shf_qsw*(0.58*exp(-hmxl/0.35)+0.42*exp(-hmxl/23))
q_shf = shf/(lamda*hmxl)

q_pen = q_pen/(lamda*hmxl);
q_pen = rmMonAnnCycTLL(q_pen);q_pen - get_moving_climo(q_pen,nmean,nyr,True) ;
q_shf = rmMonAnnCycTLL(q_shf);q_shf - get_moving_climo(q_shf,nmean,nyr,True) ;
copy_VarCoords(u_mld,q_pen)
copy_VarCoords(u_mld,q_shf)
printVarSummary(q_pen)
;-------------------budget-------------------
; check the equation
; umdSmdx,updSmdx,umdSpdx,updSpdx,vmdSmdy,vpdSmdy,vmdSpdy,vpdSpdy,dSpdt,mnupdSpdx,mnvpdSpdy
; ucdTcdx,uadTcdx,ucdTadx,uadTadx,vcdTcdy,vadTcdy,vcdTady,vadTady,dTadt,clm_uadTadx,clm_vadTady
; w_entr,wmdTmdz,wpdTmdz,wmdTpdz,wpdTpdz
; wcdTcdz,wadTcdz,wcdTadz,wadTadz

; w vertical entrainment volocity
; why directly use u_mld?
w_entr = dHdt + u_mld*dHdx + v_mld*dHdy + w_sub ;dHdt/C_TIME_MO_S
wc_e = clmMonTLL(w_entr);get_moving_climo(w_entr,nmean,nyr,True) ;
wa_e = rmMonAnnCycTLL(w_entr);w_entr - wc_e ; 

;;;---------------------
wc_e_expand = w_entr
vc_mld_expand = va_mld ;  va_mld; vc_mld ;
uc_mld_expand = ua_mld ;  ua_mld; uc_mld ;
tc_mld_expand = ta_mld ;  ta_mld; tc_mld ;
tc_sub_expand = ta_sub ;  ta_sub; tc_sub ;
dTcdy_expand  = dTady ; dTady;   dTcdy ;
dTcdx_expand  = dTadx ; dTadx;   dTcdx ;
do imon = 0,11
  wc_e_expand(imon::12,:,:) = conform_dims(dimsizes(wc_e_expand(imon::12,:,:)),    wc_e(imon,:,:),(/1,2/))
  vc_mld_expand(imon::12,:,:) = conform_dims(dimsizes(vc_mld_expand(imon::12,:,:)),vc_mld(imon,:,:),(/1,2/))
  uc_mld_expand(imon::12,:,:) = conform_dims(dimsizes(uc_mld_expand(imon::12,:,:)),uc_mld(imon,:,:),(/1,2/))
  tc_mld_expand(imon::12,:,:) = conform_dims(dimsizes(tc_mld_expand(imon::12,:,:)),tc_mld(imon,:,:),(/1,2/))
  tc_sub_expand(imon::12,:,:) = conform_dims(dimsizes(tc_sub_expand(imon::12,:,:)),tc_sub(imon,:,:),(/1,2/))
  dTcdy_expand(imon::12,:,:) = conform_dims(dimsizes(dTcdy_expand(imon::12,:,:)),  dTcdy(imon,:,:),(/1,2/))
  dTcdx_expand(imon::12,:,:) = conform_dims(dimsizes(dTcdx_expand(imon::12,:,:)),  dTcdx(imon,:,:),(/1,2/))
end do

delete([/wc_e,  vc_mld,  uc_mld,  tc_mld,  tc_sub,  dTcdy,  dTcdx/])
wc_e   = wc_e_expand
vc_mld = vc_mld_expand
uc_mld = uc_mld_expand
tc_mld = tc_mld_expand
tc_sub = tc_sub_expand
dTcdy  = dTcdy_expand
dTcdx  = dTcdx_expand
delete([/wc_e_expand,  vc_mld_expand,  uc_mld_expand,  tc_mld_expand,  tc_sub_expand,  dTcdy_expand,  dTcdx_expand/])

; Heaviside step function used for w entrainment
; Only positive sign will be reserved
w_sign = wc_e
w_sign = where(wc_e.gt.0,1.,0.)


wadTcdz = w_sign*wa_e*(tc_mld-tc_sub)/hmxl
wcdTadz = w_sign*wc_e*(ta_mld-ta_sub)/hmxl
wadTadz = w_sign*wa_e*(ta_mld-ta_sub)/hmxl
wcdTcdz = w_sign*wc_e*(tc_mld-tc_sub)/hmxl ;??? why not include this term

ucdTcdx = uc_mld*dTcdx
ucdTadx = uc_mld*dTadx
vcdTcdy = vc_mld*dTcdy
vcdTady = vc_mld*dTady
uadTcdx = ua_mld*dTcdx
vadTcdy = va_mld*dTcdy
uadTadx = ua_mld*dTadx
vadTady = va_mld*dTady

;--------------------------------
clm_uadTadx = get_moving_climo(uadTadx,nmean,nyr,True) ;clmMonTLL(uadTadx)
clm_vadTady = get_moving_climo(vadTady,nmean,nyr,True) ;clmMonTLL(vadTady)

clm_uadTadx_expand = ua_mld
clm_vadTady_expand = va_mld
do imon = 0,11
  clm_uadTadx_expand(imon::12,:,:) = conform_dims(dimsizes(clm_uadTadx_expand(imon::12,:,:)),clm_uadTadx(imon,:,:),(/1,2/))
  clm_vadTady_expand(imon::12,:,:) = conform_dims(dimsizes(clm_vadTady_expand(imon::12,:,:)),clm_vadTady(imon,:,:),(/1,2/))
end do
delete([/clm_uadTadx,  clm_vadTady/])
clm_uadTadx = clm_uadTadx_expand
clm_vadTady = clm_vadTady_expand
delete([/clm_uadTadx_expand,clm_vadTady_expand/])

copy_VarCoords(ua_mld,dTadt)
copy_VarCoords(ua_mld,ucdTadx)
copy_VarCoords(ua_mld,vcdTady)
copy_VarCoords(ua_mld,uadTcdx)
copy_VarCoords(ua_mld,vadTcdy)
copy_VarCoords(ua_mld,clm_uadTadx)
copy_VarCoords(ua_mld,clm_vadTady)
copy_VarCoords(ua_mld,wadTcdz)
copy_VarCoords(ua_mld,wcdTadz)
copy_VarCoords(ua_mld,wadTadz)
printVarSummary(uadTcdx)
printVarSummary(vcdTady)

;;;;;;; all dynamic terms together
ndim = dimsizes(dTadt)
dia   = new((/19,ndim(0),ndim(1),ndim(2)/), float,dTadt@_FillValue)
dia(0,:,:,:)  = dTadt
; dia(2,:,:,:)  = ucdTcdx *-1 *C_TIME_MO_S
; dia(3,:,:,:)  = vcdTcdy *-1 *C_TIME_MO_S
dia(2,:,:,:)  = ucdTadx *-1 *C_TIME_MO_S
dia(3,:,:,:)  = vcdTady *-1 *C_TIME_MO_S
dia(4,:,:,:)  = uadTcdx *-1 *C_TIME_MO_S
dia(5,:,:,:)  = vadTcdy *-1 *C_TIME_MO_S
dia(6,:,:,:)  = uadTadx *-1 *C_TIME_MO_S
dia(7,:,:,:)  = vadTady *-1 *C_TIME_MO_S
dia(8,:,:,:)  = clm_uadTadx *C_TIME_MO_S
dia(9,:,:,:)  = clm_vadTady *C_TIME_MO_S
dia(10,:,:,:) = wadTcdz *-1 *C_TIME_MO_S
dia(11,:,:,:) = wcdTadz *-1 *C_TIME_MO_S
dia(12,:,:,:) = wadTadz *-1 *C_TIME_MO_S
dia(13,:,:,:) = q_pen *-1 *C_TIME_MO_S
dia(14,:,:,:) = q_shf *C_TIME_MO_S
dia(15,:,:,:)  = dTdt
dia(16,:,:,:) = ucdTcdx *-1 *C_TIME_MO_S
dia(17,:,:,:) = vcdTcdy *-1 *C_TIME_MO_S
dia(18,:,:,:) = wcdTcdz *-1 *C_TIME_MO_S
dia(1,:,:,:)  = dim_sum_n_Wrap(dia(2:13,:,:,:),0) ;summarize all terms in the right side of the equation
copy_VarCoords(u_mld,dia(0,:,:,:))

printVarSummary(dia)

TERM_NAME = (/"dTadt","Sum","ucdTadx","vcdTady","uadTcdx",\
            "vadTcdy","uadTadx","vadTady","clm_uadTadx","clm_vadTady",\;"ucdTcdx","vcdTcdy",
            "wadTcdz","wcdTadz","wadTadz","q_pen","q_shf",\;/);,"fsns(atm)","flns(atm)","shflx(atm)","lhflx(atm)"/)
            "dTdt","ucdTcdx","vcdTcdy","wcdTcdz"/)
dia!0 = "terms"
dia@terms = TERM_NAME
dia@units = "C/mon"


dterms   = dia ; new((/13,ndim(0),ndim(1),ndim(2)/), float,dTadt@_FillValue)
dterms(0,:,:,:)  = tc_mld
dterms(1,:,:,:)  = ta_mld
dterms(2,:,:,:)  = uc_mld
dterms(3,:,:,:)  = ua_mld
dterms(4,:,:,:)  = vc_mld
dterms(5,:,:,:)  = va_mld
dterms(6,:,:,:)  = wc_e
dterms(7,:,:,:)  = wa_e
dterms(8,:,:,:)  = dTcdx
dterms(9,:,:,:)  = dTadx
dterms(10,:,:,:)  = dTcdy
dterms(11,:,:,:)  = dTady
dterms(12,:,:,:)  = (tc_mld-tc_sub)/hmxl
dterms(13,:,:,:)  = (ta_mld-ta_sub)/hmxl

copy_VarCoords(dia,dterms)
dterms@units = ""

if (NOTENSOYEAR) then 
yrs2 = 2035
yrl2 = yrs2 + 3
fon1=dirip+"heatbudget/enso/"+MODEL+"_"+ENSN+"_heatbudget_terms_"+yrs2+"-"+yrl2+".nc"
system("rm -f "+fon1)
fo=addfile(fon1,"c")
fo->dia     = dia(:,(yrs2-yrs)*12:(yrl2-yrs)*12-1,:,:)
fo->dterms     = dterms(:,(yrs2-yrs)*12:(yrl2-yrs)*12-1,:,:)

else

;;;;------------ setting for El Nino cases-------------

print(locs(ie))
print(ENSN)

EXP = "" ; Since ENSN includes EXP


do is = 0,dimsizes(yrstrt2a)-1
yrstrt2 = yrstrt2a(is)
yrlast2 = yrlast2a(is)

hb_el = hb_atm_terms_el(diriw,dia,IND,MODEL,EXP,ENSN,RMMME_EL,usePI,PiModelExp,EXTREME,ElorLa,dia&time,yrstrt2,yrlast2)
term_el = hb_atm_terms_el(diriw,dterms,IND,MODEL,EXP,ENSN,RMMME_EL,usePI,PiModelExp,EXTREME,ElorLa,dterms&time,yrstrt2,yrlast2)
copy_VarMeta(u_mld(0,:,:),hb_el(0,0,0,:,:))
copy_VarMeta(u_mld(0,:,:),term_el(0,0,0,:,:))

fon1=diri+"/enso/"+MODEL+"_"+ENSN+"_heatbudget_terms_"+OWNSTD+EXTREME_str+ElorLa+"_"+yrstrt2+"-"+yrlast2+".nc"
system("rm -f "+fon1)
fo=addfile(fon1,"c")
fo->hb_el     = dim_avg_n_Wrap(hb_el,1)
fo->term_el     = dim_avg_n_Wrap(term_el,1)
; fo->hb_el     = hb_el(:,1,:,:,:)
delete(hb_el)
delete(term_el)

end do 

end if 

delete([/dTadt ,dTdt ,ucdTcdx ,vcdTcdy,ucdTadx ,vcdTady,uadTcdx,vadTcdy,clm_uadTadx,clm_vadTady,wadTcdz,wcdTadz,wadTadz,wcdTcdz/])
delete([/dTady,dTcdy,dHdy,dTadx ,dTcdx ,dHdt /])
delete([/u_mld   ,v_mld   ,w_mld   ,t_mld,t_sub,u_sub   ,v_sub   ,w_sub   ,hmxl    /])
delete([/uc_mld,vc_mld,wc_mld,tc_mld,uc_sub,vc_sub,wc_sub,tc_sub,ua_mld,va_mld,wa_mld,ta_mld,ua_sub,va_sub,wa_sub,ta_sub/])
delete([/q_pen,shf_qsw,shf,dia,wc_e,wa_e/]);q_flux
end do
delete([/locs/])
end do

end
