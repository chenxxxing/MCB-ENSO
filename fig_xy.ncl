load "./func/get_anom_moving_climo.ncl"
load "./func/get_moving_climo.ncl"
load "./func/get_ensemble_mean.ncl"
load "./func/get_el_nino_cases.ncl"
load "./func/get_la_nina_cases.ncl"
; Fig 1a moving STD changes of MCB and SAI and their control runs
; Fig 1b STD
; Fig 3a GMST
;---
undef("add_y_errorbar")
procedure add_y_errorbar(wks, plot, x[*]:numeric,y[*]:numeric, yerror[*]:numeric, res)
local dimz, xpoints, ypoints, gsres, i
begin
  gsres = res
  dimz  = dimsizes(y)

  xpoints = (/x, x/)
  ypoints = (/ y-yerror, y+yerror/)
  do i=0, dimz(0)-1
    str1 = unique_string("y_errorbar")
    plot@$tostring(str1+i)$ = gsn_add_polyline(wks, plot, xpoints(:,i), ypoints(:,i), gsres )
  end do
end

begin
diri = "/glade/work/chenxing/geog/"
dirip = "/glade/u/home/chenxing/geog/"

  ; yrs1 = 1950
  ; yrl1 = 1999
  ; yrs2 = 2050
  ; yrl2 = 2099
  ; ymstrt1 = yrs1*100+1
  ; ymlast1 = yrl1*100+12
  ; ymstrt2 = yrs2*100+1
  ; ymlast2 = yrl2*100+12

;from lens_index.ncl
diri3 = "/glade/work/chenxing/geog/"
SEASON = (/"DJF","MAM","JJA","SON" /)

; ; Change to false RMMME_EL for single ensemble data
; MODELa = (/"CAM","MCB","MCB-reduceseeds","MCB-reduceseeds","MCB-reduceseeds","MCB-reduceseeds"/)
; EXPa = (/"SSP245","SSP245","SSP245-MCB-80PCT-40PCT","SSP245-MCB-80PCT-50PCT","SSP245-MCB-80PCT-60PCT","SSP245-MCB-80PCT-70PCT"/)

; MODELa = (/"MCB-difseeds","MCB-difseeds","MCB-difseeds","MCB-difseeds"/)
; EXPa = (/"SSP245-CMIP6-MCB-025PCT","SSP245-CMIP6-MCB-050PCT","SSP245-CMIP6-MCB-075PCT","SSP245-CMIP6-MCB-125PCT"/)

MODELa = (/"CAM","MCB","MCB-feed","MCB-feed","CESM2-WACCM","ARISE-SAI-1.5"/);,"MCB-reduceseeds"/);/);,"CAM"/); ,(/"GLENS","GLENS"/); 
EXPa = (/"SSP245","SSP245","MCB-feedback-1DOF","MCB-feedforward-1DOF","SSP245","SSP245"/);,"SSP245-MCB-80PCT-60PCT"/);(/"control","feedback"/) ;

; yrs_lens = (/2020,2010/) ;(/2015,2035 /)
; yrl_lens = (/2099,2097/) ;(/2069,2069 /)

yrstrt = 2035;2035;2020; start year
yrlast = 2068;2054;2055;2069; end year

SEASON_used = "DJF"
  
; Nino 1+2 (0-10S, 90W-80W), Nino 3 (5N-5S, 150W-90W),
; Nino 3.4/ONI (5N-5S, 170W-120W) and Nino 4 (5N-5S, 160E-150W)
NLAT_ind =   5.
SLAT_ind =  -5.
WLON_ind =  360.-150.;170.;
ELON_ind =  360.-90.;120.;

; Nino: 4.0 ; CLD: 0.4; FSNS: 40. OMEGA500: 0.1; WWV: 1e+16; MSE: 4000; U10: 1; photoC: 0.07 ; GMST:1.? ;TS.SEP:2.; pr:2.?
IND = "TREFHTgmst" ;"gmst" ;"WWV" ;"nino34" ;"FSNS.SEP" ;"TS.WP" ;"U1000hPa.nino4" ;"OMEGA500.nino3" ;"prthres" ;"pr.wp" ;"gmst" ;"Usfc.nino4" ;"FSNS.SEP" ;"WWV" ;"nino34" ;"OMEGA500.nino3" ;"CLDHGH.wp" ;"CLDLOW.nino3" ;"CLDLOW.SEP" ;"FSNS.SEP" ;"nino34" ;"WWV" ; "nino34" ;"nino4" ;"nino3";
VALUE = 1.;1e+16;4.;3e+14 ; 2.;
LONGNAME = "GMST" ;"Warm water volume" ;"Nino3.4" ;"SST over Warm Pool" ;"U at 1000hPa over nino4" ;"SST zonal gradient";"Pr over Warm Pool" ;

; VAR = "PRECC"
EXTREME = False ; Extreme El Nino?
DETREND = False ;False ;True
FILTER = False ;True ;False
MOCLIM = False ;True
RMMME = False; True

; Defination of El Nino
ElorLa = "LaNina" ; El Nino or La Nina? "ElNino" "LaNina"
NINO_IND = "nino34" ; "nino3" ;"nino3pr"; "nino4" ;"nino34" ;

