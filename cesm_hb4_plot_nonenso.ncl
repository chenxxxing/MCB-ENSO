load "./func/get_el_nino_cases.ncl"
begin

dirip = "/glade/u/home/chenxing/geog/"
; C_TIME_MO_S = 24.*3600.*30 ;mon --> s
SEASON = (/"DJF","MAM","JJA","SON" /)

diri = "/glade/home/chenxing/geog/"
diri0 = "/glade/derecho/scratch/chenxing/geog/heatbudget/"
diri3 = "/glade/work/chenxing/geog/cesm/"

MODEL_NAME = (/"CAM","MCB" /) ;(/"CESM2-WACCM","ARISE-SAI-1.5"/);,"GLENS","GLENS","CESM2","CESM2-WACCM"/) ; ;
EXPA = (/"SSP245","SSP245"/);,"feedback","control","piControl","piControl"/) ;"feedback" ; the first 50 ens or the last 50 ens

yrsa = (/2035,2035/) ;(/2040,2040/); (/2035,2035,2020,2020,400,400 /);(/2035,2035,2035,2035 /);(/2015,2035,2020,2010 /);
; yrla = (/2069,2069,2055,2055,499,499 /);(/2069,2069,2069,2069 /)
yrla = (/2038,2038/) ;(/2069,2069/);yrsa + 34

; Look at El Nino years or not
NOTENSOYEAR = True

do im = 0,dimsizes(MODEL_NAME)-1
; im = 0

EXP = EXPA(im)
MODEL = MODEL_NAME(im)
yrs = yrsa(im)
yrl = yrla(im)
; ymstrt = yrs*100+2
; ymlast = (yrl+1)*100+1

;read computed terms from heatbudget2_comput.ncl
TERM_NAME = (/"dTadt","Sum","ucdTadx","vcdTady","uadTcdx",\
          "vadTcdy","uadTadx","vadTady","clm_uadTadx","clm_vadTady",\
          "wadTcdz","wcdTadz","wadTadz","SW","LW",\;"q_pen","q_shf",\;"SW","LW",\;
          "SH","LH","Residuals"/) ;"q_pen","q_shf","SW","LW","SH","LH",
; TERM_NAME = (/"Total tendency","Sum","Advection due to ~C~mean zonal currents","Advection due to ~C~mean meridional currents","Zonal advection",\
;           "Meridional advection","Nonlinear(zonal)","Nonlinear(meridional)","Climatological ~C~zonal nonlinear","Climatological ~C~merdional nonlinear",\
;           "Ekman feedback","Thermocline feedback","Nonlinear(vertical)","SW Flux","LW Flux",\;"q_pen","q_shf",\;"SW","LW",\;
;           "SH Flux","LH Flux","Residuals"/) ;"q_pen","q_shf","SW","LW","SH","LH",
; TERM_NAME = (/"dTadt","Sum","ucdTadx","vcdTady","wcTamld","uadTcdx","vadTcdy","wadTcdz","wcTasub","uadTadx"\
; ,"vadTady","wadTadz","SW","LW","SH","LH","Residuals"/)

VAR_NAME = (/"Tc","Ta","Uc","Ua","Vc","Va","Wc","Wa","dTcdx","dTadx","dTcdy","dTady","dTcdz","dTadz" /)

  locs1 = systemfunc("ls "+diri0+"enso/"+MODEL+"_"+EXP+"*_heatbudget_terms_"+yrs+"-"+yrl+".nc")
  ;CAM_009_heatbudget_atmswterms_2035-2038.nc
  locs3 = systemfunc("ls "+diri0+"enso/"+MODEL+"_*_heatbudget_atmswterms_"+yrs+"-"+yrl+".nc")


f1   = addfiles(locs1, "r")  ;multiple files
ListSetType (f1, "join")        ; concatenate (=default)
print(locs1)
ne = dimsizes(locs1)

f3   = addfiles(locs3, "r")  ;multiple files
ListSetType (f3, "join")        ; concatenate (=default)
print(locs3)

nf = dimsizes(locs1)
ENSN = new(nf,"string")
do ie = 0,nf-1
  ;CESM1-CAM5_105_heatbudget_terms_el_nino3_"+yrs+"-"+yrl+".nc
  locs_str = str_split(locs1(ie), "_");6), "_");12), ".");
  ENSN(ie) = locs_str(1)
  print("ENSN "+ENSN(ie))
end do

hb0 = f1[:]->dia
hf_atm = f3[:]->dia
var = f1[:]->dterms

hb0!0 = "ensemble"
var!0 = "ensemble"
hf_atm!0 = "ensemble"
printVarSummary(hb0)
printVarSummary(hf_atm)

ndim = dimsizes(hb0)

x_axis = ispan(0, ndim(2)-1, 1)

; ;;;;;;;;;;;;;;;;;;;;;;
; ; Normalise all terms using dTadt
; hb0 = hb0 / avg(hb0(terms|0,ensemble|:,time|12,{lat|-2.5:2.5},{lon|210:270}))/2.


; hb = hf_atm(terms|:,ensemble|:,time|:,lat|:,lon|:)
; hb_p2 = hf_atm_p2(terms|:,ensemble|:,time|:,lat|:,lon|:)

