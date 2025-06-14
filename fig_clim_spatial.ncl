; from plot_com.ncl
begin
diri = "/glade/work/chenxing/geog/"
dirip = "/glade/u/home/chenxing/geog/"

diri2 = "/gpfs/fs1/collections/cdg/data/CLIVAR_LE/"
;from lens_index.ncl
diri3 = "/glade/work/chenxing/geog/"
; diri4 =  "/glade/p/cesm/community/CESM-LE/data/CESM-CAM5-BGC-LE/ocn/proc/tseries/monthly/"
diri4 =  "/glade/p/cesm/community/CESM-LE/data/CESM-CAM5-BGC-LE/atm/proc/tseries/monthly/"
diri6 = "/glade/campaign/cgd/cesm/CESM2-LE/atm/proc/tseries/month_1/"

diri_arise = "/glade/campaign/cesm/collections/ARISE-SAI-1.5/b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT"
diri_waccm = "/glade/campaign/cesm/collections/CESM2-WACCM-SSP245/b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM"
diri_glen = "/glade/campaign/cesm/collections/GLENS/"

SEASON = (/"DJF","MAM","JJA","SON" /)


yrsa = 2035;(/2035,2047,2059/);(/2035,2035,2035,2035 /);(/2015,2035,2010,2020 /);
yrla = yrsa+34;(/2045,2057,2068/);2069;(/2069,2069,2069,2069 /);(/2069,2069,2097,2099 /);
; yrsg = 2020;(/2032,2044,2020/)
; yrlg = yrsg+33;(/2042,2054,2054/)

; FSNS: 100; CLD: 0.3; TS: 5; PR: 8; OMEGA500:0.1; photoC_TOT_zint_100m:0.1?
VARa = (/"TS","PRECC"/) ;(/"TREFHT" ,"PRECT"/);"FSNS"; "SST";(/"FSNS","PRECC"/);"photoC_TOT_zint_100m" ;(/"CLDTOT","FSNS","TS","PRECC"/);(/"Z3200-200","Z3500-500","Z3850-850"/) ;"PSL","FLNT","FSNS","CLDMED","CLDLOW","CLDHGH","OMEGA500-500"/);"AREL1000-200","CLDTOT","FSNT","FLNT","FSNS","FSNSC"/);,,"ACTREL"(/"FSNS","FSNSC"/);"cloudrs" ; "TS","PSL",,"U850","U200","V850","V200"/) ;,"pr" "ts"
COVER_LAND = False ;True
COUNTERMX = (/5.,8./) ;100.; (/50.,8./) ;(/0.3,50.,5.,8./) ;0.5,5.0,0.2,40,40,40,40/);40,40,40,  ;1.0,
MODEL1 = "MCB"; "ARISE-SAI-1.5" ;"MCB-feed";"MCB-feed";
EXP1 = "SSP245"; "MCB-feedforward-1DOF";  "MCB-feedback-1DOF";
MODEL2 = "CAM";"CESM2-WACCM" ;
EXP2 = "SSP245"
MODEL_pi = "CESM2-WACCM" ;"CESM2" ;"CESM2";"CESM2-WACCM" ; picontrol 

VARu = "FSNS" ;"U850-850"
VARv = "FSNS" ;"FSNSC" ;"V850-850"

isea =  0;2;

iyr = 0
; do iyr = 0,dimsizes(yrsa)-1
yrs = yrsa(iyr)
yrl = yrla(iyr)

wks    = gsn_open_wks("pdf",dirip+"cesm_clim")
plot = new(30, graphic)
plot1 = new(30, graphic)
plot2 = new(30, graphic)
plot3 = new(30, graphic)
plot4 = new(30, graphic)
plot5 = new(30, graphic)
plot6 = new(30, graphic)
plot7 = new(30, graphic)


do iv = 0,dimsizes(VARa)-1
VAR = VARa(iv)

;---------read output---------------
; from clim_output.ncl
; CESM2-WACCM_SSP245_clim_PRECC_2035-2069.nc
; CESM2-WACCM_piControl_clim_PRECC_1-499.nc
f   = addfile(diri3+"cesm/clim/"+MODEL1+"_"+EXP1+"_clim_"+VAR+"_"+yrs+"-"+yrl+".nc", "r")  
clm_ar  = month_to_seasonN(f->xclm_em, SEASON)
std_ar  = month_to_seasonN(f->xstd_em, SEASON)
clm_std_ar  = month_to_seasonN(f->xclm_std, SEASON) ;STD over ensembles

