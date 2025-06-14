; originate from plot_mse_xy.ncl

begin
diri = "/glade/work/chenxing/geog/"
dirip = "/glade/u/home/chenxing/geog/"

;from lens_index.ncl
diri3 = "/glade/work/chenxing/geog/"
SEASON = (/"DJF","MAM","JJA","SON" /)

MODELa = (/"CAM","MCB"/);,"CESM2-WACCM","ARISE-SAI-1.5"/);"CAM"/); ,(/"GLENS","GLENS"/); 
EXPa = (/"SSP245","SSP245"/);,"SSP245","SSP245"/);(/"control","feedback"/) ;

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

; Nino: 4.0 ; CLD: 0.4; FSNS: 40. OMEGA500: 0.1; WWV: 1e+16; MSE: 4000
TARGET = "trop1000-850" ;
VALUE = 4000.;

wks         = gsn_open_wks("pdf",dirip+"mse_xy")
plot  = new(30, graphic)
plot1 = new(30, graphic)
plot2 = new(30, graphic)
plot3 = new(30, graphic)
plot4 = new(30, graphic)
plot5 = new(30, graphic)
plot6 = new(30, graphic)
plot7 = new(30, graphic)


;---------read output---------------

nsa = dimsizes(MODELa)


do ia = 0,nsa-1

EXP = EXPa(ia)
MODEL = MODELa(ia)

;from mse_areaavg_index_profile_spatial_output.ncl
fils = systemfunc("ls "+diri3+"cesm/MSE."+TARGET+"/"+MODEL+"_"+EXP+"*_MSE."+TARGET+"_*.nc")
print(fils)
f   = addfiles(fils, "r")  ;multiple files
ListSetType (f, "join")        ; concatenate (=default)
TIME2=f[1]->time
yyyymm2=cd_calendar(TIME2, -1)
printMinMax(yyyymm2, True)

ymstrt = yrstrt*100+2
ymlast = (yrlast+1)*100+1

ymstrts = ind(yyyymm2.eq.ymstrt)
ymlasts = ind(yyyymm2.eq.ymlast)
print(ymstrts+" <--start end--> "+ymlasts)

mse  = f[:]->index(:,ymstrts:ymlasts);(:,:ymlasts);ymstrts
printVarSummary(mse)
mse_mme = dim_avg_n_Wrap(mse,0)

fils = systemfunc("ls "+diri3+"cesm/LSE."+TARGET+"/"+MODEL+"_"+EXP+"*_LSE."+TARGET+"_*.nc")
print(fils)
f   = addfiles(fils, "r")  ;multiple files
ListSetType (f, "join")        ; concatenate (=default)
lse  = f[:]->index(:,ymstrts:ymlasts);(:,:ymlasts);ymstrts
lse_mme = dim_avg_n_Wrap(lse,0)


fils = systemfunc("ls "+diri3+"cesm/DSE."+TARGET+"/"+MODEL+"_"+EXP+"*_DSE."+TARGET+"_*.nc")
print(fils)
f   = addfiles(fils, "r")  ;multiple files
ListSetType (f, "join")        ; concatenate (=default)
dse  = f[:]->index(:,ymstrts:ymlasts);(:,:ymlasts);ymstrts
dse_mme = dim_avg_n_Wrap(dse,0)
printVarSummary(dse_mme)

delete([/fils,TIME2,yyyymm2/])

ndim = dimsizes(mse) 
;=========plot=========================

;*******************************************
; time series (principal component) plot
;*******************************************

  gsn_define_colormap(wks,"seaice_2")
  colors = ispan(2, 17, 1)   ; indices into color table
  colors2 = ispan(4, 17, 2)   ; indices into color table
  colors1 = ispan(10, 18, 1)   ; indices into color table
  line_dash = ispan(1,10,1) ;(/1,2,3,4,0,5 /)
  colors3 = (/"blue","forestgreen","darkgoldenrod1","coral1"/)

; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

  res = True
  res@gsnDraw = False        ;dont draw
  res@gsnFrame = False        ;dont advance frame
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res@vpHeightF = 0.3
  res@vpWidthF  = 0.8

  res@tmXTOn    = False
  res@tmYROn    = False
  ;res@gsnXYBarChart            = True              ; Create bar plot
  ;res@gsnXYBarChartOutlineOnly = True


  res@gsnYRefLine           = 0.0             ; reference line
  ; res@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  ; res@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
  ; res@gsnLeftStringFontHeightF  = 0.03
  ; res@gsnRightStringFontHeightF = 0.03

  res3 = res

  x_axis_mon = fspan(yrstrt, yrlast+1, ndim(1))

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
  res@trXMaxF               = yrlast;yrstrt+2;+10;

;MODEL
res@xyLineThicknessF = 5.0; 0.3
res@gsnRightString = "" ;xx@units

res2 = res

;   res@gsnLeftString = MODEL+" "+EXP
  res2@gsnLeftString = "" ;""+IND+" "+nmyr+"-year moving STD"
  res2@tiYAxisString = ""
  res@xyLineColor = "grey45" ;"grey75"

  res@trYMinF               =  332000.
  res@trYMaxF               =  360000.


  ress2 = res2
  ress = res 

  ; res@trYMinF               =  330000/3.
  ; res@trYMaxF               =  360000/3.

  res@xyLineColor = colors3(ia) ;"grey40"
  res@xyLineThicknessF = 1.0
;   res@xyLineOpacityF = 0.5
  ress@xyLineColor = colors3(ia)
