begin
diri = "/glade/work/chenxing/geog/"
dirip = "/glade/u/home/chenxing/geog/"

diri2 = "/gpfs/fs1/collections/cdg/data/CLIVAR_LE/"
;from lens_index.ncl
diri3 = "/glade/derecho/scratch/chenxing/geog/"
; diri4 =  "/glade/p/cesm/community/CESM-LE/data/CESM-CAM5-BGC-LE/ocn/proc/tseries/monthly/"
diri4 =  "/glade/p/cesm/community/CESM-LE/data/CESM-CAM5-BGC-LE/atm/proc/tseries/monthly/"
diri6 = "/glade/campaign/cgd/cesm/CESM2-LE/atm/proc/tseries/month_1/"

diri_arise = "/glade/campaign/cesm/collections/ARISE-SAI-1.5/b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT"
diri_waccm = "/glade/campaign/cesm/collections/CESM2-WACCM-SSP245/b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM"
diri_glen = "/glade/campaign/cesm/collections/GLENS/"

SEASON = (/"DJF","MAM","JJA","SON" /)

yrs = 2035;(/2035,2047,2059/);(/2035,2035,2035,2035 /);(/2015,2035,2010,2020 /);
yrl = 2069;(/2045,2057,2068/);2069;(/2069,2069,2069,2069 /);(/2069,2069,2097,2099 /);

MODEL1 = "MCB"; "ARISE-SAI-1.5";
EXP1 = "SSP245"
MODEL2 = "CAM" ;"CESM2-WACCM";"CESM2";
EXP2 = "SSP245";"piControl"; 

ISOT_TEMP = 20

wks    = gsn_open_wks("pdf",dirip+"cesm_isot20")
plot1 = new(30, graphic)
plot2 = new(30, graphic)
plot3 = new(30, graphic)

;---------read output---------------
; from cesm_isot20_output.ncl
; CAM_SSP245.004_isot20_2035-2069.nc
; MCB_SSP245.001_isot20_2035-2069.nc
fils1 = systemfunc("ls "+diri+"cesm/isot"+ISOT_TEMP+"/"+MODEL1+"_"+EXP1+".*_isot"+ISOT_TEMP+"_"+yrs+"-"+yrl+".nc")
f1   = addfiles(fils1, "r")  
ListSetType (f1, "join")     
ar  = month_to_seasonN(dim_avg_n_Wrap(f1[:]->isot,0), SEASON)

fils2 = systemfunc("ls "+diri+"cesm/isot"+ISOT_TEMP+"/"+MODEL2+"_"+EXP2+".*_isot"+ISOT_TEMP+"_"+yrs+"-"+yrl+".nc");1-499.nc");
f2   = addfiles(fils2, "r")  
ListSetType (f2, "join")     
wc  = month_to_seasonN(dim_avg_n_Wrap(f2[:]->isot,0), SEASON)
ar@units = "m"
wc@units = "m"
printVarSummary(ar)
printVarSummary(wc)

f_pi   = addfile(diri+"cesm/isot"+ISOT_TEMP+"/CESM2_piControl.001_isot"+ISOT_TEMP+"_1-499.nc", "r")  

clm_ar = month_to_seasonN(clmMonTLL(dim_avg_n_Wrap(f1[:]->isot,0)), SEASON)
clm_wc = month_to_seasonN(clmMonTLL(dim_avg_n_Wrap(f2[:]->isot,0)), SEASON)
clm_pi = month_to_seasonN(clmMonTLL(f_pi->isot), SEASON)
clm_ar@units = "m"
clm_wc@units = "m"
clm_pi@units = "m"
printVarSummary(clm_wc)
printVarSummary(clm_ar)

;----------------------------------------------------------------

wc_dif = ar
wc_dif = ar - wc

clm_wc_dif = clm_ar
clm_wc_dif = clm_ar - clm_wc

printVarSummary(wc_dif)

;----------------------------------------------------------------   
;;;; trend
iytr = 5 ; the first iytr years of the trend
year = ispan(yrs,yrs+iytr-1,1)
trend_xdif = regCoef_n(year,wc_dif(:,:iytr-1,:,:),0,1)
trend_xdif@long_name = "Trend"
trend_xdif@units  = wc_dif@units+"/year"
copy_VarCoords(wc_dif(:,0,:,:), trend_xdif)
printVarSummary(trend_xdif)

;--------------plot-------------------
gsn_define_colormap(wks, "NCV_blu_red") ;"NCV_blu_red" "MPL_BrBG"


res2 = True
res2@gsnDraw = False        ;dont draw
res2@gsnFrame = False        ;dont advance frame
res2@gsnLeftString = ""
res2@gsnRightString = ""
res2@vpWidthF  = 0.8
res2@vpHeightF = 0.4
res3 = res2
sdres = res2
  opt = res2
vcres = res2 

res2@mpCenterLonF = 180.
res2@mpFillOn = False
res2@mpFillDrawOrder = "PostDraw"
res2@tmXBLabelFontHeightF = 0.018         ; change maj lat tm spacing
res2@tmYLLabelFontHeightF = res2@tmXBLabelFontHeightF
res2@gsnMajorLonSpacing = 50              ; change maj lon tm spacing
res2@gsnAddCyclic = True ;False

 res2@mpMaxLatF                   =  60
 res2@mpMinLatF                   = -60
 res2@mpMaxLonF                   = 360
 res2@mpMinLonF                   = 0

res2@cnFillOn = True;False ;
res2@cnLinesOn = False;True ;
res2@cnLineLabelsOn = False