hb = array_append_record(hb0(terms|:12,ensemble|:,time|:,lat|:,lon|:), hf_atm(terms|:,ensemble|:,time|:,lat|:,lon|:), 0)
copy_VarMeta(hb0(0,0,0,:,:),hb(0,0,0,:,:))
printVarSummary(hb)

; Sum term is the summary of all these terms
hb(1,:,:,:,:) = dim_sum_n_Wrap(hb(2:dimsizes(TERM_NAME)-2,:,:,:,:),0)
; Residuals term: DT/dt - sum of all terms
hb(dimsizes(TERM_NAME)-1,:,:,:,:) = hb(0,:,:,:,:) - hb(1,:,:,:,:) ; dim_sum_n_Wrap(hb(11:15,:,:,:),0)
printVarSummary(hb) ; terms*ensemble*time*lon

; ;;;;;;;;;;;;
; ; Calculate the ratio contributed by terms
; hb = hb / conform(hb, hb(1,:,:,:,:),(/1,2,3,4/))


; hb = hb * C_TIME_MO_S
; hb_p2 = hb_p2 * C_TIME_MO_S
hb@units = "degC/mon"

;3-mon running mean ;
hb = runave_n_Wrap(hb,3,1,2)

ndimt = dimsizes(TERM_NAME);hb)
nterms = ndimt(0)

nvar = dimsizes(VAR_NAME);hb)
; ;-----------moving average---------------------
; nrun = 3
; endopt    = 1 ;
; dia  = runave_n_Wrap (dia, nrun, endopt, 0)

;;----------- area average ---------------------
; Nino 1+2 (0-10S, 90W-80W), Nino 3 (5N-5S, 150W-90W),
; Nino 3.4/ONI (5N-5S, 170W-120W) and Nino 4 (5N-5S, 160E-150W)
AREA = "Nino4" ;"Nino3m";
NLAT =  5.0;2.5
SLAT = -5.0;2.5
WLON =  160.;210.;190;160;190.;
ELON =  360-150.;270.;250;210;240.;

hb_mme = dim_avg_n_Wrap(hb(terms|:,time|:,ensemble|:,{lat|SLAT:NLAT},lon|:),(/2,3/))
var_mme = dim_avg_n_Wrap(var(terms|:,time|:,ensemble|:,{lat|SLAT:NLAT},lon|:),(/2,3/))

hb_area = dim_avg_n_Wrap(hb(:,:,:,{SLAT:NLAT},{WLON:ELON}),(/3,4/))

;--------------------------------------------

hb_area_mme = dim_avg_n_Wrap(hb_area, 1) ; terms * time

hb_mme_sea = month_to_seasonN(dim_avg_n_Wrap(hb(time|:,terms|:,ensemble|:,lat|:,lon|:),2),SEASON)
var_mme_sea = month_to_seasonN(dim_avg_n_Wrap(var(time|:,terms|:,ensemble|:,lat|:,lon|:),2),SEASON)
hb_std_sea = month_to_seasonN(dim_stddev_n_Wrap(hb(time|:,terms|:,ensemble|:,lat|:,lon|:),2),SEASON)
hb_area_std_sea = dim_avg_n_Wrap(hb_std_sea(:,:,:,{SLAT:NLAT},{WLON:ELON}),(/3,4/))
printVarSummary(hb_mme_sea)

hb_area_mme_sea = new((/4,ndim(2)/12,nterms/),typeof(hb))
do i =0,nterms-1
  hb_area_mme_sea(:,:,i) = month_to_seasonN(hb_area_mme(i,:),SEASON)
end do
hb_area_mme_sea!2 = "terms"

hb_area_sea = month_to_seasonN(hb_area(time|:,ensemble|:,terms|:),SEASON)

; ;----------------Other index----------------------------
; yrs1 = 1950
; yrl1 = 1999
; yrs2 = 2050
; yrl2 = 2099
; ymstrt1 = yrs1*100+1
; ymlast1 = yrl1*100+12
; ymstrt2 = yrs2*100+1
; ymlast2 = yrl2*100+12

; wp_djf = new((/nf,(yrl0-yrs0+1)/),"float")
; do ie = 0,nf-1
; ; BE cautiou of the order of ensemble!!
; ; fils = systemfunc("ls "+diri3+"lens/nino3/"+MODEL+"_r*_nino3_*.nc")

; fils = systemfunc("ls "+diri3+"nino3/"+MODEL+"_"+EXP+"*"+ENSN(ie)+"_nino3_*.nc")
; ; print(fils)
; f   = addfile(fils, "r")
; TIME2=f->time
; yyyymm2=cd_calendar(TIME2, -1)
; wp  = f->index;(ymstrts1:ymlast1) 

;   wp_djf(ie,:) = month_to_seasonN(wp,"DJF")
; end do
; printVarSummary(wp_djf)

; ymstrts1 = ind(yyyymm2.eq.ymstrt1)
; ymlasts1 = ind(yyyymm2.eq.ymlast1)
; ymstrts2 = ind(yyyymm2.eq.ymstrt2)
; ymlasts2 = ind(yyyymm2.eq.ymlast2)