; For the ENSO function
usePI = False ; use STD of Pi Control for ENSO metrics
PiModelExpa = (/"CESM2_piControl","CESM2_piControl","CESM2_piControl","CESM2_piControl","CESM2_piControl","CESM2-WACCM_piControl","CESM2-WACCM_piControl","CESM1_piControl","CESM1_piControl"/)
; EXTREME = True
; ElorLa = "ElNino";"LaNina" ;"ElNino"
; IND = "nino3pr" ;"nino4" ;
diriw = "/glade/work/chenxing/geog/cesm/" ;ENSO index path

EXTREME_str = ""
if(EXTREME) then 
EXTREME_str = "extreme"
end if 


wks         = gsn_open_wks("pdf",dirip+"cesm_xy_"+IND)
plot  = new(30, graphic)
plot1 = new(30, graphic)
plot2 = new(30, graphic)
plot3 = new(30, graphic)
plot4 = new(30, graphic)
plot5 = new(30, graphic)
plot6 = new(30, graphic)
plot7 = new(30, graphic)

; Define the section length of the ENSO event
nyear1 = 3 ;1;2
nyear2 = 3 ;1;2;4
nyra = nyear1+nyear2
nmon = nyra*12

;---------read output---------------
; from reg_cmip5.ncl reg_cmip6.ncl
;cmip5_historical_GISS-E2-R_r6i1p1_nino34_1861-2004.nc


nsa = dimsizes(MODELa)

dif_el = new(nmon,"float")
std_all = new((/nsa,2/),"float")

do ia = 0,nsa-1

EXP = EXPa(ia)
MODEL = MODELa(ia)
PiModelExp = PiModelExpa(ia)

if(MODEL.eq."MCB-reduceseeds") then 
  RMMME_EL = False ; remove ensemble mean for ENSO index?
else 
  RMMME_EL = True ; remove ensemble mean for ENSO index?
end if 

;MCB-difseeds_SSP245-CMIP6-MCB-025PCT.000_nino34_2035-2069.nc
fils = systemfunc("ls "+diri3+"cesm/"+IND+"/"+MODEL+"_"+EXP+"*_"+IND+"_*.nc")
print(fils)
f   = addfiles(fils, "r")  ;multiple files
ListSetType (f, "join")        ; concatenate (=default)
TIME2=f[0]->time
yyyymm2=cd_calendar(TIME2, -1)
printMinMax(yyyymm2, True)

ymstrt = yrstrt*100+2
ymlast = (yrlast+1)*100+1

ymstrts = ind(yyyymm2.eq.ymstrt)
ymlasts = ind(yyyymm2.eq.ymlast)
print(ymstrts+" <--start end--> "+ymlasts)

xx  = f[:]->index(:,ymstrts:ymlasts);(:,:ymlasts);ymstrts
printVarSummary(xx)

if(isStrSubset(IND, "pr" ).and.IND.ne."prthres") then 
    xx = xx*1000*24*3600 ;prate-->precip  m/s-->mm/day
    xx@units = "mm/day"
end if

if(IND.eq."nino34".or.IND.eq."nino4".or.LONGNAME.eq."GMST".or.isStrSubset(IND, "TS" )) then 
    xx = xx -273.15
    xx@units = "degC"
end if

xx1 = xx
if(DETREND)then
  ; a seperated detrend for historical and future RCP periods
  ; xx = dtrend_msg_n(xx&time, xx, True, False, 1)

  yy = 199001;200512
  ymrcps = ind(yyyymm2.eq.yy)
  tt = xx&time
  xx1(:,ymrcps:) = dtrend_msg_n(tt(ymrcps:),xx(:,ymrcps:),True,True,1)
  xx1(:,:ymrcps) = dtrend_msg_n(tt(:ymrcps),xx(:,:ymrcps),True,True,1)
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
xx1 = wgt_runave_n_Wrap( xx, wgt,  0, 1 )   ;opt < 0 : utilize cyclic conditions
end if

  ndim = dimsizes(xx1)

  if(MOCLIM) then
  do ie = 0,ndim(0)-1
    nmean = 10;30 ;moving window
    nyr = ndim(1)/12
    ISMON = True
    xxc = get_moving_climo(xx(ie,:),nmean,nyr,ISMON)
    xx1(ie,:) = xx(ie,:) - xxc
  end do
  delete([/xxc/])

  end if

  if(RMMME) then 

    ; Method 1

    dirik = ""
    files_em = diri3+"cesm/"+IND+"/"+MODEL+"_"+EXP+"*_"+IND+"_*.nc"
    xx_mean = get_ensemble_mean(dirik,files_em,"index",True,121)

    do ie = 0,ndim(0)-1

        xx1(ie,:) = xx(ie,:) - xx_mean(ymstrts:ymlasts)
    end do

    delete(xx_mean)

    ; ; Method 2
    ; ; read MME data for RMMME
    ; print(diri3+"cesm/mme/"+MODEL+"_"+EXP+"_"+VAR+"_mme.nc")
    ; f_mme = addfile(diri3+"cesm/mme/"+MODEL+"_"+EXP+"_"+VAR+"_mme.nc","r")
    ; if (VAR.eq."PRECC") then 
    ;     x1  = f_mme->$VAR$
    ;     f_mme2 = addfile(diri3+"cesm/mme/"+MODEL+"_"+EXP+"_PRECL_mme.nc","r")
    ;     x2  = f_mme2->PRECL
    ;     xx_mean1 = x1
    ;     xx_mean1 = x1 + x2 
    ;     copy_VarMeta(x1,xx_mean1)
    ;     delete([/x1,x2,f_mme2/])
    ; else 
    ;     xx_mean1 = f_mme->$VAR$ 
    ; end if 

    ; lat = xx_mean1&lat
    ; rad    = 4.0*atan(1.0)/180.0
    ; clat   = cos(lat*rad)
    ; copy_VarCoords(xx_mean1(0,:,0), clat)  
    ; xx_mean = wgt_areaave_Wrap(xx_mean1(ymstrts:ymlasts,{SLAT_ind:NLAT_ind},{WLON_ind:ELON_ind}),clat({SLAT_ind:NLAT_ind}), 1.0, 1)
  
    ; xx1 = xx - conform_dims(dimsizes(xx), xx_mean,1)

    ; delete([/xx_mean,xx_mean1/])

  end if 

