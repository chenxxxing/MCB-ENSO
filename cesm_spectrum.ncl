load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
; load "./wavelet_nino.ncl"
begin

diri = "/glade/work/chenxing/geog/"
dirip = "/glade/u/home/chenxing/geog/"
diri3 = "/glade/work/chenxing/geog/"

wks         = gsn_open_wks("pdf",dirip+"spectrum_index") 
plot = new(12, graphic)
text = new(12, graphic)

SEASON = (/"DJF","MAM","JJA","SON" /)

yrstrt = (/ 2040, 2040, 2040, 2040, 2040,440,440/) ;start year of datasets
yrlast = (/ 2069, 2069, 2069, 2069, 2069,469,469/) ;end year of datasets

MODELa = (/"CAM_SSP245","MCB_SSP245","MCB-feed_MCB-feedback-1DOF","MCB-feed_MCB-feedforward-1DOF","MCB-reduceseeds_SSP245-MCB-80PCT-60PCT"/);,"CESM2-WACCM_SSP245","ARISE-SAI-1.5_SSP245","CESM2_piControl","CESM2-WACCM_piControl" /)
; MODELa = (/"MCB-difseeds_SSP245-CMIP6-MCB-025PCT","MCB-difseeds_SSP245-CMIP6-MCB-050PCT","MCB-difseeds_SSP245-CMIP6-MCB-075PCT","MCB-difseeds_SSP245-CMIP6-MCB-125PCT"/)
nmo = dimsizes(MODELa)

IND = "nino34" ;"U10.nino4"
RMANNCYCLE = True 

;--------------MODEL---------------------------------
do im = 0,nmo-1


MODEL = MODELa(im)

fils = systemfunc("ls "+diri3+"cesm/"+IND+"/"+MODEL+".*_"+IND+"_*.nc")
print(fils)
f   = addfiles(fils, "r")  ;multiple files
ListSetType (f, "join")        ; concatenate (=default)
TIME2=f[0]->time
yyyymm=cd_calendar(TIME2, -1)
printMinMax(yyyymm, True)

ymstrt = yrstrt(im)*100+2
ymlast = (yrlast(im)+1)*100+1

ymstrts = ind(yyyymm.eq.ymstrt)
ymlasts = ind(yyyymm.eq.ymlast)
print(ymstrts+" <--start end--> "+ymlasts)

xx  = f[:]->index(:,ymstrts:ymlasts)
printVarSummary(xx)

delete([/fils,TIME2,yyyymm/])

print("MODEL "+MODEL)
;************************************************
; set function arguments
;************************************************
  d   = 0    ; detrending opt: 0=>remove mean 1=>remove mean + detrend
  sm  = 3   ; smooth: should be at least 3 and odd
  pct = 0.10 ; percent taper: (0.0 <= pct <= 1.0) 0.10 common. 
  val1 = 0.05;.95
  val2 = 0.95;.99

;************************************************
; calculate spectrum
;************************************************
II = xx
ndima = dimsizes(II)

  nmissy = ind(.not.ismissing(II(0,:)))
  sdof0 = specx_anal(II(0,nmissy),d,sm,pct) 
  splt0 = specx_ci(sdof0,val1,val2)  ;4*44

SA = sdof0@frq
SB = splt0 ;@spcx
;N = 0
SA = 0
SB = 0
printVarSummary(SA)
printVarSummary(SB)
ndim = dimsizes(splt0)

  
fq = conform_dims((/ndima(0),dimsizes(SA)/), SA, (/1/));72
sp = conform_dims((/ndima(0),ndim(0),ndim(1)/), splt0, (/1,2/))
fq@_FillValue = 9.96921e+36
fq = 9.96921e+36
sp@_FillValue = 9.96921e+36
sp = 9.96921e+36

  do ia=0,ndima(0)-1
    ;   ;;;; rm annual cycle or not?
    if(RMANNCYCLE)then 
        II(ia,:) = rmAnnCycle1D(II(ia,:))
    ;   ;;;;  
    end if 

    spectra_mvf = False
      nmissy = ind(.not.ismissing(II(ia,:)))
      if(.not.all(ismissing(II(ia,:))))then 
        sdof = specx_anal(II(ia,nmissy),d,sm,pct)   ; pc1 is standardized
        splt1 = specx_ci(sdof,val1,val2)
        fq(ia,:) = sdof@frq
        sp(ia,:,:) = splt1 ;@spcx
       delete([/splt1,sdof/])
      end if
      delete([/nmissy/])
  end do 