; ; year index
; iyr_hs = (ymstrts1)/12
; iyr_hl = (ymlasts1 + 1 )/12 -1
; iyr_fs = (ymstrts2)/12
; iyr_fl = (ymlasts2 + 1 )/12 -1
; print(ymstrts1+"-"+ymlasts1+" "+ymstrts2+"-"+ymlasts2)
; print(iyr_hs+"-"+iyr_hl+" "+iyr_fs+"-"+iyr_fl)

; wa_mean_hist = dim_stddev_n_Wrap(wp_djf(:,iyr_hs:iyr_hl),1)
; wa_mean_future = dim_stddev_n_Wrap(wp_djf(:,iyr_fs:iyr_fl),1)

; dif_wa = wa_mean_future - wa_mean_hist
; dif_wa@units = wa_mean_future@units

; end do

; printVarSummary(hb_area_p2_mme_sea)
; printVarSummary(dif_wa)
; printVarSummary(dif_hb_area_sea)

;---------------------------------------------
;Read seeding mask
fs   = addfile(dirip+"mask_0375_050_SSP245.nc", "r")  
seedmask  = fs->mask
lat = fs->lat 
lon = fs->lon
lon@units = "degrees_east"
lat@units = "degrees_north"
seedmask&lat = lat 
seedmask&lon = lon 

printVarSummary(seedmask)
;================================================================================
;  PLOT
;================================================================================


isea = 2
iyr = 0

wks = gsn_open_wks("pdf","hb_el_"+MODEL+"_"+EXP)
wks2 = gsn_open_wks("png","hb_el_"+MODEL+"_"+EXP+"_contour")
  plot  = new(nterms, graphic)
  plot2 = new(nterms, graphic)
  plot3 = new(nterms, graphic)
  plot4 = new(nterms, graphic)
  plot5 = new(nterms, graphic)
  plot6 = new(nterms, graphic)
  plotc = new(nterms, graphic)
  plotd = new(nterms, graphic)
  plot1 = new(nterms, graphic)
  plot7 = new(nterms, graphic)
  plot8 = new(nterms, graphic)
  plot9 = new(nterms, graphic)
  plot10 = new(nterms, graphic)
  plotv = new(nvar, graphic)
  
  gsn_define_colormap(wks2,"BlueDarkRed18")

  res                       = True                 ; plot mods desired
  res@gsnFrame = False
  res@gsnDraw  = False
  res2=res
  res@vpHeightF             = 0.3                 ; Changes the aspect ratio
  res@vpWidthF              = 0.7
  res@xyLineOpacityF =  1.0;0.5
    ; res@tmYROn                 = False    ; right off
  res@tmXTOn              = False   ; Turn off top tickmarks
  res@tmYLMinorOn         = False   ; Turn off left minor tickmarks
  res@gsnYRefLine           = 0.              ; reference line
  res@tmXBOn                = True            ; turn off tickmarks at bot
  res@tmXBLabelsOn          = True
  res@tmXBMode              = "Explicit"
  ; res@tmXBMode   = "Explicit"
  ; res@tmXBValues = (/-12,0,11,23/)
  ; res@tmXBLabels = "year("+(/"-1","0","+1","+2"/)+")"
  res@pmLegendWidthF         = 0.5
  res@pmLegendHeightF        = 0.5
  ; res@trXMinF            = -1*12 ;
  ; res@trXMaxF            = 1*12-1;
  ; res@trYMinF            = -0.6
  ; res@trYMaxF            =  0.6
  res@tiYAxisString = ""
  res@tiXAxisString = "MO"

  res@xyLineThicknessF = 3.

  res1 = res

  cmap = read_colormap_file("prcp_1") ;radar_1

colors = (/4,19,15,11,21,2,2/)   ; indices into color table
colora = cmap(0:15,:)
colora(0,:) = (/0,0,0,1/)
; colora(6,:) = (/1,0,0,1/)


  res@xyLineColors = colora;(/"black","grey40","gold","cyan","blue","red" /); colora
  res@xyMonoDashPattern = False
  res@xyDashPatterns = (/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,2,3,4,5,6,7,8/)
  res@pmLegendDisplayMode    = "Never" ;"Never" ;"Conditional" ;"Always"
  res@xyExplicitLegendLabels = TERM_NAME
  ; res@pmLegendOrthogonalPosF = 0.5
  ; res@pmLegendParallelPosF   = 1.0


; res@gsnLeftString          = ""
; plot(0) = gsn_csm_xy(wks,x_axis,hb_area_mme(:,:),res) ;hb_area_mme


; TERM_NAME = (/"dTadt","Sum","ucdTadx","vcdTady","uadTcdx","vadTcdy","uadTadx","vadTady","clm_uadTadx",\;"ucdTcdx","vcdTcdy",
; "clm_vadTady","wadTcdz","wcdTadz","wadTadz","q_pen","q_shf","SW","LW","SH","LH","Residuals"/) ;"q_pen","q_shf",

  res1@trYMinF            = -0.6
  res1@trYMaxF            =  0.6
  
res11 = res1
res1@xyLineThicknessF = 5.
res11@xyLineThicknessF = 1.
res1@xyLineColors = (/"red","blue","green","magenta"/)
; res11@xyLineColors = (/"palevioletred1","lightblue","darkseagreen1","plum1"/)
res11@xyLineOpacityF = 0.8