f   = addfile(diri3+"cesm/clim/"+MODEL2+"_"+EXP2+"_clim_"+VAR+"_"+yrs+"-"+yrl+".nc", "r")  
clm_wc  = month_to_seasonN(f->xclm_em, SEASON)
std_wc  = month_to_seasonN(f->xstd_em, SEASON)
clm_std_wc  = month_to_seasonN(f->xclm_std, SEASON) ;STD over ensembles

printVarSummary(clm_ar)

; fils1 = systemfunc("ls "+diri3+"cesm/trend/"+MODEL1+"_"+EXP1+"_*_trend_SST_"+yrs+"-"+yrl+".nc");
; print(fils1)
; ft1   = addfiles(fils1, "r")  ;multiple files
; ListSetType (ft1, "join")        ; concatenate (=default)
; trend_ar  = dim_avg_n_Wrap(ft1[:]->trend_p,0)

; printVarSummary(trend_ar)

; fils2 = systemfunc("ls "+diri3+"cesm/trend/"+MODEL2+"_"+EXP2+"_*_trend_SST_"+yrs+"-"+yrl+".nc");
; print(fils2)
; ft2   = addfiles(fils2, "r")  ;multiple files
; ListSetType (ft2, "join")        ; concatenate (=default)
; trend_wc  = dim_avg_n_Wrap(ft2[:]->trend_p,0)

; printVarSummary(trend_wc)


f   = addfile(diri3+"cesm/clim/"+MODEL1+"_"+EXP1+"_clim_"+VARu+"_"+yrs+"-"+yrl+".nc", "r")  
uclm_ar  = month_to_seasonN(f->xclm_em, SEASON)

f   = addfile(diri3+"cesm/clim/"+MODEL2+"_"+EXP2+"_clim_"+VARu+"_"+yrs+"-"+yrl+".nc", "r")  
uclm_wc  = month_to_seasonN(f->xclm_em, SEASON)


f   = addfile(diri3+"cesm/clim/"+MODEL1+"_"+EXP1+"_clim_"+VARv+"_"+yrs+"-"+yrl+".nc", "r")  
vclm_ar  = month_to_seasonN(f->xclm_em, SEASON)

f   = addfile(diri3+"cesm/clim/"+MODEL2+"_"+EXP2+"_clim_"+VARv+"_"+yrs+"-"+yrl+".nc", "r")  
vclm_wc  = month_to_seasonN(f->xclm_em, SEASON)


printVarSummary(vclm_ar)

if(clm_ar@units.eq."K") then 
  clm_ar = clm_ar -273.15
  clm_ar@units = "degC"
  clm_wc = clm_wc -273.15
  clm_wc@units = "degC"
end if

if(COVER_LAND) then 
;-------------------------------------
;cover land data; do this first!!
;mask 0=ocean (land reserved), 1=land, 2=lake, 3=small island, 4=ice shelf.

lland = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsm0 = landsea_mask(lland->LSMASK,clm_ar&lat,clm_ar&lon)
clm_ar_sea = mask(clm_ar,lsm0.eq.1, False)      ; mask out land points
clm_wc_sea = mask(clm_wc,lsm0.eq.1, False)      ; mask out land points
copy_VarMeta(clm_ar, clm_ar_sea)
copy_VarMeta(clm_wc, clm_wc_sea)

clm_ar = clm_ar_sea
clm_wc = clm_wc_sea
delete(lsm0)

end if 

;;;-----------------------------------

clm_wc_dif = clm_ar
clm_wc_dif = clm_ar - clm_wc
uclm_wc_dif = uclm_ar
uclm_wc_dif = uclm_ar - uclm_wc
vclm_wc_dif = vclm_ar
vclm_wc_dif = vclm_ar - vclm_wc
printVarSummary(clm_wc_dif)

; Cloud radiation = net SW - clear-sky SW
cloudrs_dif = uclm_wc_dif
cloudrs_dif = uclm_wc_dif - vclm_wc_dif


; if(VAR.eq."pr") then
;   var = var * 3600 *24
;   var@units = "mm/day/decades"
; end if


;Read seeding mask
fs   = addfile(dirip+"mask_0375_050_SSP245.nc", "r")  
seedmask  = month_to_seasonN(fs->mask, SEASON)
lat = fs->lat 
lon = fs->lon
lon@units = "degrees_east"
lat@units = "degrees_north"
seedmask&lat = lat 
seedmask&lon = lon 

