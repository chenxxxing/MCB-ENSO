; For Figure 3c and 3d
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

TARGET = "profile_clm" ;"extremeLaNina" ;"extremeElNino" ;
MODEL1 = "MCB";"MCB-feed";"ARISE-SAI-1.5" ;  "MCB-feed";
EXP1 = "SSP245"; "MCB-feedback-1DOF"; "MCB-feedforward-1DOF";
MODEL2 = "CAM";"CESM2-WACCM" ;
EXP2 = "SSP245"

VAR = "OMEGA" ;"T" ;"TEMP"
VU = "U"; "UVEL"
VW = "OMEGA" ;"WVEL"
VO = "TEMP" ;"OMEGA" ;"WVEL"
SLAT = -5
NLAT = 5
WLON = 90;0;
ELON = 360-60;360;100;90
OWLON = 118;0;
OELON = 360-80

DEPTH1 = 1000; hPa ; 0;
DEPTH2 = 100; hPa ; 800*100 ; depth (cm) for the variable
ODEPTH1 = 0; ocean depth setting 
ODEPTH2 = 800*100 ; depth (cm) for the variable

; MODELa = "CAM","MCB","GLENS","GLENS","CESM2-WACCM","ARISE-SAI-1.5"
; EXPa =  "SSP245","SSP245","control","feedback","SSP245","SSP245"

iyr = 0
; do iyr = 0,dimsizes(yrsa)-1
yrs = yrsa(iyr)
yrl = yrla(iyr)
; yrsgg = yrsg(iyr)
; yrlgg = yrlg(iyr)

wks    = gsn_open_wks("pdf",dirip+"cesm_"+TARGET+"_"+VAR+"_"+iyr)
plot1 = new(30, graphic)
plot2 = new(30, graphic)
plot3 = new(30, graphic)
plot4 = new(30, graphic)
plot5 = new(30, graphic)
plot6 = new(30, graphic)
plot7 = new(30, graphic)
plot8 = new(30, graphic)
;---------read output---------------
; from profile_output.ncl
; ARISE-SAI-1.5_SSP245_profile_clm_WVEL_-5-5_2035-2069.nc
f   = addfile(diri3+"cesm/profile/"+MODEL1+"_"+EXP1+"_"+TARGET+"_"+VAR+"_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc", "r")  
clm_ar  = month_to_seasonN(f->xclm_em(:,{DEPTH1:DEPTH2},{WLON:ELON-0.01}), SEASON)

f   = addfile(diri3+"cesm/profile/"+MODEL2+"_"+EXP2+"_"+TARGET+"_"+VAR+"_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc", "r")  
clm_wc  = month_to_seasonN(f->xclm_em(:,{DEPTH1:DEPTH2},{WLON:ELON-0.01}), SEASON)
clm_std_wc  = month_to_seasonN(f->xclm_std(:,{DEPTH1:DEPTH2},{WLON:ELON-0.01}), SEASON) ;STD over ensembles
printVarSummary(clm_ar)

f   = addfile(diri3+"cesm/profile/"+MODEL1+"_"+EXP1+"_"+TARGET+"_"+VU+"_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc", "r")  
uclm_ar  = month_to_seasonN(f->xclm_em(:,{DEPTH1:DEPTH2},{WLON:ELON-0.01}), SEASON)
f   = addfile(diri3+"cesm/profile/"+MODEL2+"_"+EXP2+"_"+TARGET+"_"+VU+"_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc", "r")  
uclm_wc  = month_to_seasonN(f->xclm_em(:,{DEPTH1:DEPTH2},{WLON:ELON-0.01}), SEASON)