res1@pmLegendDisplayMode    = "Always"            ; turn on legend
; res1@pmLegendSide           = "Top"               ; Change location of 
; res1@pmLegendParallelPosF   = .1                  ; move units right
; res1@pmLegendOrthogonalPosF = -0.3                ; move units down
res1@pmLegendWidthF         = 0.05                ; Change width and
res1@pmLegendHeightF        = 0.12                ; height of legend.
res1@lgPerimOn              = False               ; turn off box around
res1@lgLabelFontHeightF     = .025                 ; label font height
res1@lgLineColors = res1@xyLineColors

color_en = (/"palevioletred1","lightblue","darkseagreen1","plum1"/)

zoterm = (/2,4,6,8/) ;zonal advection terms
meterm = (/3,5,7,9/) ;zonal advection terms
veterm = (/10,11,12/) ;vertical advection terms
fxterm = (/13,14,15,16/);(/13,14/) ;Flux terms

res1@xyExplicitLegendLabels = TERM_NAME(zoterm)

res1@gsnLeftString = "Zonal Advection"
aa = hb_area(terms|zoterm,ensemble|:,time|:)
plot1(0) = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(aa,1),res1)
do ik = 0,dimsizes(zoterm)-1
  res11@xyLineColor = color_en(ik)
  plota = gsn_csm_xy(wks,x_axis,aa(ik,:,:),res11)
  overlay(plot1(0),plota)
end do 

delete(res1@xyExplicitLegendLabels)
res1@xyExplicitLegendLabels = TERM_NAME(meterm)

res1@gsnLeftString = "Meridional Advection"
aa = hb_area(terms|meterm,ensemble|:,time|:)
plot1(1) = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(aa,1),res1)
do ik = 0,dimsizes(meterm)-1
  res11@xyLineColor = color_en(ik)
  plota = gsn_csm_xy(wks,x_axis,aa(ik,:,:),res11)
  overlay(plot1(1),plota)
end do 

delete(res1@xyExplicitLegendLabels)
res1@xyExplicitLegendLabels = TERM_NAME(veterm)

res1@gsnLeftString = "Vertical Advection"
bb = hb_area(terms|veterm,ensemble|:,time|:)
plot1(2) = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(bb,1) ,res1)
do ik = 0,dimsizes(veterm)-1
  res11@xyLineColor = color_en(ik)
  plota = gsn_csm_xy(wks,x_axis,bb(ik,:,:),res11)
  overlay(plot1(2),plota)
end do 

delete(res1@xyExplicitLegendLabels)
res1@xyExplicitLegendLabels = TERM_NAME(fxterm)

res1@gsnLeftString = "Flux"
cc = hb_area(terms|fxterm,ensemble|:,time|:)
plot1(3) = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(cc,1),res1)
do ik = 0,dimsizes(fxterm)-1
  res11@xyLineColor = color_en(ik)
  plota = gsn_csm_xy(wks,x_axis,cc(ik,:,:),res11)
  overlay(plot1(3),plota)
end do 

res11@xyLineColor = "black"
res11@xyLineThicknessF = 5.
res11@xyDashPatterns = 1

plota = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(hb_area(terms|0,ensemble|:,time|:),0),res11)
overlay(plot1(0),plota)
plota = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(hb_area(terms|0,ensemble|:,time|:),0),res11)
overlay(plot1(1),plota)
plota = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(hb_area(terms|0,ensemble|:,time|:),0),res11)
overlay(plot1(2),plota)
plota = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(hb_area(terms|0,ensemble|:,time|:),0),res11)
overlay(plot1(3),plota)

delete(res1)
delete(res11)

;------2d spatial pattern-----------
; res@tiXAxisString = "Longitude"
; res@trXMinF            = 120 ;
; res@trYMinF            = -0.4
; res@trYMaxF            =  0.4
; res2@vpHeightF             = 0.8
; res2@vpWidthF              = 0.8
res2@mpMaxLatF                   =  10.
res2@mpMinLatF                   = -10.
res2@mpMaxLonF                   = 280.;300
res2@mpMinLonF                   = 130.;90.
res2@mpCenterLonF = 180.
res2@gsnAddCyclic = False

res2@cnFillOn = True;False ;
res2@cnLinesOn = False;True ;
res2@cnLineLabelsOn = False
res2@lbLabelBarOn = True;
res2@lbOrientation = "Vertical"
res2@lbBoxLinesOn  = False
; res2@lbTitleOn        =  True                ; turn on title
; res2@lbLabelStride    = 2
; res2@lbTitleString    = ""                ; title string
; res2@lbTitlePosition  = "Right"              ; title position
; res2@lbTitleFontHeightF= .015                ; make title smaller
res2@pmLabelBarWidthF = 0.05
res2@lbLabelFontHeightF = 0.01

res2@gsnLeftStringFontHeightF = 0.03
res2@gsnRightStringFontHeightF = 0.03
res2@tmXBLabelFontHeightF = 0.02
res2@tmYLLabelFontHeightF = res2@tmXBLabelFontHeightF

printVarSummary(hb_mme_sea)

VAR = (/"Tc","Ta","Uc","Ua","Vc","Va","Wc","Wa","dTcdx","dTadx","dTcdy","dTady","dTcdz","dTadz" /)
       ; 0     1   2    3    4    5    6    7     8       9       10      11      12      13