printVarSummary(seedmask)

;-------------------------------------
;cover land data; do this first!!
;mask 0=ocean (land reserved), 1=land, 2=lake, 3=small island, 4=ice shelf.
lland = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsm0 = landsea_mask(lland->LSMASK,cloudrs_dif&lat,cloudrs_dif&lon)
cloudrs_sea = mask(cloudrs_dif,lsm0.eq.1, False)      ; mask out land points
copy_VarMeta(cloudrs_dif, cloudrs_sea)
delete(lsm0)

;------------------------------------------------
; precipitation change percentage

ratio = clm_wc_dif
ratio = clm_wc_dif / clm_wc
printVarSummary(ratio)

;------------------------------------------------
; relative SST (30S-30N)

lat = clm_wc_dif&lat
rad    = 4.0*atan(1.0)/180.0
clat   = cos(lat*rad)
copy_VarCoords(clm_wc_dif(0,0,:,0), clat)
; go = wgt_areaave_Wrap(x,clat, 1.0, 1)

NLAT1 =  30.;
SLAT1 =  -30.;
WLON1 =  120.;
ELON1 =  300.;

trop_sst_mean = wgt_areaave_Wrap(clm_wc_dif(:,:,{SLAT1:NLAT1},{WLON1:ELON1}),clat({SLAT1:NLAT1}), 1.0, 1)
printVarSummary(trop_sst_mean)
relative_clm_wc_dif = clm_wc_dif - conform(clm_wc_dif, trop_sst_mean, (/0,1/))
copy_VarMeta(clm_wc_dif, relative_clm_wc_dif)
printVarSummary(relative_clm_wc_dif)


;-------t-test---------------------------------
oned = ndtooned(clm_std_wc)
oned1 = where(oned.eq.0,clm_std_wc@_FillValue,oned)
clm_std_wc = reshape(oned1, dimsizes(clm_std_wc))

delete([/oned,oned1/])

ndim = dimsizes(clm_ar)
df = clm_wc_dif
df = ndim(0)
b = clm_wc_dif
b = 0.5
p_tval = clm_wc_dif
p_tval = (clm_wc_dif)*sqrt(ndim(0))/clm_std_wc
; clm_prob = (1.-betainc( df/(df+p_tval^2), df/2.0, b))*100.  ; probability in %

; False discovery rate
pvals = betainc( df/(df+p_tval^2), df/2.0, b)
pflat = ndtooned(pvals)

; psort = dim_pqsort(pflat,0)
m     = dimsizes(pflat)
alpha = 0.05

; Build thresholds and find critical p
thresh = new(m, float)
do k = 0, m-1
  thresh(k) = (k+1)/tofloat(m) * alpha
end do
idx_ok = where(pflat .le. thresh, pflat,pflat@_FillValue)
pcrit = max(idx_ok)
print(pcrit)

; Create FDR mask on original grid
; now marks which gridpoints survive FDR at α=0.05
clm_prob = where((pvals/100.0) .le. pcrit,(1-pvals)*100,-((1-pvals)*100))
copy_VarCoords(clm_wc_dif,clm_prob)
printMinMax(clm_prob, 0)
printVarSummary(clm_prob)

delete([/df,b,pvals,idx_ok,thresh,pflat/])

;--------------plot-------------------
; gsn_define_colormap(wks, "NCV_blu_red") ;"NCV_blu_red" "MPL_BrBG"


res2 = True
res2@gsnDraw = False        ;dont draw
res2@gsnFrame = False        ;dont advance frame
res2@gsnLeftString = ""
res2@gsnRightString = ""
res2@vpWidthF  = 0.6
res3 = res2
sdres = res2
  opt = res2
  vcres = res2 

res2@mpCenterLonF = 180.
res2@mpFillOn = False
res2@mpFillDrawOrder = "PostDraw"
res2@tmXBLabelFontHeightF = 0.022         ; change maj lat tm spacing
res2@tmYLLabelFontHeightF = res2@tmXBLabelFontHeightF
res2@gsnMajorLonSpacing = 50              ; change maj lon tm spacing