delete(ndim)

ndim_xx = dimsizes(xx)
nf = ndim_xx(0);dimsizes(fils) ; file number

x_annual = xx1(:,::12)
do ie = 0,nf-1
  x_annual(ie,:) = month_to_annual(xx1(ie,:),1)
end do

;--------bandpass filter (for envelope line)--------------------------------
ca    = 1.*12        ; band start (longer period)
cb    = 7.*12        ; band end

fca   = 1.0/ca      ; 'left'  frequency
fcb   = 1.0/cb      ; 'right' frequency

dims  = 1           ; 'time' dimension

opt   = True        ; options to set
opt@return_envelope = True ; time series of filtered and envelope values

xx_bf = bw_bandpass_filter (xx1,fca,fcb,opt,dims)       ; (xx,fca,fcb,opt,dims)
; copy_VarMeta(xx, xx_bf)
xx_bf@long_name = "Band Pass: "+cb+"-"+ca+" month"
xx_bf!2 = "time"
; printVarSummary(xx_bf)

ndimb = dimsizes(xx_bf)

;-----------DJF & Mean removed & Average------------------------------------

nn1 = dimsizes(xx&time)
xx_sea = new((/nf,nn1/12/),"float",xx@_FillValue)
bf_sea = new((/2,nf,ndimb(2)/12/),"float",xx@_FillValue)
; printVarSummary(bf_sea)
xa1 = xx1
; xa0_annual = xx_sea
do i = 0,nf-1
  xx_sea(i,:) = month_to_seasonN(xx1(i,:),SEASON_used)
  bf_sea(0,i,:) = dim_avg_n_Wrap(month_to_seasonN(xx_bf(0,i,:),SEASON_used),0)
  bf_sea(1,i,:) = dim_avg_n_Wrap(month_to_seasonN(xx_bf(1,i,:),SEASON_used),0)
  if (ia.eq.0) then 
  save_ssp_avg = new(12,"float")
  do imon = 0,11
    save_ssp_avg(imon) = avg(xx1(:,imon::12))
    xa1(i,:) = rmAnnCycle1D(xx1(i,:))
  end do 
    ; print(save_ssp_avg)
    ssss = avg(xx1(i,:))
    ; print(ssss)
  else
  do imon = 0,11
    xa1(i,imon::12) = xx1(i,imon::12) - save_ssp_avg(imon)
  end do 
  xa1(i,:) = rmAnnCycle1D(xa1(i,:))
  ; xx1(i,:) = xx1(i,:) - ssss
  end if 
  ; xa1(i,:) = rmAnnCycle1D(xx1(i,:))
  ; xa0_annual(i,:) = month_to_annual(rmAnnCycle1D(xx1(i,:)),1)
end do

nyr = ndimb(2)/12
xa_sea = dim_rmvmean_n_Wrap(xx_sea,1)

; moving climatology removed for every 30-year
; NO NEEDS HERE
; nmean = 30 ; 30-year climatology
; do i = 0,nf-1
;   xa_sea(i,:) = get_anom_moving_climo(xx_sea(i,:),nmean,nyr,False)
; end do

xx_me = dim_avg_n_Wrap(xa_sea,0)
bf_me = dim_avg_n_Wrap(bf_sea,1)

;-----------moving index------------------------------------

nmyr = 10
xm_std = new((/nf,nn1/12/),"float",xx@_FillValue)
; xm_clm = new((/nf,nn1/12/),"float",xx@_FillValue)
do iy = nmyr/2,nn1/12-nmyr/2-1
  xm_std(:,iy) = dim_stddev_n_Wrap(xa_sea(:,iy-nmyr/2:iy+nmyr/2),1)
  ; xm_clm(:,iy) = dim_avg_n_Wrap(xa0_annual(:,iy-nmyr/2:iy+nmyr/2),1)
end do
xm_std_me = dim_avg_n_Wrap(xm_std,0)
; xm_clm_me = dim_avg_n_Wrap(xm_clm,0)