f   = addfile(diri3+"cesm/profile/"+MODEL1+"_"+EXP1+"_"+TARGET+"_"+VW+"_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc", "r")  
wclm_ar  = month_to_seasonN(f->xclm_em(:,{DEPTH1:DEPTH2},{WLON:ELON-0.01}), SEASON)
f   = addfile(diri3+"cesm/profile/"+MODEL2+"_"+EXP2+"_"+TARGET+"_"+VW+"_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc", "r")  
wclm_wc  = month_to_seasonN(f->xclm_em(:,{DEPTH1:DEPTH2},{WLON:ELON-0.01}), SEASON)

; f   = addfile(diri3+"cesm/profile/"+MODEL1+"_"+EXP1+"_"+TARGET+"_T_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc", "r")  
f   = addfile(diri3+"cesm/profile/MCB_SSP245_"+TARGET+"_T_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc", "r")  
tclm_ar  = month_to_seasonN(f->xclm_em(:,{DEPTH1:DEPTH2},{WLON:ELON-0.01}), SEASON)
f   = addfile(diri3+"cesm/profile/"+MODEL2+"_"+EXP2+"_"+TARGET+"_T_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc", "r")  
tclm_wc  = month_to_seasonN(f->xclm_em(:,{DEPTH1:DEPTH2},{WLON:ELON-0.01}), SEASON)

f   = addfile(diri3+"cesm/profile/"+MODEL1+"_"+EXP1+"_"+TARGET+"_"+VO+"_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc", "r")  
oclm_ar  = month_to_seasonN(f->xclm_em(:,{ODEPTH1:ODEPTH2},{OWLON:OELON}), SEASON)
f   = addfile(diri3+"cesm/profile/"+MODEL2+"_"+EXP2+"_"+TARGET+"_"+VO+"_"+SLAT+"-"+NLAT+"_"+yrs+"-"+yrl+".nc", "r")  
oclm_wc  = month_to_seasonN(f->xclm_em(:,{ODEPTH1:ODEPTH2},{OWLON:OELON}), SEASON)
oclm_std_wc  = month_to_seasonN(f->xclm_std(:,{ODEPTH1:ODEPTH2},{OWLON:OELON}), SEASON) ;STD over ensembles
printVarSummary(oclm_wc)

f   = addfile(diri3+"cesm/profile/CESM2_piControl_"+TARGET+"_"+VO+"_"+SLAT+"-"+NLAT+"_1000-2000.nc", "r")  
oclm_pi  = month_to_seasonN(f->xclm_em(:,{ODEPTH1:ODEPTH2},{OWLON:OELON}), SEASON)