;  res2@mpMaxLatF                   =  10;30
;  res2@mpMinLatF                   = -10;30
;  res2@mpMaxLonF                   = 300;360
;  res2@mpMinLonF                   = 100;0
res2@gsnAddCyclic = True ;False
res2@cnFillOn = True;False ;
res2@cnLinesOn = False;True ;
res2@cnLineLabelsOn = False
res2@cnFillPalette = "NCV_blu_red" ;"NCV_blu_red" "MPL_BrBG"
if(VAR.eq."PRECC".or.VAR.eq."PRECT") then 
    res2@cnFillPalette = "MPL_BrBG"
end if 

res2@gsnLeftStringFontHeightF = 0.03
res2@gsnRightStringFontHeightF = res2@gsnLeftStringFontHeightF
res2@lbOrientation = "Horizontal"
res2@lbBoxEndCapStyle = "TriangleBothEnds"
res2@lbBoxLinesOn  = False
res2@lbTitleOn        =  True                ; turn on title
res2@lbLabelStride    = 2
res2@lbTitleString    = clm_wc_dif@units                ; title string
res2@lbTitlePosition  = "Right"              ; title position
res2@lbTitleFontHeightF= .02                ; make title smaller
res2@lbTitleDirection = "Across"
res2@lbTitleExtentF   = 0.01 ;Default: 0.15
res2@lbLabelFontHeightF = 0.02  ;Default: 0.02
; res2@pmLabelBarWidthF = 0.05
res2@pmLabelBarOrthogonalPosF = 0.2 ;default 0.02

res2@lbLabelBarOn = True;
res2@cnLevelSelectionMode  = "ManualLevels"

res3@cnFillOn  = False
res3@cnInfoLabelOn            = False
;res3@cnLinesOn = True
res3@cnLineLabelsOn = False ;
; res3@cnLevelFlags = "Line" ;control over whether a line and/or a line label is to appear at each contour level
res3@cnLineLabelBackgroundColor = -1
res3@cnLineColor = "chartreuse"
; res3@cnLineLabelInterval = 1
; res3@cnLineLabelPlacementMode = "constant"
res3@cnLineThicknessF = 3.0
res3@cnLineLabelFontHeightF = 0.01
res3@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
res3@cnLevels = fspan(-200, -30, 18) ;(/-6.,-4.,-2.,2.,4.,6.,8.,10./)
; res3@cnLevelSpacingF = 20.0

vcres@vcGlyphStyle            = "Fillarrow"    ; turn on curly vectors
; vcres@vcFillArrowFillColor    = "purple"
vcres@vcFillArrowEdgeColor    = "white"
; vcres@vcLineArrowColor        = "seagreen1"           ; change vector color
vcres@vcLineArrowThicknessF   = 2.0               ; change vector thickness
vcres@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
vcres@vcMinFracLengthF        = 0.4
vcres@vcMinDistanceF          = 0.025
vcres@vcRefLengthF            = 0.045             ; define length of vec ref

vcres@vcRefAnnoOn             = True
vcres@vcRefAnnoPerimOn          = False

vcres@vcRefAnnoString2          = uclm_ar@units            ;not draw the word"reference vector"
vcres@vcRefAnnoOrthogonalPosF = -0.7            ; move ref vector up

vcres@lbLabelBarOn = False

vcres@vcRefMagnitudeF         = 10.           ; define vector ref mag


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


res2@cnMinLevelValF        =  -COUNTERMX(iv) ;40.;4. ;120.; 
res2@cnMaxLevelValF        =   COUNTERMX(iv) ;40.;4. ;120.; 
res2@cnLevelSpacingF       =  res2@cnMaxLevelValF/10.


  res2@gsnLeftString = "" ;MODEL1
  plot(iv) = gsn_csm_contour_map_ce(wks, clm_wc_dif(isea,0,:,:), res2) ;dim_avg_n_Wrap(clm_wc(:,0,:,:),0) ; or annual mean

  res2@gsnRightString = VAR
  res2@gsnLeftString =  MODEL1+" - reference"
  plot2(2) = gsn_csm_contour_map_ce(wks, clm_wc_dif(isea,0,:,:), res2)

  plot4(iv) = gsn_csm_contour_map_ce(wks, relative_clm_wc_dif(isea,0,:,:), res2)


res2@cnMinLevelValF        =  -1.0
 res2@cnMaxLevelValF        =   1.0
 res2@cnLevelSpacingF       =  res2@cnMaxLevelValF/10.
res2@lbTitleString    = ""               ; title string
 
 plot5(iv) = gsn_csm_contour_map_ce(wks, ratio(isea,0,:,:), res2) 