tmp = dim_stddev_n_Wrap(xa_sea(:,5:),1)
std_all(ia,0) = avg(tmp)
std_all(ia,1) = stddev(tmp)
delete(tmp)

; print(avg(dim_stddev_n_Wrap(xa_sea,1)))
; print(avg(dim_stddev_n_Wrap(xa_sea(:,:50),1)))
; print(avg(dim_stddev_n_Wrap(xa_sea(:,100:),1)))
;--------------- El Nino ----------------------

;/glade/work/chenxing/fuel/data/lens/nino3ua/MPI-ESM_r10i1p1_nino3ua_1850-2099.nc
; locs_str = str_split(fils(1), "_"); "/")
; print("'" + locs_str + "'")

; bb = str_split(locs_str(3), "-")

;  yrs = toint( bb(0))
;  cc = str_split(bb(1), ".")
;  yrl = toint( cc(0))

; print(yrs+"-"+yrl)
; delete(bb)

ENSN = new(nf,"string")
do i = 0,nf-1
;/glade/work/chenxing/geog/cesm/nino34/ARISE-SAI-1.5_SSP245.008_nino34_2035-2069.nc
;CAM_SSP245.005_nino34_2035-2069.nc
;CESM2-WACCM_SSP245.007_nino34_2035-2069.nc
;MCB_SSP245.006_nino34_2035-2069.nc
;MCB-difseeds_SSP245-CMIP6-MCB-025PCT.000_nino34_2035-2069.nc

    aa = str_split(fils(i), "/")
    ; bb = str_index_of_substr(aa(1), "i1p1", 1)
    bb = str_split(aa(6), "_")
    cc = str_split(bb(1), ".")
    ENSN(i) = cc(1) ;str_get_cols(aa(1),"r", "i")
    delete([/aa,bb,cc/])

end do
print(""+ENSN)
delete([/fils,TIME2,yyyymm2/])
;---------------find El Nino cases----------------------

; avoid the transition phase because of the injection
yrs1_el = yrstrt+5 ;yrstrt+1
yrl1_el = yrlast-3 ;-1  ;

xx_el1 = new((/nf,100,nmon/), typeof(xa1),xa1@_FillValue)

case_ind = new((/nf,nn1/12/), integer,xa1@_FillValue)

xa_el = xa1
xa_el = xa1@_FillValue

do ic = 0,nf-1

  cases1 = get_el_nino_cases(diriw,MODEL,EXP,ENSN(ic),NINO_IND,RMMME_EL,usePI,PiModelExp,EXTREME,ElorLa,yrs1_el,yrl1_el)
    ; print(cases1+yrs1_el)
  nel1 = dimsizes(cases1)

if (.not.ismissing(cases1(0)))then

do ie =0,nel1-1
  if(cases1(ie).ne.0)then
    kk = (cases1(ie)-nyear1+(yrs1_el-yrstrt))*12
    ll = kk+nmon-1
    ; print(kk+"-"+ll)
    xx_el1(ic,ie,:) = xa1(ic,kk:ll)

    xa_el(ic,kk+10:ll-22) = xa1(ic,kk+10:ll-22)

    case_ind(ic,cases1(ie)) = 1
    end if
end do

end if 

delete([/cases1/])
end do

case_ind!0  = "ens"
case_ind!1 = "time"

num_case_en = dim_sum_n_Wrap(case_ind,1)
; print(num_case_en)

copy_VarCoords(xa1(:,0),xx_el1(:,0,0))
xx_el1!0 = "ens"
xx_el1!1 = "cases"
xx_el1!2 = "time"
; printVarSummary(xx_el1)

xx_el2 = reshape(xx_el1,(/nf*100,nmon/)) ;dim_avg_n_Wrap(xx_el1,1)

  ;---------------moving El Nino composite----------------------

    ndimx = dimsizes(xx)

    lenth_mv = 16 ; indicate moving years; prefer even number

  xm_el_com = new((/nf,nn1/12/), typeof(xa1),xa1@_FillValue)

  do istr_mv = 1,yrlast-yrstrt-lenth_mv-1

      ; print("moving during "+yrs1_el+"-"+yrl1_el)

    xx_mv_el = new((/nf,100/), typeof(xa1),xa1@_FillValue)

    do ic = 0,nf-1  ;ensemble

      yrs2_el = yrstrt+istr_mv
      yrl2_el = yrs2_el+lenth_mv

      cases1 = get_el_nino_cases(diriw,MODEL,EXP,ENSN(ic),NINO_IND,RMMME_EL,usePI,PiModelExp,EXTREME,ElorLa,yrs2_el,yrl2_el)
            
      ; cases1 = get_la_nina_cases(MODEL,ENSN,IND,yrs2_el,yrl2_el)
      if(.not.ismissing(cases1(0))) then 
    ;   if(dimsizes(cases1).gt.1) then 

      nel1 = dimsizes(cases1)

      do ie =0,nel1-1 ; each El Nino cases
          if(cases1(ie).ne.0)then
          ; kk = (cases1(ie)-nyear1+(yrs2_el-yrstrt))*12
          ; ll = kk+nmon-1
          ; print(kk+"-"+ll)
          xx_mv_el(ic,ie) = xa_sea(ic,cases1(ie)+(yrs2_el-yrstrt))

          end if
      end do

    ;   end if 
      end if 
      delete([/cases1/])

    end do 

      xm_el_com(:,toint(istr_mv+lenth_mv/2)) = dim_avg_n_Wrap(xx_mv_el,1)

      delete([/xx_mv_el/])

    end do 

    xm_el_com!0 = "ens"
    xm_el_com!1 = "year"
    printVarSummary(xm_el_com)