SCALE_VAR = (/5.,0.4,0.2,0.1,0.2,0.01,1e-05,2e-06,8e-07,3e-07,3e-06,2e-06,0.03,0.01 /)
res2@cnLevelSelectionMode  = "ManualLevels"

do it = 0,dimsizes(VAR)-1
    res2@cnMinLevelValF        = -SCALE_VAR(it)
    res2@cnMaxLevelValF        =  SCALE_VAR(it)
    res2@cnLevelSpacingF       =  res2@cnMaxLevelValF/10.
    res2@gsnLeftString          = VAR(it)
    res2@gsnRightString          = MODEL
    ; plotd(it) = gsn_csm_contour_map_ce(wks2,dif_var_mme_sea(isea,iyr,it,:,:),res2)
end do

res2@lbLabelBarOn = False;
res2@cnLevelSelectionMode  = "ManualLevels"
res2@cnMinLevelValF        = -0.6;0.2
res2@cnMaxLevelValF        =  0.6;0.2
res2@cnLevelSpacingF       =  res2@cnMaxLevelValF/10.
do it = 0,nterms-1
    res2@gsnLeftString          = TERM_NAME(it)
    ; plotc(it) = gsn_csm_contour_map_ce(wks2,dif_hb_mme_sea(isea,iyr,it,:,:),res2)
end do

resk = True
resk@gsnMaximize = True
resk@gsnPaperOrientation = "portrait"   ; force portrait
resk@txString = "future - historical in "+SEASON(isea)+iyr
; gsn_panel(wks2, plotd, (/7,2/), resk)
; gsn_panel(wks2, plotd((/1,11,4/)), (/3,1/), resk)
; gsn_panel(wks2, plotd((/0,8,3/)), (/3,1/), resk)
; gsn_panel(wks2, plotd((/0,12,7/)), (/3,1/), resk)
; gsn_panel(wks2, plotd((/1,13,6/)), (/3,1/), resk)
; resk@gsnPanelLabelBar = True
; ; gsn_panel(wks2, plotc, (/9,2/), resk)
; gsn_panel(wks2, plotc((/0,3,4,10,11,13,16/)), (/7,1/), resk)

;-----------------------------------------------
; Set up resources for a customized legend.
;
  lgres                    = True
  lgres@lgLineColors       = res@xyLineColors
  lgres@lgBoxLineDashPattern = res@xyDashPatterns
  lgres@lgLineThicknessF  = 2.
  lgres@lgItemType         = "Lines"        ; show lines only (default)
  lgres@lgLabelFontHeightF = .03            ; legend label font thickness
  lgres@vpWidthF           = 0.4           ; width of legend (NDC)
  ; lgres@vpHeightF          = 0.13           ; height of legend (NDC)
  lgres@lgPerimThicknessF  = 0.0            ; thicken the box perimeter
  lgres@lgMonoDashIndex    = False
  lgres@lgDashIndex        = res@xyDashPatterns

  labels = TERM_NAME

  nitems = dimsizes(labels)                 ; number of legend items

; Create legend
  lbid = gsn_create_legend(wks,nitems,labels,lgres)
  ;
; Use gsn_add_annotation to attach this legend to our existing plot.
; This way, if we resize the plot, the legend will stay with the
; plot and be resized automatically.
;
  amres                  = True

; Point (0,0) is the dead center of the plot. Point (0,.5) is center,
; flush bottom. Point (0.5,0.5) is flush bottom, flush right.
;
  amres@amJust           = "BottomLeft"    ; Use bottom right corner of box
                                            ; for determining its location.
  amres@amParallelPosF   = 0.7              ; Move legend to right
  amres@amOrthogonalPosF = 1.0              ; Move legend down.

  ; annoid1 = gsn_add_annotation(plot(0),lbid,amres)  ; add legend to plot

delete(res)


;-----------------------------------------
; Lon-time Hov plot

  res = True
  res@gsnDraw = False        ;dont draw
  res@gsnFrame = False        ;dont advance frame
  sdres = True
  opt = True
  sdres@gsnDraw = False        ;dont draw
  sdres@gsnFrame = False        ;dont advance frame
  opt@gsnDraw = False        ;dont draw
  opt@gsnFrame = False        ;dont advance frame

  res@vpHeightF = 0.9
  res@vpWidthF  = 0.5
  gsn_define_colormap(wks,"BlueDarkRed18")
  WLON2  = 130.;90.
  ELON2  = 280.;300
  
  res@cnFillOn = True
  res@cnLinesOn = False
  res@cnLineLabelsOn = False
  res@cnInfoLabelOn = False

  res@lbLabelBarOn = False
  res@cnLevelSelectionMode = "ManualLevels"     ; manual contour levels

  res@tmXBLabelFontHeightF = 0.045         ; change maj lat tm spacing
  res@tmYLLabelFontHeightF = 0.06;res@tmXBLabelFontHeightF

  res@gsnLeftStringFontHeightF  = 0.06
  res@gsnRightStringFontHeightF = 0.06

  sdres@cnFillOn = False
  sdres@cnLinesOn = False;True ; 
  sdres@cnLineLabelsOn        = False; True   
  ;sdres@cnSmoothingOn = True    ;what's that smooth for?! what's wrong with it?!
  ;sdres@cnSmoothingTensionF = 1
  sdres@cnInfoLabelOn = False
  sdres@gsnLeftString = ""
  sdres@cnFillColor = "purple";"lightpink" ;"green"
  sdres@cnLineColor = "purple" ;"green"
  sdres@cnLineThicknessF = 2.0
  ; sdres@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ; sdres@cnLevels =(/-30./)
  sdres@cnFillDotSizeF       = 0.005;0.0025            ; increase dot size of contours
  sdres@cnFillOpacityF = 1.0;0.7

  opt@gsnShadeFillType = "pattern"      ; pattern fill
  ; opt@gsnShadeFillScales = 0.8 ;triggers fatal:Subscript out of range, error in subscript #0
  opt@gsnShadeHigh = 17 ;-1          ;
  ; opt@gsnShadeLow =  17 ;6       ;
  opt@cnLineLabelsOn        = False   
  opt@gsnLeftString  = ""
  opt@cnInfoLabelOn  = False
  opt@cnFillDrawOrder = "PostDraw"

  res@gsnRightString = ""
  hb_mme&time = x_axis+1
  res@tiYAxisString = "" ;"Month since MCB starts"
  res@tiYAxisFontHeightF = res@tmXBLabelFontHeightF

  if(im.eq.0) then 
  hb_dif = hb_mme