res2@lbTitleString    = clm_wc_dif@units                ; title string
res2@cnMinLevelValF        = 10 ;290.; 
  res2@cnMaxLevelValF        = 35;310.; 
  res2@cnLevelSpacingF       = 1.; res2@cnMaxLevelValF/20.

 res2@mpMaxLatF                   =  45
 res2@mpMinLatF                   = -45
 res2@mpMaxLonF                   = 360
 res2@mpMinLonF                   = 90

 res2@gsnLeftString =  "reference"
 plot2(0) = gsn_csm_contour_map_ce(wks, clm_wc(isea,0,:,:), res2)

   res2@gsnLeftString =  MODEL1
 plot2(1) = gsn_csm_contour_map_ce(wks, clm_ar(isea,0,:,:), res2)



 res2@cnMinLevelValF        =  -COUNTERMX(iv)/2 ;40.;4. ;120.; 
 res2@cnMaxLevelValF        =   COUNTERMX(iv)/2 ;40.;4. ;120.; 
 res2@cnLevelSpacingF       =  res2@cnMaxLevelValF/10.
 
; res2@lbTitleString    = trend_wc@units                ; title string
; res2@gsnLeftString =  "reference"
; plot3(0) = gsn_csm_contour_map_ce(wks, trend_wc, res2)

;   res2@gsnLeftString =  MODEL1
; plot3(1) = gsn_csm_contour_map_ce(wks, trend_ar, res2)


  ; if(VAR.eq."TS".and.MODEL1.eq."MCB") then 
;   plota = gsn_csm_vector(wks, uclm_wc_dif(isea,0,:,:), vclm_wc_dif(isea,0,:,:), vcres) 
;   overlay(plot(iv),plota)

    rsmask = gsn_csm_contour(wks, seedmask(isea,0,:,:), sdres); 
    rsmask = gsn_contour_shade(rsmask,-999,0.5, opt)   ; Shade contours above .5
    ; overlay(plot(iv), rsmask)


    ; end if 


    delete(opt@gsnShadeHigh)
    sdres@cnFillColor = "gray38";"lightpink" ;"green"
    sdres@cnFillDotSizeF       = 0.0025            ; increase dot size of contours
    sdres@cnFillOpacityF = 0.5
    opt@gsnShadeLow =  3 ;6       ;
    plota = gsn_csm_contour(wks, clm_prob(isea,0,:,:), sdres);clm_prob 
    plota = gsn_contour_shade(plota,95, -999,opt)   ; Shade contours below 95
    overlay(plot(iv), plota)


delete([/res3,res2,opt,sdres/])

resk = True
resk@gsnPanelLabelBar   = True                 ; add common colorbar
resk@gsnMaximize = True
resk@gsnPaperOrientation = "portrait"   ; force portrait
resk@lbBoxEndCapStyle = "TriangleBothEnds"
resk@lbOrientation = "Horizontal"
resk@lbBoxLinesOn = False
resk@lbTitlePosition  = "Right"              ; title position
resk@lbTitleFontHeightF= .03                ; make title smaller
resk@lbTitleDirection = "Across"
resk@lbTitleExtentF   = 0.01 ;Default: 0.15
;resk@lbBoxMinorExtentF = 0.2
resk@lbLabelFontHeightF = 0.01  ;Default: 0.02
;resk@pmLabelBarWidthF = 0.1
;resk@pmLabelBarHeightF = 0.2
;resk@pmLabelBarParallelPosF = 0.3 ;default 0.5
;resk@pmLabelBarOrthogonalPosF = 0.005 ;default 0.02
resk@txFontHeightF = 0.03
resk@lbTitleString = clm_wc_dif@units
resk@gsnPanelLabelBar   = False                 ; add common colorbar
resk@txString = SEASON(isea)+""
gsn_panel(wks,plot2,(/3,1/),resk)
gsn_panel(wks,plot2(0),(/1,1/),resk)
gsn_panel(wks,plot2(1),(/1,1/),resk)
; resk@txString = "Trend in DJF"
; gsn_panel(wks,plot3,(/2,1/),resk)
end do 

resk@txString = ""
gsn_panel(wks,plot,(/dimsizes(VARa),1/),resk)
resk@txString = "Relative to tropical Pacific average"
gsn_panel(wks,plot4,(/dimsizes(VARa),1/),resk)
resk@txString = "percentage relative to climatology"
gsn_panel(wks,plot5,(/dimsizes(VARa),1/),resk)



end