printVarSummary(fq)
printVarSummary(sp)
delete([/II, SA,SB, splt0, sdof0/])

fq_avg = dim_avg_n_Wrap(fq, 0)
sp_avg = dim_avg_n_Wrap(sp, 0)

; ;output
; fon=diri+"obs_spectrum_pdv_index.nc";
; system("rm -f "+fon)
; fo=addfile(fon,"c")
; fo->fq = fq_avg
; fo->sp = sp_avg
; exit

;========================================================================

     pres = True
     pres@vpXF = 0.07
     pres@vpHeightF = 0.5
     pres@vpWidthF  = 0.8
     pres@trYMinF = 0.
     pres@trYMaxF = 120.;80;180.
     pres@trXMinF = 0.0
     pres@trXMaxF = 0.08; 0.2; 
     pres@tiYAxisString = "Power"              ; yaxis
     pres@gsnFrame      = False
     pres@gsnDraw       = False
  
     pres@tmXBLabelDeltaF = -.8
     pres@tmXTLabelDeltaF = -.8
     pres@pmLegendDisplayMode    = "Never"
     ; pres@xyLineThicknesses   = (/3.5,2.,1.,1./) 
     pres@xyDashPatterns      = 0; (/0,0,0,0/)
     pres@tmYROn = False
     pres@tmXTLabelsOn = True
     pres@tmXUseBottom = False
     pres@tmXTOn = True
     pres@tmXTMode   = "Explicit"  
     pres@tmXTValues = (/"0.17","0.08","0.04","0.02","0.01","0.0017"/);,"0.005",".0416",".0556",".0832"
     pres@tmXTLabels = (/"0.5","1","2","4","7","50"/) ;,"15" ,"2","1.5","1"         
     pres@tmXTLabelFontHeightF = 0.03
     pres@tmXBLabelFontHeightF = pres@tmXTLabelFontHeightF
     pres@tmYLLabelFontHeightF = pres@tmXTLabelFontHeightF
     pres@tiYAxisString = "Power (degC~S~2~N~ / cycles mo~S~-1~N~)" ;"Power (~S~o~N~C~S~2~N~ / cycles mo~S~-1~N~)" ;"Variance (" ;             ; yaxis
     pres@tiXAxisString = "Frequency (month~S~-1~N~)";(cycles mo~S~-1~N~)"
     pres@tiMainString = ""
     pres@gsnCenterString = "Period (years)"
     pres@txFontHeightF = 0.022 ;0.015
     pres@xyLineLabelFontHeightF = 0.022
     pres@tiXAxisFontHeightF = 0.04
     pres@tiYAxisFontHeightF = pres@tiXAxisFontHeightF
     pres@tiMainFontHeightF = pres@tiXAxisFontHeightF
     ; pres@gsnRightStringOrthogonalPosF = -0.115
     pres@gsnLeftStringOrthogonalPosF = 0.15
     
     pres@tiMainOn = False
     pres@gsnLeftStringFontHeightF =    pres@tiYAxisFontHeightF
     pres@gsnCenterStringFontHeightF =    pres@tiYAxisFontHeightF
     pres@gsnRightStringFontHeightF  =    pres@tiYAxisFontHeightF - 0.005
     pres@gsnRightString = "";ensemble(ie)
    ;  pres@gsnLeftString = MODEL

        ;each ensemble
        ; pres@trYMaxF = max(sp(:,0,:))*1.1
        pres@xyLineThicknessF   = 0.5
        ; plot(im) = gsn_csm_xy(wks,fq,sp(:,0,:),pres)

        colors3 = (/"blue","forestgreen","darkgoldenrod1","coral1","brown","purple"/)

        ;ensemble mean
        pres@xyLabelMode = "custom"
        pres@xyExplicitLabels = (/"","","",val2*100+"%"/);val1*100+"%"
        ; pres@xyLineColors        = (/"foreground","red","Transparent","green"/)      
        pres@xyLineLabelFontColors = pres@xyLineColors 
        pres@xyLineThicknesses   = (/4.,1.5,1.5,1.5/) 
        ; plot1 = gsn_csm_xy(wks,fq_avg,sp_avg(0,:),pres)
        ; overlay(plot(im), plot1)

        ; pres@xyLineColors   = (/colors3(im),"red","Transparent","green"/)        
        pres@xyLineColors   = (/colors3(im),"Transparent","Transparent",colors3(im)/);
        if(im.eq.1)then
        delete(pres@tiYAxisString)
        pres@tmYLOn = False
        end if

        plot(im) = gsn_csm_xy(wks,fq_avg,sp_avg,pres) ;sp_avg(0,:)

        if(im.ge.2) then  
        plota = gsn_csm_xy(wks,fq_avg,sp_avg,pres)
        overlay(plot(1),plota)
        end if 

  
