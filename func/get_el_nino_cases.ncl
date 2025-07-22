; load "./func/get_anom_moving_climo.ncl"
load "./func/get_moving_climo.ncl"
load "./func/get_ensemble_mean.ncl"
function get_el_nino_cases(diriw,MODEL_NAME,EXP,ENSN,IND,RMMME,usePI,PiModelExp,EXTREME,ElorLa,yrstrt,yrlast)
; get the yearly index of El Nino years
; it is based on 0.5STD
; If EXTREME (El Nino) is applied
; will use Pr over 5 mm/day (Cai et al. 2014; Stevenson et al. 2020)

; usePI: use PIControl for ENSO metrics?
; PiModelExp: PiControl Model's name and EXP e.g. CESM2_piControl CESM2-WACCM_piControl
; ElorLa: El Nino or La Nina
; ENSN: Ensemble member
; RMMME: remove ensemble mean?

begin
;read index
; diriw = "/global/u2/c/chenxing/data/fuel/" ;"/glade/work/chenxing/fuel/data/"
; IND = "nino3"
  ymstrt = yrstrt*100+2
  ymlast = (yrlast+1)*100+1

  ;CESM2-CAM6_smbbLE2-1231.015_nino3_1850-2100.nc
fils = systemfunc("ls "+diriw+IND+"/"+MODEL_NAME+"_"+EXP+"*"+ENSN+"_"+IND+"_*.nc")

; print("index "+fils)
f   = addfile(fils, "r")  ;multiple files

TIME2=f->time
yyyymm2=cd_calendar(TIME2, -1)
; printMinMax(yyyymm2, True)
ymstrts = ind(yyyymm2.eq.ymstrt)
ymlasts = ind(yyyymm2.eq.ymlast)

nino0  = f->index;(ymstrts:ymlasts)

; ;detrend
; nino = dtrend_n(nino,True,0)

; nmean = 10 ; 30-year climatology
; nyr = dimsizes(nino)/12
; nino_clm = get_moving_climo(nino,nmean,nyr,True)
; nino = nino - nino_clm ;rmAnnCycle1D(nino)


  if(RMMME) then 

  dirik = ""
  files_em = diriw+IND+"/"+MODEL_NAME+"_"+EXP+"*_"+IND+"_*.nc"
  xx_mean = get_ensemble_mean(dirik,files_em,"index",True,20*12+1)
  nino = nino0 - xx_mean
  
  else 
  nino = nino0
  end if 

  if(.not.isStrSubset(IND, "pr" )) then 
    nino = rmAnnCycle1D(nino)
  end if 

;3-mon running mean ;
nino = runave_n_Wrap(nino,3,1,0)

nino_t = nino(ymstrts:ymlasts)

nino_t!0 = "time"
nino1 = month_to_seasonN(nino_t,"DJF")
nino_ano = nino1(0,:);dim_rmvmean_n_Wrap(nino1(0,:),0)
; nino_ano1 = dtrend_msg_n (nino_ano&time,nino_ano,True,False,0) ;dtrend_n no missing value allowed

; moving climatology removed for every 30-year
; nino_ano = get_anom_moving_climo(nino_djf,nmean,nyr,False)

if(usePI) then 

 fils_pi = systemfunc("ls "+diriw+IND+"/"+PiModelExp+"*_"+IND+"_*.nc")
 f   = addfile(fils_pi(0), "r") 
 nino_pi = f->index 
 STD = stddev( month_to_seasonN(nino_pi,"DJF"))
 else 
 STD = stddev(nino_ano)
end if 
; print(STD)

if (ElorLa.eq."ElNino") then

  if(EXTREME) then 
    if(nino0@units.eq."m/s")then 
      nino_ano = nino_ano *1000 * 3600 *24
      nino_ano@units = "mm/day"
    end if 
    iel = ind(nino_ano.ge.5.0)
  else 
    iel = ind(nino_ano.ge.1.0*STD)
  end if 

else if (ElorLa.eq."LaNina") then 

  ; based on Cai et al. 2015
  ; extreme (with |Niño4| > 1.75 s.d.), moderate (1.0 s.d. < |Niño4| < 1.75 s.d.) 
  ; and weak (0.5 s.d. < |Niño4| < 1.0 s.d.) La Niña
  if(IND.eq."nino4") then 

    if(EXTREME) then 
      iel = ind(nino_ano.ge.-1.75*STD.and.nino_ano.le.-1.0*STD)
    else 
      iel = ind(nino_ano.le.-0.5*STD) ;nino_ano.ge.-1.0*STD.and.
    end if 
  end if 
  if(IND.eq."nino34") then 

    iel = ind(nino_ano.le.-1.0*STD)
  end if 

end if 
end if 
; print(iel)

return iel
end