;   plot3(ia*3) = gsn_csm_xy (wks,x_axis_mon, mse ,res) ;
;   plota = gsn_csm_xy (wks,x_axis_mon, mse_mme ,ress)
;   overlay(plot3(ia*3),plota)  

;   plot3(ia*3+1) = gsn_csm_xy (wks,x_axis_mon, lse_mme ,ress)
; ;   overlay(plot3(ia),plota)  

;   plot3(ia*3+2) = gsn_csm_xy (wks,x_axis_mon, dse_mme ,ress)
; ;   overlay(plot3(ia),plota)  

  if(ia.eq.0) then 

  res2@xyLineColor = colors3(0)
  res2@xyDashPattern = line_dash(0)

  plot4(0) = gsn_csm_xy (wks,x_axis_mon, mse_mme ,ress) ;
  
  dif_mse = mse_mme
  dif_lse = lse_mme
  dif_dse = dse_mme

  else 
  ress2@xyLineColor = colors3(ia)
  ress2@xyDashPattern = line_dash(ia)

  plota = gsn_csm_xy (wks,x_axis_mon, mse_mme ,ress)
  overlay(plot4(0),plota)  


  dif_mse = dif_mse - mse_mme
  dif_lse = dif_lse - lse_mme
  dif_dse = dif_dse - dse_mme

  ress@trYMinF               =  0.
  ress@trYMaxF               =  17000.

  ress@xyLineColor = colors3(1)
  plot1(0) = gsn_csm_xy (wks,x_axis_mon, dif_mse ,ress) ;

  ress@xyLineColor = colors3(2)
  plota = gsn_csm_xy (wks,x_axis_mon, dif_lse ,ress)
  overlay(plot1(0),plota)  

  ress@xyLineColor = colors3(3)
  plota = gsn_csm_xy (wks,x_axis_mon, dif_dse ,ress)
  overlay(plot1(0),plota)  

  end if 

;---------shading of STD---------

  ; delete(res@xyDashPattern)
  delete(res@xyLineColors)
  res@xyLineColor     = -1                           ; We don't want the line, so make it trax_axisparent.
  res@gsnXYFillOpacities = 0.2
  res@xyCurveDrawOrder = "PreDraw"
  mmz = mse(0:1,:)

res@gsnLeftString = ""

tmp_std = dim_stddev_n_Wrap(mse,0)

  mmz(0,:) = mse_mme-tmp_std
  mmz(1,:) = mse_mme+tmp_std

  res@gsnXYFillColors = colors3(ia)
  plota  = gsn_csm_xy (wks,(/x_axis_mon/),mmz(0:1,:),res)  ; Create filled XY plot.
  overlay(plot4(0), plota)

delete(mmz)

print(MODEL+" "+EXP+" done!")


delete([/ mse,dse,lse,x_axis_mon/]) ;xa0_annual,
end do


;---------------------------------
; Set up resources for a customized legend.
;
lgres                    = True
lgres@lgLineThicknessF   = 5.0
lgres@lgItemType         = "Lines"        ; show lines only (default)
lgres@lgLabelFontHeightF = .1            ; legend label font thickness
lgres@vpWidthF           = 0.30           ; width of legend (NDC)
lgres@vpHeightF          = 0.10           ; height of legend (NDC)
; lgres@lgPerimThicknessF  = 2.0            ; thicken the box perimeter
lgres@lgPerimOn          = True
; lgres@lgPerimFill = 0
; lgres@lgPerimFillColor = 0
lgres@lgPerimFill            = "SolidFill"      ; Fill legend box w/white
lgres@lgPerimFillColor       = "white"          ; so it masks XY curves

lgres@lgMonoDashIndex = True

lgres@vpWidthF           = 0.25           ; width of legend (NDC)
lgres@lgLabelFontHeightF = .06            ; legend label font thickness
lgres@lgLineColors       = colors3;(:3:-1)
; lgres@lgDashIndexes = line_dash;(:3:-1)

labels4 = (/"SSP2-4.5(CAM)",MODELa(1)/) ;MODELa;+" "+EXP
nitems4 = dimsizes(labels4)                 ; number of legend items
lbid_4 = gsn_create_legend(wks,nitems4,labels4,lgres)

delete(lgres@lgLineColors)
labels3 = (/"DSE  ","LSE     ","MSE     "/);
lgres@lgLineColors       = (/"coral1","darkgoldenrod1","forestgreen"/)
nitems3 = dimsizes(labels3)                 ; number of legend items
lbid_3 = gsn_create_legend(wks,nitems3,labels3,lgres)

; Use gsn_add_annotation to attach this legend to our existing plot.
; This way, if we resize the plot, the legend will stay with the
; plot and be resized automatically.
;
amres                  = True

amres@amJust           = "BottomLeft"    ; Use bottom right corner of box
amres@amParallelPosF   =  -0.44              ; Move legend to right
amres@amOrthogonalPosF =  -0.2              ; Move legend up.


annoid4 = gsn_add_annotation(plot4(0),lbid_4,amres)  ; add legend to plot
annoid3 = gsn_add_annotation(plot1(0),lbid_3,amres)  ; add legend to plot


;------------------------------------------------

resk = True
;resk@txFontHeightF = 0.03
resk@gsnPanelLabelBar   = False                 ; add common colorbar
resk@gsnMaximize = True
resk@gsnPaperOrientation = "portrait"   ; force portrait

; resk@txString = ""+IND+" & their original ensemble mean"
; gsn_panel(wks,plot3,(/2,3/),resk)
gsn_panel(wks,plot4,(/1,1/),resk)
gsn_panel(wks,plot1,(/1,1/),resk)


end