;---------Difference between control (odd) and exp (even) --------------
if (mod(ia,2).eq.0) then 
    aveX = dim_avg_n_Wrap(dim_avg_n_Wrap(xx_el1,1),0)
    varX = dim_variance_n_Wrap(xx_el1, (/0,1/))
    sX = dimsizes(ind(ndtooned(.not.ismissing(xx_el1(:,:,0)))))
    dif_el = aveX
else if (mod(ia,2).eq.1) then 
    aveY = dim_avg_n_Wrap(dim_avg_n_Wrap(xx_el1,1),0)
    varY = dim_variance_n_Wrap(xx_el1, (/0,1/))
    sY = dimsizes(ind(ndtooned(.not.ismissing(xx_el1(:,:,0)))))
    dif_el = aveY - dif_el ;Control - EXP run

    ;---------Significant test------------------
    ; two sample t test
    iflag   = True                                   ; population variance similar
    tval_opt= False                                  ; p-value only
    prob = 100.*(1. - ttest(aveX,varX,sX, aveY,varY,sY, iflag, True))
    ; print(aveX)
    ; print(varX)
    ; print(sX)
    ; print(aveY)
    ; print(varY)
    ; print(sY)
    ; print("p value is")
    ; print(prob(0,:))
    ; ;-------t-test---------------------------------
    ; pra_std = stddev(dif_el)

    ; df = dif_el
    ; df = dimsizes(dif_el)
    ; b = dif_el
    ; b = 0.5
    ; pr_tval = dif_el
    ; pr_tval = (dif_el-0)*sqrt(40)/pra_std
    ; pr_prob = (1.-betainc( df/(df+pr_tval^2), df/2.0, b))*100.  ; probability in %
    ; printMinMax(pr_prob, 0)
    ; print(pr_prob)

    ; delete([/df,b/])

    ; sig_pra1 = dif_el
    ; sig_pra1 = where(pr_prob.ge.90., abs(dif_el), dif_el@_FillValue)
    ; print(pr_prob)

end if 
end if 
printVarSummary(dif_el)


;=========plot=========================

;*******************************************
; time series (principal component) plot
;*******************************************

  gsn_define_colormap(wks,"seaice_2")
  colors = ispan(2, 17, 1)   ; indices into color table
  colors2 = ispan(4, 17, 2)   ; indices into color table
  colors1 = ispan(10, 18, 1)   ; indices into color table
  line_dash = ispan(1,10,1) ;(/1,2,3,4,0,5 /)
  colors3 = (/"blue","forestgreen","darkgoldenrod1","coral1","brown","purple","gray35"/)

; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

  res = True
  res@gsnDraw = False        ;dont draw
  res@gsnFrame = False        ;dont advance frame
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res@vpHeightF = 0.3
  res@vpWidthF  = 1.0;0.8

  res@tmXTOn    = False
  res@tmYROn    = False
  ;res@gsnXYBarChart            = True              ; Create bar plot
  ;res@gsnXYBarChartOutlineOnly = True


  ; res@gsnYRefLine           = 0.0             ; reference line
  ; res@gsnYRefLineColor      = "grey50"
  ; res@gsnYRefLineDashPattern = 1
  ; res@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  ; res@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
  ; res@gsnLeftStringFontHeightF  = 0.03
  ; res@gsnRightStringFontHeightF = 0.03

  res3 = res
  resb = res

  ndim  = dimsizes(xx_me)
  x_axis = ispan(yrstrt, yrlast, 1)
  x_axis_mon = fspan(yrstrt, yrlast+1, nn1)

  ;res@tmXBMode   = "Explicit"
  ;res@tmXBValues = x_axis;-1
  ;res@tmXBLabels = model
  ;res@tmXBLabelAngleF = 45.
  ;res@tmXBLabelFontHeightF = 0.02
  ; res@tiYAxisString = ""
  res@tiXAxisString = "year"

  res@xyMonoLineColor = False
  res@xyMonoDashPattern = True

  res@trXMinF               = yrstrt
  res@trXMaxF               = yrlast;yrstrt+10;

;MODEL
res@xyLineThicknessF = 7.0; 0.3
res@gsnRightString = "" ;xx@units