if(VW.eq."OMEGA")then 
; The vertical component of the wind speed vector was approximated from the pressure velocities using the relationship 
; w = ω/(−ρg), where ρ is air density and g is gravitational acceleration, and is scaled by 10^4. (Naiman et al. 2017; 
;https://journals.ametsoc.org/view/journals/clim/30/11/jcli-d-16-0512.1.xml)

g = 9.8 ; m s^-2 ; gravity
p0 = 1000 ; kg/m3

; convert omega to w
                                  ; make p[*] conform to omega[*][*][*][*]
P       = conform(wclm_ar, wclm_ar&lev, 2)   ; P(:,:,:,:)
P       = P*100                   ; hPa -> Pa
P@units = "Pa"
wclm_ar       = tofloat(omega_to_w(wclm_ar, P, tclm_ar))      ; w[*][*][*][*] (m/s)
wclm_wc       = tofloat(omega_to_w(wclm_wc, P, tclm_wc))      ; w[*][*][*][*] (m/s)

scale  = -1000; 500;fabs(uAve/wAve)
print("scale is "+scale)
wclm_ar = wclm_ar*scale ;/(g*p0)
wclm_wc = wclm_wc*scale ;/(g*p0)


end if 
printVarSummary(wclm_ar)

if(VW.eq."WVEL")then 
  ;
  ; Vertical motion is significantly smaller than horizonal currents, so we will
  ; scale it so that some vertical motion is visible
  ;
  wAve   = avg(wclm_ar(0,0,{:10000},{121}))           ; used for scaling
  uAve   = avg(uclm_ar(0,0,{:10000},{121}))
  scale  = 300000; fabs(uAve/wAve)
  print(wAve+" "+uAve+" "+scale)
  wscale_ar = wclm_ar*scale                       ; now scale
  wscale_wc = wclm_wc*scale                       ; now scale

  copy_VarCoords(wclm_ar, wscale_ar)            
  copy_VarCoords(wclm_wc, wscale_wc)            

  wclm_ar = wscale_ar
  wclm_wc = wscale_wc

  ;----------------------------------------------------------------
  ; depth units from cm to m 

  z_t = clm_ar&z_t
  z_t = z_t/100.
  z_t@units = "m"
  clm_ar&z_t = z_t

  z_t = clm_wc&z_t
  z_t = z_t/100.
  z_t@units = "m"
  clm_wc&z_t = z_t

end if 
;----------------------------------------------------------------

clm_wc_dif = clm_ar
clm_wc_dif = clm_ar - clm_wc

uclm_wc_dif = uclm_ar
uclm_wc_dif = uclm_ar - uclm_wc

wclm_wc_dif = wclm_ar;
wclm_wc_dif = wclm_ar - wclm_wc;

oclm_wc_dif = oclm_ar;
oclm_wc_dif = oclm_ar - oclm_wc;

printVarSummary(clm_wc_dif)
printVarSummary(wclm_wc_dif)

;-------t-test---------------------------------
oned = ndtooned(clm_std_wc)
oned1 = where(oned.eq.0,clm_std_wc@_FillValue,oned)
clm_std_wc = reshape(oned1, dimsizes(clm_std_wc))
delete([/oned,oned1/])

oned = ndtooned(oclm_std_wc)
oned1 = where(oned.eq.0,oclm_std_wc@_FillValue,oned)
oclm_std_wc = reshape(oned1, dimsizes(oclm_std_wc))
delete([/oned,oned1/])

ndim = dimsizes(clm_wc_dif)
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

ndim2 = dimsizes(oclm_wc_dif)
df = oclm_wc_dif
df = ndim2(0)
b = oclm_wc_dif
b = 0.5
p_tval2 = oclm_wc_dif
p_tval2 = (oclm_wc_dif)*sqrt(ndim2(0))/oclm_std_wc
; oclm_prob = (1.-betainc( df/(df+p_tval2^2), df/2.0, b))*100.  ; probability in %

; False discovery rate
pvals = betainc( df/(df+p_tval2^2), df/2.0, b)
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
oclm_prob = where((pvals/100.0) .le. pcrit,(1-pvals)*100,-((1-pvals)*100))
copy_VarCoords(oclm_wc_dif,oclm_prob)
printMinMax(oclm_prob, 0)
printVarSummary(oclm_prob)

delete([/df,b,pvals,idx_ok,thresh,pflat/])

; ;----------------------------------------------------------------
; ; crop only Pacific ocean temp

; oclm_wc_dif(:,:,:,{:118}) = oclm_wc_dif@_FillValue
; oclm_pi(:,:,:,{:118}) = oclm_pi@_FillValue
; oclm_ar(:,:,:,{:118}) = oclm_ar@_FillValue
; oclm_wc(:,:,:,{:118}) = oclm_wc@_FillValue

z_t = oclm_wc_dif&z_t
z_t = z_t / 100.
z_t@units = "m"
oclm_wc_dif&z_t = z_t
oclm_pi&z_t = z_t
oclm_ar&z_t = z_t
oclm_wc&z_t = z_t
oclm_prob&z_t = z_t

;----------------------------------------------------------------
; find thermocline depth based on Fiedler 2010:
; thermocline temperature TT =T(MLD) – 0.25 [T(MLD) – T(400 m)], 
; where the temperature atthe base of the mixed layer T(MLD) = SST – 0.8


x1 = oclm_ar;(:,:,:,{140:270})
ndim = dimsizes(x1)
depth = x1&z_t

T_MLD = x1(:,:,0,:) - 0.8
temp_thermocline1 = T_MLD - 0.25*(T_MLD - x1(:,:,{400},:))

x2 = oclm_wc;(:,:,:,{140:270})
T_MLD = x2(:,:,0,:) - 0.8
temp_thermocline2 = T_MLD - 0.25*(T_MLD-x2(:,:,{400},:))

therm_depth_ar = x1(:,:,0,:)
therm_depth_wc = x2(:,:,0,:)
therm_depth_ar = x1@_FillValue
therm_depth_wc = x2@_FillValue

do ia = 0,ndim(0)-1
do ib = 0,ndim(1)-1
do ie = 0,ndim(3)-1

diff = abs(x1(ia,ib,:,ie) - temp_thermocline1(ia,ib,ie))
i_closest = minind(diff)
; print(i_closest+" "+diff(i_closest))
therm_depth_ar(ia,ib,ie) = depth(i_closest)

diff = abs(x2(ia,ib,:,ie) - temp_thermocline2(ia,ib,ie))
i_closest = minind(diff)
; print(i_closest+" "+diff(i_closest))
therm_depth_wc(ia,ib,ie) = depth(i_closest)
end do 
end do 
end do 

printVarSummary(therm_depth_wc)

;--------------plot-------------------
gsn_define_colormap(wks, "NCV_blu_red") ;"NCV_blu_red" "MPL_BrBG"


res2 = True
res2@gsnDraw = False        ;dont draw
res2@gsnFrame = False        ;dont advance frame
res2@gsnLeftString = ""
res2@gsnRightString = ""
res2@vpWidthF  = 0.6
res2@vpHeightF = 0.3
res3 = res2
sdres = res2
  opt = res2
vcres = res2 
resp      = res2                    

res2@tmXBLabelFontHeightF = 0.022        ; change maj lat tm spacing
res2@tmYLLabelFontHeightF = res2@tmXBLabelFontHeightF
res2@gsnAddCyclic = False
res2@cnFillOn = True;False ;
res2@cnLinesOn = False;True ;
res2@cnLineLabelsOn = False

res2@gsnLeftStringFontHeightF = 0.03
res2@gsnRightStringFontHeightF = res2@gsnLeftStringFontHeightF

res2@tmYROn = False
res2@tmXTOn = False

res2@lbOrientation = "Horizontal"
res2@lbBoxEndCapStyle = "TriangleBothEnds"
res2@lbBoxLinesOn  = False
res2@lbTitleOn        =  True                ; turn on title
res2@lbLabelStride    = 2
res2@lbTitlePosition  = "Right"              ; title position
res2@lbTitleFontHeightF= .02                ; make title smaller
res2@lbTitleDirection = "Across"
res2@lbTitleExtentF   = 0.01 ;Default: 0.15
res2@lbLabelFontHeightF = 0.02  ;Default: 0.02
; res2@pmLabelBarWidthF = 0.05
; res2@pmLabelBarOrthogonalPosF = 0.2 ;default 0.02

res2@lbLabelBarOn = True; False;
res2@cnLevelSelectionMode  = "ManualLevels"

res3@cnFillOn  = False
res3@cnInfoLabelOn            = False
;res3@cnLinesOn = True
res3@cnLineLabelsOn = False ;
; res3@cnLevelFlags = "LineAndLabel" ;control over whether a line and/or a line label is to appear at each contour level
res3@cnLineLabelBackgroundColor = -1
; res3@cnLineLabelInterval = 1
; res3@cnLineLabelPlacementMode = "constant";"Computed" ;
res3@cnLineThicknessF = 4.0
res3@cnLineLabelFontHeightF = 0.02
res3@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
res3@cnLevels = 20; (/15,20,25/) ;(/-6.,-4.,-2.,2.,4.,6.,8.,10./)
; res3@cnLevelSpacingF = 0.1


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
sdres@tmYROn = False

  opt@gsnShadeFillType = "pattern"      ; pattern fill
  ; opt@gsnShadeFillScales = 0.8 ;triggers fatal:Subscript out of range, error in subscript #0
  ; opt@gsnShadeHigh = 17 ;-1          ;
  ; opt@gsnShadeLow =  17 ;6       ;
  opt@cnLineLabelsOn        = False   
  opt@gsnLeftString  = ""
  opt@cnInfoLabelOn  = False
  opt@cnFillDrawOrder = "PostDraw"

; vcres@vcGlyphStyle            = "Fillarrow" ;"CurlyVector";   ; turn on curly vectors
; vcres@vcFillArrowFillColor    = "purple"
; vcres@vcFillArrowEdgeColor    = "white"
; vcres@vcLineArrowColor        = "seagreen1"           ; change vector color
vcres@vcLineArrowThicknessF   = 3.0               ; change vector thickness
vcres@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
vcres@vcMinFracLengthF        = 0.4
vcres@vcMinDistanceF          = 0.025
vcres@vcRefLengthF            = 0.05             ; define length of vec ref

vcres@vcRefAnnoOn             = True
vcres@vcRefAnnoPerimOn          = False

vcres@vcRefAnnoString2          = "" ;uclm_ar@units            ; we don't want the text "reference vector"
vcres@vcRefAnnoOrthogonalPosF = -.6            ; move ref vector up

vcres@lbLabelBarOn = False
vcres@vcRefMagnitudeF         = 10;10.0;0.05;0.3;           ; define vector ref mag

  isea = 0 ;DJF
  iy = 0

  ;gsn_csm_pres_hgt for atmospheric profile
  ;gsn_csm_contour for ocean profile

  res2@cnMinLevelValF        =  -0.1 ;
  res2@cnMaxLevelValF        =   0.1 ;
  res2@cnLevelSpacingF       =  res2@cnMaxLevelValF/10.

  res2@trYReverse                      = True                  ; reverse y-axis
    res2@tiYAxisString = "Level (hPa)" ;"depth (m)"
    res2@gsnPresHgtHeightLabelOn = False
    res2@gsnRightString = "" ;VAR
    res2@lbTitleString    = clm_ar@units                ; title string


    res2@gsnLeftString = "a   SSP2-4.5 (CAM)"
    plot1(0) = gsn_csm_pres_hgt(wks, clm_wc(isea,iy,:,:), res2)
    plota = gsn_csm_vector(wks, uclm_wc(isea,iy,:,:), wclm_wc(isea,iy,:,:), vcres) ;wclm_ar
    overlay(plot1(0),plota)
    res2@gsnLeftString = "b   "+MODEL1
  
    plot1(1) = gsn_csm_pres_hgt(wks, clm_ar(isea,iy,:,:), res2)
    plota = gsn_csm_vector(wks, uclm_ar(isea,iy,:,:), wclm_ar(isea,iy,:,:), vcres) ;wclm_ar
    overlay(plot1(1),plota)
    res2@gsnLeftString = "c   "+MODEL1+" - SSP2-4.5 (CAM)"
    
    plot1(2) = gsn_csm_pres_hgt(wks, clm_wc_dif(isea,iy,:,:), res2)
    plota = gsn_csm_vector(wks, uclm_wc_dif(isea,iy,:,:), wclm_wc_dif(isea,iy,:,:), vcres) ;wclm_ar
    overlay(plot1(2),plota)

    sdres@cnFillColor = "gray38";"lightpink" ;"green"
    sdres@cnFillDotSizeF       = 0.0025            ; increase dot size of contours
    sdres@cnFillOpacityF = 0.5
    opt@gsnShadeLow =  3 ;6       ;
    plota = gsn_csm_pres_hgt(wks, clm_prob(isea,iy,:,:), sdres); 
    plota = gsn_contour_shade(plota,95, -999,opt)   ; Shade contours below 95
    overlay(plot1(2), plota)


  res2@cnMinLevelValF        =  -5.0;1. ;
  res2@cnMaxLevelValF        =   5.0;1. ;
  res2@cnLevelSpacingF       =  res2@cnMaxLevelValF/10.
  res2@lbTitleString    = oclm_ar@units                ; title string

  res2@tmXBLabelFontHeightF = 0.018        ; change maj lat tm spacing
res2@tmYLLabelFontHeightF = res2@tmXBLabelFontHeightF

;   res2@trYReverse                      = False                  ; reverse y-axis
  res2@tiYAxisString = "Depth (m)"
  res2@gsnRightString = "" ;VO
  plot2(0) = gsn_csm_contour(wks, oclm_wc_dif(isea,iy,:,:), res2)
  ; plota = gsn_csm_contour(wks, oclm_wc(isea,iy,:,:), res3) ;oclm_pi
  ; plota = gsn_csm_contour(wks, thermoline_oclm_wc(isea,iy,:,{140:270}), res3) ;oclm_pi
  ; overlay(plot2(0),plota)

  resp@xyLineColor      = "black"                     ; color of lines
  resp@xyLineThicknessF = 4.0                       ; thickness of lines
  ; resp@gsLineLabelString= "test"                    ; adds a line label string
  lon = therm_depth_wc&lon
  dum1 =gsn_csm_xy(wks,lon,therm_depth_wc(isea,iy,:),resp)    ;{140:270}  
  overlay(plot2(0),dum1)

  resp@xyDashPattern = 11
  dum2 =gsn_csm_xy(wks,lon,therm_depth_ar(isea,iy,:),resp)    ;{140:270}  
  overlay(plot2(0),dum2)


  plota = gsn_csm_contour(wks, oclm_prob(isea,iy,:,:), sdres); 
  plota = gsn_contour_shade(plota,95, -999,opt)   ; Shade contours below 95
  overlay(plot2(0), plota)

  res2@cnMinLevelValF        =  0.;
  res2@cnMaxLevelValF        =  30.0;
  res2@cnLevelSpacingF       =  1.0
  delete(res3@cnLevels)
  
  res3@cnLevels = (/15,20,25/) 
  res3@cnLineLabelsOn = True ;

  plot2(1) = gsn_csm_contour(wks, oclm_wc(isea,iy,:,:), res2)
  plota = gsn_csm_contour(wks, oclm_wc(isea,iy,:,:), res3)
  ; plota = gsn_csm_contour(wks, thermoline_oclm_wc(isea,iy,:,:), res3)
  overlay(plot2(1),plota)

  plot2(2) = gsn_csm_contour(wks, oclm_ar(isea,iy,:,:), res2)
  plota = gsn_csm_contour(wks, oclm_ar(isea,iy,:,:), res3)
  ; plota = gsn_csm_contour(wks, thermoline_oclm_ar(isea,iy,:,:), res3)

  overlay(plot2(2),plota)

resk = True
resk@gsnPanelLabelBar   = False                 ; add common colorbar
resk@gsnMaximize = True
resk@gsnPaperOrientation = "portrait"   ; force portrait
resk@lbBoxEndCapStyle = "TriangleBothEnds"
resk@lbOrientation = "Horizontal"
resk@lbBoxLinesOn = False
resk@lbTitlePosition  = "Right"              ; title position
resk@lbTitleFontHeightF= .01                ; make title smaller
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

resk@txString = ""
gsn_panel(wks,plot1,(/3,1/),resk)
gsn_panel(wks,(/plot1(2),plot2(0)/),(/2,1/),resk)
gsn_panel(wks,(/plot2(1),plot2(2)/),(/2,1/),resk)

delete([/res3,res2,vcres/])
; end do
end