else if(im.eq.1) then 
  hb_dif = hb_mme - hb_dif
end if 
end if 

  do i =0,nterms-1
    res@gsnLeftString = TERM_NAME(i)
    ; res@gsnRightString = ""+yrs+"-"+yrl+""
    res@cnMinLevelValF       = -0.5	        ; min level
    res@cnMaxLevelValF       =  0.5               ; max level
    res@cnLevelSpacingF      =  res@cnMaxLevelValF/10.                ; contour level spacing
      plot3(i) = gsn_csm_hov(wks, hb_mme(i,:,{WLON2:ELON2}), res)
    
    if(i.eq.13.and.im.eq.1) then 
      sdmask_lon = dim_avg_n_Wrap(seedmask(:,{-5:5},:),1)
      ndimt1 = dimsizes(hb_mme)
      ndimt2 = dimsizes(sdmask_lon)
      sdmask_tl = new((/ndimt1(1),ndimt2(1)/),typeof(seedmask))
      do iy = 0,ndimt1(1)/12-1
        sdmask_tl(iy*12:iy*12+11,:) = sdmask_lon
      end do 
        rsmask = gsn_csm_contour(wks, sdmask_tl(:,{WLON2:ELON2}), sdres)
        rsmask = gsn_contour_shade(rsmask,-999,0.5, opt)   ; Shade contours above .5
        overlay(plot3(i), rsmask)

    end if 

  if(im.eq.1) then 
  res@cnMinLevelValF       = -0.1	        ; min level
  res@cnMaxLevelValF       =  0.1               ; max level
  res@cnLevelSpacingF      =  res@cnMaxLevelValF/10.                ; contour level spacing
    plot10(i) = gsn_csm_hov(wks, hb_dif(i,:,{WLON2:ELON2}), res)
  end if 
  

  end do


  res@lbLabelBarOn = True

  do it =0,nvar-1
  res@gsnLeftString = VAR(it)
  res@cnMinLevelValF       = -SCALE_VAR(it)*2
  res@cnMaxLevelValF       =  SCALE_VAR(it)*2
  res@cnLevelSpacingF      =  res@cnMaxLevelValF/10.                ; contour level spacing
    plotv(it) = gsn_csm_hov(wks, var_mme(it,:,{WLON2:ELON2}), res)

end do


  print("Lat-time done")


delete(res)

;=========SCATTER=========================

  res = True
  res@gsnFrame = False
  res@gsnDraw  = False
  resl = res

  res@xyMarkLineMode     = "Markers"  ; choose which have markers
  ; res@xyDashPatterns      = 1                      ; solid line
    res@xyMarker         =  1                      ; choose type of marker
    res@xyMarkerSizeF     = 0.02                     ; Marker size (default 0.01)
  ;   res@xyLineThicknesses   = (/1,2/)                ; set second line to 2

  res@xyMarkerOpacityF = 1.0
    res@tmYROn                 = False    ; right off
  ;res@vpWidthF    = 0.5        ; Make plots wider
  ;res@vpHeightF   = 0.5
  res@tmXTOn              = False   ; Turn off top tickmarks
  res@tmYLMinorOn         = False   ; Turn off left minor tickmarks
  res@tmXMajorGrid                = True
  res@tmYMajorGrid                = True
  res@tmXMajorGridThicknessF      = 1.0
  res@tmYMajorGridThicknessF      = 1.0
  res@tmXMajorGridLineDashPattern = 2
  res@tmYMajorGridLineDashPattern = 2

  res@gsnRightString = ""
  res@gsnLeftString = ""
  res@gsnLeftStringFontHeightF  = 0.06
  res@gsnRightStringFontHeightF = 0.06

  res@xyMonoMarkerColor  = False ;True ;          ; Allow different colors for markers
   ; res@xyMonoDashPattern        = True              ; all solid

  ;colors = read_colormap_file("default") ;("BkBlAqGrYeOrReViWh200");("default");("cosam");"GMT_paired"
    res@xyMarkLineMode     = "Markers"  ; choose which have markers
    ; res@xyMarker         =  9

    ; res@xyMarkerColors             = colors;ispan(1, nm+7, 1)

    res@gsnYRefLine = 0.;avg(index_pro)
    res@gsnYRefLineThicknessF = 2.
    res@gsnYRefLineDashPattern = 1
    res@gsnXRefLine = 0;avg(index_vwso)
    res@gsnXRefLineThicknessF = 2.
    res@gsnXRefLineDashPattern = 1
    res@tiMainString             = ""

    ; res@trYMinF = -0.25
    ; res@trYMaxF = 0.5
    ; res@trXMinF = -0.4
    ; res@trXMaxF = 0.8