res2 = res

  res@gsnLeftString = "" ;MODEL+" "+EXP
  res2@gsnLeftString = "" ;""+IND+" "+nmyr+"-year moving STD"
  ; res2@tiYAxisString = "";+IND+" "+nmyr+"-year moving STD"
  res@xyLineColor = "grey45" ;"grey75"


  X2 = xm_std
  X3 = xx1 ;xa1

  X2_mme = dim_avg_n_Wrap(X2,0)

  ; plot1(ia) = gsn_csm_xy (wks,x_axis, X2 ,res2) ;

  res2@trXMinF               = 2040;yrstrt
  res2@trXMaxF               = 2063;yrlast;yrstrt+10;

  ress2 = res2
  ress = res 

  res2@trYMinF               =  -0.5;0.0
  res2@trYMaxF               =  2.1;*VALUE^2 ;3000.;

  res6 = res2 

  res@trYMinF               = 14.9;1.8e+15;16.0;24.; 26.;0.; 19.;  ;;-4.;-40.;6000.;4.0
  res@trYMaxF               = 17.5;3.2e+15;18.5;32.; 32.0;15.;25.; 4. ;; 40.;10000.;4.0


  res@xyLineColor = colors3(ia) ;"grey40"
  res@xyLineThicknessF = 1.0
  res@xyLineOpacityF = 0.5
  ress@xyLineColor = colors3(ia)
  plot3(ia) = gsn_csm_xy (wks,x_axis_mon, X3 ,res) ;
  plota = gsn_csm_xy (wks,x_axis_mon, dim_avg_n_Wrap(X3,0) ,ress)
  overlay(plot3(ia),plota)  

  res6@xyLineThicknessF = 1.0
  res6@xyLineOpacityF = 0.8

  print(MODEL+" STD:"+dim_avg_n_Wrap(X2_mme(2045-yrstrt:2068-yrstrt),0))


  if(ia.eq.0) then 

  res2@xyLineColor = colors3(0)
  res2@xyDashPattern = line_dash(0)
  res2@tiYAxisString = "STD ("+X2@units+")"
  res2@gsnLeftString = LONGNAME+" "+nmyr+"-year moving STD"
  plot1(0) = gsn_csm_xy (wks,x_axis, X2_mme ,res2) ;
  res6@xyLineColor = colors3(ia) ;"grey40"
  plota = gsn_csm_xy (wks,x_axis, X2 ,res6)
  ; overlay(plot1(0),plota)  

  else 

  ress2@xyLineColor = colors3(ia)
  ress2@xyDashPattern = line_dash(ia)

  plota = gsn_csm_xy (wks,x_axis, X2_mme ,ress2)
  overlay(plot1(0),plota)

  res6@xyLineColor = colors3(ia) ;"grey40"
  plota = gsn_csm_xy (wks,x_axis, X2 ,res6)
  ; overlay(plot1(0),plota) 

  end if 

  res3@xyLineThicknessF = 7.0
  res3@tiXAxisString = "Month"
  x_axis2 = ispan(-nyear1*12, nyear2*12-1, 1)
  res3@xyLineColor = "lightseagreen"
  res3@trYMinF               =  -VALUE;4.0
  res3@trYMaxF               =   VALUE;4.0
  
  delete(ress2)
  ress2 = res3

  ; plot2(ia) = gsn_csm_xy (wks,x_axis2, xx_el2 ,res3)
  ; overlay(plot2(ia),plota)
  ; res@xyLineColor = "blue"
  ; res@xyLineThicknessF = 3.0
  ; plota = gsn_csm_xy (wks,x_axis2, dim_avg_n_Wrap(xx_el1,1) ,res)
  ; overlay(plot2(ia),plota)

  ; res@xyLineColor = "black"
  ; res@xyLineThicknessF = 6.0
  ; plota = gsn_csm_xy (wks,x_axis2, dim_avg_n_Wrap(dim_avg_n_Wrap(xx_el1,1),0) ,res)
  ; overlay(plot2(ia),plota)

  ress@xyLineThicknessF = 6.;4.0

  xx_el_mme = dim_avg_n_Wrap(dim_avg_n_Wrap(xx_el1,1),0)

  res3@gsnRightString = xx@units
  res3@gsnYRefLine           = 0.0             ; reference line
  res3@gsnYRefLineColor      = "grey50"
  res3@gsnYRefLineDashPattern = 1

  res3@tmXBMode        = "Explicit"	
  res3@tmXBValues      = (/-30,-20,-10,0,10,20,30/)
  res3@tmXBLabels      = (/"Jun(-3)","Apr(-2)","Feb(-1)","Dec(-1)","Oct(0)","Aug(1)","Jun(2)"/)

  if(ia.eq.0) then 

  res3@xyLineColor = colors3(0)
  res3@xyDashPattern = line_dash(0)

  res3@gsnLeftString = ElorLa+" composite ("+LONGNAME+")"
  plot1(1) = gsn_csm_xy (wks,x_axis2, xx_el_mme ,res3) ;

  res@gsnLeftString = "    "+LONGNAME
  plot4(0) = gsn_csm_xy (wks,x_axis_mon, X3 ,res) ;
  plota = gsn_csm_xy (wks,x_axis_mon, dim_avg_n_Wrap(X3,0) ,ress)
  overlay(plot4(0),plota)  

  res@gsnLeftString = "";+LONGNAME
  res@tiYAxisString = "GMST ("+x_annual@units+")"
  plot5(0) = gsn_csm_xy (wks,x_axis, x_annual ,res) ;
  plota = gsn_csm_xy (wks,x_axis, dim_avg_n_Wrap(x_annual,0) ,ress)
  overlay(plot5(0),plota)  
  
  res@gsnLeftString = ""

  else 
  ress2@xyLineColor = colors3(ia)
  ress2@xyDashPattern = line_dash(ia)

  plota = gsn_csm_xy (wks,x_axis2, xx_el_mme ,ress2)
  overlay(plot1(1),plota)
  plota = gsn_csm_xy (wks,x_axis_mon, X3 ,res) ;
  overlay(plot4(0),plota)  
  plota = gsn_csm_xy (wks,x_axis_mon, dim_avg_n_Wrap(X3,0) ,ress)
  overlay(plot4(0),plota)  

  plota = gsn_csm_xy (wks,x_axis, x_annual ,res) ;
  overlay(plot5(0),plota)  
  plota = gsn_csm_xy (wks,x_axis, dim_avg_n_Wrap(x_annual,0) ,ress)
  overlay(plot5(0),plota)  


  end if 

  ress2@xyLineColor = "red"
  ; ress2@trYMinF               =  -4.0
  ; ress2@trYMaxF               =   4.0

  ; Mark all ENSO cases in the time series for reference
  ; plota = gsn_csm_xy (wks,x_axis_mon, xa_el ,ress2)
  ; overlay(plot3(ia),plota)

  ; if (ia.eq.1) then 
  ;   res@xyLineColor = "red"
  ;   plota = gsn_csm_xy (wks,x_axis2, dif_el ,res)
  ;   overlay(plot2(ia),plota)
  ; end if 