;---------shading of STD---------
gsn_define_colormap(wks,"seaice_2")
colors2 = ispan(4, 17, 2)   ; indices into color table

  res = True
  res@gsnDraw = False        ;dont draw
  res@gsnFrame = False        ;dont advance frame
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res@xyLineColor     = -1                           ; We don't want the line, so make it trax_axisparent.
  res@gsnXYFillOpacities = 0.3
  res@xyCurveDrawOrder = "PreDraw"
  mmz = (/sp_avg(0,:),sp_avg(0,:)/)


com_std2 = dim_stddev_n_Wrap(sp(:,0,:),0)

  mmz(0,:) = sp_avg(0,:)-com_std2
  mmz(1,:) = sp_avg(0,:)+com_std2

  res@gsnXYFillColors = colors2(im) ;"grey40"
  plota  = gsn_csm_xy (wks,fq_avg,mmz(0:1,:),res)  ; Create filled XY plot.
  if(im.gt.1) then  
  overlay(plot(1), plota)
  else
  overlay(plot(im), plota)
  end if 

  delete(mmz)


        delete([/fq,sp/])

delete([/xx, pres, fq_avg,sp_avg /])

end do 


;---------------------------------
; Set up resources for a customized legend.
;
lgres                    = True
lgres@lgLineThicknessF   = 5.0
lgres@lgItemType         = "Lines"        ; show lines only (default)
lgres@vpHeightF          = 0.3           ; height of legend (NDC)
; lgres@lgPerimThicknessF  = 2.0            ; thicken the box perimeter
lgres@lgPerimOn          = False
; lgres@lgPerimFill = 0
; lgres@lgPerimFillColor = 0
lgres@lgPerimFill            = "SolidFill"      ; Fill legend box w/white
lgres@lgPerimFillColor       = "white"          ; so it masks XY curves

lgres@lgMonoDashIndex = True

lgres@vpWidthF           = 0.4           ; width of legend (NDC)
lgres@lgLabelFontHeightF = .06            ; legend label font thickness
lgres@lgLineColors       = colors3(1:4:-1);(:3:-1)

labels2 = (/"MCB-tail20%","MCB-FF","MCB-FB+FF","MCB-abrupt"/) ;MODELa(1) ; MODELa(3)
; labels2 = (/"MCB-abrupt","MCB-FB+FF","MCB-FF","MCB-tail20%"/) ;MODELa(1) ; MODELa(3)
nitems2 = dimsizes(labels2)                 ; number of legend items
lbid_2 = gsn_create_legend(wks,nitems2,labels2,lgres)

; Use gsn_add_annotation to attach this legend to our existing plot.
; This way, if we resize the plot, the legend will stay with the
; plot and be resized automatically.
;
amres                  = True

amres@amJust           = "TopRight"    ; Use bottom right corner of box
amres@amParallelPosF   =  0.44              ; Move legend to right
amres@amOrthogonalPosF =  -0.2              ; Move legend down.


annoid2 = gsn_add_annotation(plot(1),lbid_2,amres)  ; add legend to plot


  panres = True
  panres@gsnMaximize = True
  panres@gsnPaperOrientation = "portrait"
  panres@gsnPanelYWhiteSpacePercent = 3.0
  panres@pmLabelBarHeightF = 0.05
  panres@pmLabelBarWidthF = 0.55
  panres@lbTitleOn = False
  panres@lbBoxLineColor = "gray70"
  panres@lbLabelFontHeightF = 0.013
     panres@txFontHeightF = 0.02
     panres@gsnPanelBottom = 0.05

  panres@txString = ""; "power spectrum of PC"
  gsn_panel(wks,plot,(/1,2/),panres)


end 