; rr = hb_area_mme_sea(0,0,:)
;     ; delete([/trXMaxF,trXMinF,trYMinF,trYMaxF/])
; do ia = 0,nterms-1
;   res@tiXAxisString = "change of STD of Nino3 DJF "+X0@units ;zonal SST gradient ;STD of Nino3
;   res@tiYAxisString = "change of "+TERM_NAME(ia)+" "+SEASON(isea)+iyr+" C/month"

;   res@xyMarkerSizeF = 0.03

;   ; res@gsnLeftString = "CMIP"+icmip(ic)
;   ; res@gsnLeftString = "R="+sprintf("%3.2f", cor1)

;     res@xyMarkerColor = "blue"
;     res@gsnLeftString = TERM_NAME(ia)
;     plot5(ia) = gsn_csm_xy(wks, X0 , Y0(:,ia), res)

;     resl@gsnLeftString = ""
;     resl@gsnRightString = ""
;     resl@xyMarkLineMode = "Lines"
;     resl@xyLineColor = "grey55"
;     rco = regline (X0 , Y0(:,ia))
;     yregro = rco*X0 + rco@yintercept
;     plotaa = gsn_csm_xy(wks, X0 , yregro,resl)
;     overlay(plot5(ia), plotaa)
;     rr(ia) = rco

; end do

; res@gsnLeftStringFontHeightF  = 0.03

; res@xyMarkerColor = "green"

; res@gsnLeftString = "Anomalous advection (Tc)"
; TC_terms = (/4,5,10/) ;zonal advection terms
; tc = dim_sum_n_Wrap(Y0(terms|TC_terms,ensemble|:),0)

; res@tiYAxisString = "change of Tc terms "+SEASON(isea)+iyr+" C/month"

; plot7(0) = gsn_csm_xy(wks, X0 , tc, res)

; res@gsnLeftString = "Mean state advection with temperature anomaly (Ta)"
; TA_terms = (/2,3,11/) ;zonal advection terms
; ta = dim_sum_n_Wrap(Y0(terms|TA_terms,ensemble|:),0)

; res@tiYAxisString = "change of Ta terms "+SEASON(isea)+iyr+" C/month"

; plot7(1) = gsn_csm_xy(wks, X0 , ta, res)

; res@gsnLeftString = "Zonal Advection" ;zoterm = (/2,4,6,8/)
; res@tiYAxisString = "change of ZA terms "+SEASON(isea)+iyr+" C/month"
; za = dim_sum_n_Wrap(Y0(terms|zoterm,ensemble|:),0)
; plot7(2) = gsn_csm_xy(wks, X0 , za, res)


; res@gsnLeftString = "Meridional Advection" ;meterm = (/3,5,7,9/)
; res@tiYAxisString = "change of MA terms "+SEASON(isea)+iyr+" C/month"
; ma = dim_sum_n_Wrap(Y0(terms|meterm,ensemble|:),0)
; plot7(3) = gsn_csm_xy(wks, X0 , ma, res)


; res@gsnLeftString = "Vertical Advection";veterm = (/10,11,12/)
; res@tiYAxisString = "change of VA terms "+SEASON(isea)+iyr+" C/month"
; va = dim_sum_n_Wrap(Y0(terms|veterm,ensemble|:),0)
; plot7(4) = gsn_csm_xy(wks, X0 , va, res)



; resl@gsnLeftString = ""
; resl@gsnRightString = ""
; resl@xyMarkLineMode = "Lines"
; resl@xyLineColor = "grey55"
; rco1 = regline (X0 , tc)
; rco2 = regline (X0 , ta)
; rco3 = regline (X0 , za)
; rco4 = regline (X0 , ma)
; rco5 = regline (X0 , va)

; yregro1 = rco1*X0 + rco1@yintercept
; yregro2 = rco2*X0 + rco2@yintercept
; yregro3 = rco3*X0 + rco3@yintercept
; yregro4 = rco4*X0 + rco4@yintercept
; yregro5 = rco5*X0 + rco5@yintercept
; plotaa = gsn_csm_xy(wks, X0 , yregro1,resl)
; overlay(plot7(0), plotaa)
; plotaa = gsn_csm_xy(wks, X0 , yregro2,resl)
; overlay(plot7(1), plotaa)
; plotaa = gsn_csm_xy(wks, X0 , yregro3,resl)
; overlay(plot7(2), plotaa)
; plotaa = gsn_csm_xy(wks, X0 , yregro4,resl)
; overlay(plot7(3), plotaa)
; plotaa = gsn_csm_xy(wks, X0 , yregro5,resl)
; overlay(plot7(4), plotaa)