;---------shading of STD---------

  ; delete(res@xyDashPattern)
  delete(res@xyLineColors)
  res@xyLineColor     = -1                           ; We don't want the line, so make it trax_axisparent.
  res@gsnXYFillOpacities = 0.2;3
  res@xyCurveDrawOrder = "PreDraw"
  mmz = (/X2(0,:),X2(0,:)/)

res@gsnLeftString = ""

com_std2 = dim_stddev_n_Wrap(X2,0)

  mmz(0,:) = X2_mme-com_std2
  mmz(1,:) = X2_mme+com_std2

  res@gsnXYFillColors = colors2(ia)
  plota  = gsn_csm_xy (wks,(/x_axis/),mmz(0:1,:),res)  ; Create filled XY plot.
  overlay(plot1(0), plota)

  delete(mmz)
  mmz = (/xx_el2(0,:),xx_el2(0,:)/)
  com_std_el = dim_stddev_n_Wrap(xx_el2,0)

  mmz(0,:) = xx_el_mme-com_std_el
  mmz(1,:) = xx_el_mme+com_std_el

  res@gsnXYFillColors = colors2(ia)
  plota  = gsn_csm_xy (wks,(/x_axis2/),mmz(0:1,:),res)  ; Create filled XY plot.
  overlay(plot1(1), plota)

print(MODEL+" "+EXP+" done!")

delete(mmz)

delete([/ xx,xx_me,xx_sea,xa_sea,x_axis,x_axis_mon,bf_sea,x_annual,X2,X3,\
 xx_bf,bf_me,xm_std,xm_std_me,res,res2,ress2, xx1,xx_el1,xx_el2,\ ;xm_clm,xm_clm_me,
 xa1, ENSN,ndim,xm_el_com,num_case_en,case_ind,xa_el/]) ;xa0_annual,
end do


;---------------------------------
; Set up resources for a customized legend.
;
lgres                    = True
lgres@lgLineThicknessF   = 3.0
lgres@lgItemType         = "Lines"        ; show lines only (default)
lgres@vpHeightF          = 0.13;10           ; height of legend (NDC)
; lgres@lgPerimThicknessF  = 2.0            ; thicken the box perimeter
lgres@lgPerimOn          = False
; lgres@lgPerimFill = 0
; lgres@lgPerimFillColor = 0
lgres@lgPerimFill            = "SolidFill"      ; Fill legend box w/white
lgres@lgPerimFillColor       = "white"          ; so it masks XY curves

lgres@lgMonoDashIndex = False

lgres@vpWidthF           = 0.25           ; width of legend (NDC)
lgres@lgLabelFontHeightF = .06            ; legend label font thickness
lgres@lgLineColors       = colors3;(:3:-1)
lgres@lgDashIndexes = line_dash;(:3:-1)

; labels2 = (/EXPa(0),EXPa(1),EXPa(2),EXPa(3)/) ;MODELa;+" "+EXP
; labels2 = (/"SSP2-4.5(CAM)","MCB-top5%","MCB-tail40%","MCB-tail30%","MCB-tail20%","MCB-tail10%"/) ;MODELa(1) ; MODELa(3)
; labels2 = (/"CAM6 SSP245","MCB","WACCM6 SSP245","SAI"/) ;MODELa(1) ; MODELa(3)
labels2 = (/"SSP2-4.5(CAM)  ","MCB-abrupt","MCB-FB+FF","MCB-FF","SSP2-4.5(WACCM)","SAI"/);,"MCB-tail20%"/) ;MODELa(1) ; MODELa(3)
nitems2 = dimsizes(labels2)
lbid_2 = gsn_create_legend(wks,nitems2,labels2,lgres)

