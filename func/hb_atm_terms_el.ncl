load "./func/get_el_nino_cases.ncl"
function hb_atm_terms_el(diriw,dia,IND,MODEL_NAME,EXP,ENSN,RMMME_EL,usePI,PiModelExp,EXTREME,ElorLa,time,yrstrt,yrlast);NLAT,SLAT,WLON,ELON,
; with atmosphere grid distribution
; return El cases * terms * time * lat * lon
begin

; ; Area Box
; ; maybe check 5-10 for meridional changes as well?
; NLAT0 =  10.
; SLAT0 = -10.
;
; NLAT =  5.
; SLAT = -5.
; WLON = 90.
; ELON = 300.
;
; yrstrt0 = 1920; start year
; yrlast0 = 2099; end year

; yrstrt = 1950;1920; start year
; yrlast = 2005;2099; end year
ymstrt = yrstrt*100+2
ymlast = (yrlast+1)*100+1

; MODEL_NAME = (/"CESM1-CAM5"/);,"CanESM2","CSIRO-Mk3-6-0",\;"EC-EARTH",
  ; "GFDL-CM3","GFDL-ESM2M","MPI-ESM" /)


; TIME2=f1[0]->time
yyyymm2=cd_calendar(time, -1)
printMinMax(yyyymm2, True)

; if (MODEL_NAME.eq."CESM1-CAM5") then
;   ymstrt = yrstrt*100+2
;   ymlast = (yrlast+1)*100+1
; else
;   ymstrt = yrstrt*100+1
;   ymlast = yrlast*100+12
; end if

ymstrts = ind(yyyymm2.eq.ymstrt)
ymlasts = ind(yyyymm2.eq.ymlast)
print(ymstrts+" <--start end--> "+ymlasts)

dia_z = dia(:,ymstrts:ymlasts,:,:);dim_avg_n_Wrap(dia(:,ymstrts:ymlasts,{SLAT:NLAT},{WLON:ELON}),2)

;---------------composite----------------------
nyear1 = 1
nyear2 = 1
nyra = nyear1+nyear2
nmon = nyra*12


cases = get_el_nino_cases(diriw,MODEL_NAME,EXP,ENSN,IND,RMMME_EL,usePI,PiModelExp,EXTREME,ElorLa,yrstrt,yrlast)
nel = dimsizes(cases)
ndim = dimsizes(dia_z)

hb_el = new((/ndim(0),nel,nmon,ndim(2),ndim(3)/), typeof(dia))
do ie =0,nel-1
  if(.not.ismissing(cases(0))) then
  if(cases(ie).ne.0)then
    kk = (cases(ie)-nyear1)*12
    ll = kk+12*nyra-1
    print(kk+"-"+ll)
    hb_el(:,ie,:,:,:) = dia_z(:,kk:ll,:,:)
  end if
  end if

end do
copy_VarCoords(dia(:,0,:,:),hb_el(:,0,0,:,:))
hb_el!0 = "terms"
hb_el!1 = "cases"
printVarSummary(hb_el)

return hb_el
end