res2@gsnLeftStringFontHeightF = 0.03
res2@gsnRightStringFontHeightF = res2@gsnLeftStringFontHeightF
res2@lbOrientation = "Vertical" ;
res2@lbBoxEndCapStyle = "TriangleBothEnds"
res2@lbBoxLinesOn  = False
res2@lbTitleOn        =  True                ; turn on title
res2@lbLabelStride    = 4
res2@lbTitlePosition  = "Top"              ; title position
res2@lbTitleFontHeightF= .02                ; make title smaller
res2@lbTitleDirection = "Across"
res2@lbTitleExtentF   = 0.01 ;Default: 0.15
res2@lbLabelFontHeightF = 0.02  ;Default: 0.02
; res2@pmLabelBarWidthF = 0.05

res2@lbLabelBarOn = True; False;
res2@cnLevelSelectionMode  = "ManualLevels"

res3@cnFillOn  = False
res3@cnInfoLabelOn            = False
;res3@cnLinesOn = True
;res3@cnLineLabelsOn = True ;
res3@cnLevelFlags = "LineAndLabel" ;control over whether a line and/or a line label is to appear at each contour level
res3@cnLineLabelBackgroundColor = -1
res3@cnLineLabelInterval = 4
; res3@cnLineLabelPlacementMode = "constant"
res3@cnLineThicknessF = 2.0
res3@cnLineLabelFontHeightF = 0.01
; res3@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
; res3@cnLevels = (/-6.,-4.,-2.,2.,4.,6.,8.,10./)
; res3@cnLevelSpacingF = 0.1
res3@cnLineColor = "green"



sdres@cnFillOn = False
sdres@cnLinesOn = False
sdres@cnLineLabelsOn        = False; True   
 

    ndim = dimsizes(clm_ar)

    do  isea = 0,3

    res2@lbTitleString    = trend_xdif@units                ; title string
    res2@cnMinLevelValF        =  -20.
    res2@cnMaxLevelValF        =   20.
    res2@cnLevelSpacingF       =  res2@cnMaxLevelValF/10.
  
    res2@gsnLeftString = MODEL1+" - reference"
    res2@gsnRightString = SEASON(isea) 
    plot2(isea) = gsn_csm_contour_map_ce(wks, trend_xdif(isea,:,:), res2) 

    res2@lbTitleString    = clm_ar@units                ; title string
  

  res2@cnMinLevelValF        =  -60.
  res2@cnMaxLevelValF        =   60.
  res2@cnLevelSpacingF       =  res2@cnMaxLevelValF/10.

  plot1(isea) = gsn_csm_contour_map_ce(wks, clm_wc_dif(isea,0,:,:), res2) 
;   plota = gsn_csm_contour(wks, clm_ar(isea,0,:,:), res3) 
;   overlay(plot1(isea),plota)
end do 

res2@gsnRightString = "DJF"
res2@gsnLeftString = "c   "+MODEL1+" - SSP2-4.5(CAM)";reference" ;SSP245"
plot3(2) = gsn_csm_contour_map_ce(wks, clm_wc_dif(0,0,:,:), res2) 

res2@cnMinLevelValF        =  0.
res2@cnMaxLevelValF        =  300.
res2@cnLevelSpacingF       =  res2@cnMaxLevelValF/20.
res2@gsnLeftString = "a   SSP2-4.5(CAM)" ;"reference" ;"CESM-CAM6 SSP245"
plot3(0) = gsn_csm_contour_map_ce(wks, clm_wc(0,0,:,:), res2) 
res2@gsnLeftString = "b   "+MODEL1
plot3(1) = gsn_csm_contour_map_ce(wks, clm_ar(0,0,:,:), res2) 

print("Thermocline depth of "+ISOT_TEMP)
print("In "+MODEL2+" "+EXP2+", it is "+avg(clm_wc(0,0,{-5:5},{120:360-90})))
print("In "+MODEL1+" "+EXP1+", it is "+avg(clm_ar(0,0,{-5:5},{120:360-90})))
print("In "+MODEL2+" piControl, it is "+avg(clm_pi(0,0,{-5:5},{120:360-90})))
print("Their difference is "+avg(clm_wc_dif(0,0,{-5:5},{120:360-90})))

resk = True
resk@gsnPanelLabelBar   = False                 ; add common colorbar
resk@gsnMaximize = True
resk@gsnPaperOrientation = "portrait"   ; force portrait
resk@lbBoxEndCapStyle = "TriangleBothEnds"
resk@lbOrientation = "Horizontal"
resk@lbBoxLinesOn = False
resk@lbTitlePosition  = "Right"              ; title position
resk@lbTitleFontHeightF= .03               
resk@lbTitleDirection = "Across"
resk@lbTitleExtentF   = 0.01 ;Default: 0.15
resk@lbLabelStride    = 4
;resk@lbBoxMinorExtentF = 0.2
resk@lbLabelFontHeightF = 0.02  ;Default: 0.02
;resk@pmLabelBarWidthF = 0.1
;resk@pmLabelBarHeightF = 0.2
;resk@pmLabelBarParallelPosF = 0.3 ;default 0.5
;resk@pmLabelBarOrthogonalPosF = 0.005 ;default 0.02
resk@txFontHeightF = 0.01
resk@lbTitleString = clm_ar@units

resk@txString = ISOT_TEMP+" C isothem depth mean state changes"
gsn_panel(wks,plot1,(/2,2/),resk)
gsn_panel(wks,plot3,(/3,1/),resk)

resk@txString = "Trend in "+ISOT_TEMP+" C isothem depth in the first "+iytr+" years"
gsn_panel(wks,plot2,(/2,2/),resk)


delete([/res3,res2,vcres/])
end