lbid_3 = gsn_create_legend(wks,nitems2,labels2,lgres)
delete([/lgres@lgDashIndexes/])
lgres@lgDashIndexes = (/0,0,0,0,0,0/)
lgres@lgPerimOn          = True
lbid_4 = gsn_create_legend(wks,nitems2,labels2,lgres)
lgres@lgPerimOn          = False
lbid_5 = gsn_create_legend(wks,nitems2,labels2,lgres)

delete([/lgres@lgDashIndexes,lgres@lgLineColors/])

; labels21 = (/"SSP2-4.5(CAM)","MCB-abrupt","MCB-FB+FF","MCB-FF"/);
; labels22 = (/"SSP2-4.5(WACCM)","SAI","MCB-tail20%"/) ;MODELa(1) ; MODELa(3)
; nitems21 = dimsizes(labels21)
; nitems22 = dimsizes(labels22)
; lgres@lgLineColors       = colors3(:3)
; lgres@lgDashIndexes = line_dash(:3)
; lbid_2 = gsn_create_legend(wks,nitems21,labels21,lgres)
; delete([/lgres@lgDashIndexes,lgres@lgLineColors/])
; lgres@lgLineColors       = colors3(4:)
; lgres@lgDashIndexes = line_dash(4:)
; lbid_22 = gsn_create_legend(wks,nitems22,labels22,lgres)

; Use gsn_add_annotation to attach this legend to our existing plot.
; This way, if we resize the plot, the legend will stay with the
; plot and be resized automatically.
;
amres                  = True

amres@amJust           = "BottomLeft"    ; Use bottom right corner of box
amres@amParallelPosF   =  -0.44              ; Move legend to right
amres@amOrthogonalPosF =  0.5; -0.2              ; Move legend down.


annoid2 = gsn_add_annotation(plot1(0),lbid_2,amres)  ; add legend to plot
annoid4 = gsn_add_annotation(plot4(0),lbid_4,amres)  ; add legend to plot

amres@amParallelPosF   =  -0.2              ; Move legend to right
; annoid22 = gsn_add_annotation(plot1(0),lbid_22,amres)  ; add legend to plot

amres@amParallelPosF   =  -0.44              ; Move legend to right
amres@amOrthogonalPosF =  -0.08              ; Move legend up.
annoid5 = gsn_add_annotation(plot5(0),lbid_5,amres)  ; add legend to plot

if(ElorLa.eq."LaNina")then
amres@amParallelPosF   =  -0.15              ; Move legend to right
annoid3 = gsn_add_annotation(plot1(1),lbid_3,amres)  ; add legend to plot
end if 
;**********************************************
; A box plot for ENSO STD
;**********************************************
resb            = True                         ; plot mods desired
resb@vpHeightF = 0.6
resb@vpWidthF  = 0.25;15
resb@tiMainString = ""
resb@xyMarkLineModes     = "Markers"
resb@xyMarker            = 6
resb@xyMarkerSizeF       = 0.03                        ; default 0.01
resb@xyMarkerThicknessF  = 8.0                         ; default 1.00

resb@trYMinF             = 0.3;res2@trYMinF
resb@trYMaxF             = 2.1 ;res2@trYMaxF
resb@trXMinF             = 0.
resb@trXMaxF             = nsa+1

x_box = ispan(1,nsa,1)

resb@tmXBMode = "Explicit"
resb@tmXBLabels = labels2
resb@tmXBValues = x_box
resb@tmXBLabelAngleF      = 65.
resb@tmXBLabelJust = "BottomRight"
resb@tmXBLabelFontHeightF = 0.02
resb@tmYLLabelFontHeightF = 0.02

gsresy = True
gsresy@gsLineThicknessF = 8.0

resb@xyMarkerColor = colors3(0)
plot6(0) = gsn_csm_xy(wks,(/x_box(0),x_box(0)/),(/std_all(0,0),std_all(0,0)/),resb)	
do ia = 0,nsa-1
  resb@xyMarkerColor = colors3(ia)
  plota = gsn_csm_xy(wks,(/x_box(ia),x_box(ia)/),(/std_all(ia,0),std_all(ia,0)/),resb)	
  gsresy@gsLineColor      = colors3(ia)
  add_y_errorbar(wks, plota, (/x_box(ia),x_box(ia)/), (/std_all(ia,0),std_all(ia,0)/),(/ 2*std_all(ia,1), 2*std_all(ia,1)/), gsresy)
  overlay(plot6(0),plota)

end do 


;------------------------------------------------

resk = True
;resk@txFontHeightF = 0.03
resk@gsnPanelLabelBar   = False                 ; add common colorbar
resk@gsnMaximize = True
resk@gsnPaperOrientation = "portrait"   ; force portrait

resk@txString = ""+IND+" & their original ensemble mean"
gsn_panel(wks,plot3,(/3,2/),resk)
gsn_panel(wks,plot4,(/1,1/),resk)
gsn_panel(wks,plot5,(/1,1/),resk)
resk@txString = ""
gsn_panel(wks,plot1(0),(/1,1/),resk)
gsn_panel(wks,plot1(1),(/1,1/),resk)
gsn_panel(wks,plot6,(/1,1/),resk)


end