delete(res)

;=========Bar=========================

res = True
res@gsnDraw = False        ;dont draw
res@gsnFrame = False        ;dont advance frame
res@gsnLeftString = ""
res@gsnRightString = ""
res@vpHeightF = 0.3
res@vpWidthF  = 0.8

res@tmXTOn    = False
res@tmYROn    = False
res@gsnXYBarChart            = True              ; Create bar plot
;res@gsnXYBarChartOutlineOnly = True
res@pmLabelBarWidthF = 0.5

res@gsnYRefLine           = 0.0             ; reference line
res@gsnAboveYRefLineColor = "red"           ; above ref line fill red
res@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
; res@gsnLeftStringFontHeightF  = 0.03
; res@gsnRightStringFontHeightF = 0.03

x_axis2 = ispan(0, nterms-1, 1)
res@tmXBMode   = "Explicit"
res@tmXBValues = x_axis2;-1
res@tmXBLabels = TERM_NAME
res@tmXBLabelAngleF = 90.;45.
;res@tmXBLabelFontHeightF = 0.02
res@tiYAxisString = ""+hb@units
res@tiXAxisString = ""

res@xyMonoLineColor = False
res@xyMonoDashPattern = True


res@xyLineThicknessF = 3.0
; res@gsnRightStringOrthogonalPosF = -0.2
; res@gsnRightStringParallelPosF = 0.1

if(im.eq.0) then 
hb_area_dif = hb_area_mme_sea
else if(im.eq.1) then 
hb_area_dif = hb_area_mme_sea - hb_area_dif
end if 
end if 

do isea = 0,3
do iyr = 0,ndim(2)/12-1
res@gsnLeftString = SEASON(isea)+"("+((-1)+floor(iyr))+")"
; res@xyLineColor = "black"
res@trYMinF               = -0.6
res@trYMaxF               =  0.6
plot2(isea+iyr*4) = gsn_csm_xy(wks,x_axis2, hb_area_mme_sea(isea,iyr,:) ,res) ;

if(im.eq.1) then 
  res@trYMinF               = -0.1
  res@trYMaxF               =  0.1
  plot9(isea+iyr*4) = gsn_csm_xy(wks,x_axis2, hb_area_dif(isea,iyr,:) ,res) ;
end if 


end do 
end do 

; res@trYMinF               = -0.3
; res@trYMaxF               =  0.3
res@gsnLeftString = "contribution to the change"
; plot2(2) = gsn_csm_xy(wks,x_axis2, rr ,res) ;

print("Bar done")

;************************************************
; add error bars
;************************************************
polyres                   = True                       ; marker resources
polyres@gsMarkerIndex     = 1                          ; index for circle
polyres@gsMarkerSizeF     = .02                        ; size
polyres@gsLineThicknessF = 2.0

; gsn_add* templates are functions that we set to dummy values. Since
; we are going to draw numerous error bars, we create two arrays to
; hold the dummy values.


; loop through the points
do isea = 0,3
do iyr = 0,1

do t=0,nterms-1
str = unique_string("errorbar") 
  plot2@$str$ = gsn_add_polyline(wks,plot2(isea+iyr*4),(/t,t/),(/hb_area_mme_sea(isea,iyr,t)\
  +hb_area_std_sea(isea,iyr,t),hb_area_mme_sea(isea,iyr,t)-hb_area_std_sea(isea,iyr,t)/),\
  polyres)

end do
end do
end do

delete(res)
;-----------------------------------------
resk = True
resk@gsnMaximize = True
resk@gsnPaperOrientation = "portrait"   ; force portrait
resk@lbBoxEndCapStyle = "TriangleBothEnds"
resk@lbBoxLinesOn = False
resk@lbTitlePosition  = "Right"              ; title position
resk@lbTitleString = hb_area_dif@units
resk@lbTitleFontHeightF= .02                ; make title smaller
resk@lbTitleDirection = "Across"
resk@lbTitleExtentF   = 0.01 ;Default: 0.15
;resk@lbBoxMinorExtentF = 0.2
resk@lbLabelFontHeightF = 0.02  ;Default: 0.02

resk@txString = MODEL+" "+EXP+" during "+yrs+"-"+yrl+""
gsn_panel(wks, plot1, (/2,2/), resk)
gsn_panel(wks, plot2, (/4,2/), resk)
resk@gsnPanelLabelBar = True
gsn_panel(wks, plot3, (/4,5/), resk)
gsn_panel(wks, (/plot3(0),plot3(4),plot3(11),plot3(13)/), (/1,4/), resk)
gsn_panel(wks, plotv, (/4,4/), resk)

delete([/locs1,f1,locs3,f3,ENSN,hb0,hf_atm,var,hb,hb_area,hb_area_mme,\
hb_mme_sea,var_mme_sea,hb_std_sea,hb_area_std_sea,hb_area_mme_sea,hb_area_sea,\
aa,bb,cc/])

end do 

resk@txString = MODEL_NAME(1)+" minus "+MODEL_NAME(0)+" during "+yrs+"-"+yrl+""
gsn_panel(wks, plot9, (/4,2/), resk)
resk@gsnPanelLabelBar = True
gsn_panel(wks, plot10, (/4,5/), resk)


end
