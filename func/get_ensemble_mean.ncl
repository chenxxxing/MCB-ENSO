function get_ensemble_mean(diri,files,VAR,FILTER,nwgt);,ISMON)
; calculate ensemble mean value of ensembles 
; what ever the dimension of a varible
; just based on the path and files
; but also do low-pass filter to smooth
; diri: direction
; files: files names
; VAR: variable's name

; FILTER: low-pass filter or not
; nwgt: how many year/month low-pass, odd only, should fit to data's unit
;; ISMON: is it a monthly?

begin

; print(diri+files)
; print(VAR)

  ff2 = systemfunc("ls "+diri+files)
  ; print(ff2)
  f3   = addfiles(ff2, "r")
  ListSetType (f3, "join")
  pc  = f3[:]->$VAR$
  pc_mean = dim_avg_n_Wrap(pc, 0)

ndim = dimsizes(pc_mean)
if (FILTER) then 
  ;------------filter----------------------
  fyr   = 8.
  ihp   = 0                             ; low-pass filter: ihp = 0; high-pass ihp = 1; band-pass ihp = 2.
  sigma = 1.0                           ; Lanczos sigma
  nWgt  = nwgt                           ; odd only
  fca   = 1./(fyr*12)
  fcb   = -999.
  wgt  = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )
  pc_mean = wgt_runave_n_Wrap(pc_mean, wgt,  1, 0 )   ;opt < 0 : utilize cyclic conditions
end if 

return pc_mean
end 
