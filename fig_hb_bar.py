import numpy as np
import matplotlib.pyplot as plt
import xarray as xr

diri = "/glade/work/chenxing/geog/output/"

ElorLa = "ElNino" # El ElNinoino or La Nina? "ElNino" "LaNina"
TAG = "OWNSTD" #"extreme"# "" # Extreme El Nino?
MODEL1_SSP = "CESM2-WACCM_SSP245"#"CAM_SSP245" # "GLENS_control" #"CESM2-WACCM_SSP245"
MODEL1_GE = "ARISE-SAI-1.5_SSP245"#"MCB_SSP245" # "GLENS_feedback" #"ARISE-SAI-1.5_SSP245"
MODEL2_SSP = "CAM_SSP245"#"CAM_SSP245" # "GLENS_control" #"CESM2-WACCM_SSP245"
MODEL2_GE = "MCB_SSP245"#"MCB_SSP245" # "GLENS_feedback" #"ARISE-SAI-1.5_SSP245"
yrs = 2040 #2036 #2020+1 #
yrl = 2069 #2054-1 #

##----------- area average ---------------------
# Nino 1+2 (0-10S, 90W-80W), Nino 3 (5N-5S, 150W-90W),
# Nino 3.4/ONI (5N-5S, 170W-120W) and Nino 4 (5N-5S, 160E-150W)
NLAT = str( 5     )
SLAT = str(-5     )
WLON = str(360-170)#210 ) #160 # 210#150
ELON = str(360-120)#360-90 ) #360-150 # 360-90#90

# from cesm_hb4_plot_bar.ncl
# ARISE-SAI-1.5_SSP245_hbvarsbar_OWNSTDElNino_2040-2069.nc
nc1= xr.open_dataset(diri+MODEL1_SSP+'_hbtermsbar_'+TAG+ElorLa+'_'+NLAT+'-'+SLAT+'_'+WLON+'-'+ELON+'_'+str(yrs)+'-'+str(yrl)+'.nc')
nc2= xr.open_dataset(diri+MODEL1_GE+'_hbtermsbar_'+TAG+ElorLa+'_'+NLAT+'-'+SLAT+'_'+WLON+'-'+ELON+'_'+str(yrs)+'-'+str(yrl)+'.nc')
nc3= xr.open_dataset(diri+MODEL2_SSP+'_hbtermsbar_'+TAG+ElorLa+'_'+NLAT+'-'+SLAT+'_'+WLON+'-'+ELON+'_'+str(yrs)+'-'+str(yrl)+'.nc')
nc4= xr.open_dataset(diri+MODEL2_GE+'_hbtermsbar_'+TAG+ElorLa+'_'+NLAT+'-'+SLAT+'_'+WLON+'-'+ELON+'_'+str(yrs)+'-'+str(yrl)+'.nc')
hb_ssp1  = nc1['com_bar']
hb_ge1   = nc2['com_bar']
hb_ssp2  = nc3['com_bar']
hb_ge2   = nc4['com_bar']
std_ssp1  = nc1['std_bar']
std_ge1   = nc2['std_bar']
std_ssp2  = nc3['std_bar']
std_ge2   = nc4['std_bar']
print(hb_ge1)
print(hb_ssp2)

with open(diri+"hbterms_name.txt") as f:
    hb_terms_name = f.readlines()
with open(diri+"hbvars_name.txt") as f:
    hb_vars_name = f.readlines()

print(hb_terms_name)
print(hb_vars_name)

# ;read computed terms from heatbudget2_comput.ncl
TERM_NAME = ["dTadt","Sum","ucdTadx","vcdTady","uadTcdx",\
          "vadTcdy","uadTadx","vadTady","clm_uadTadx","clm_vadTady",\
          "wadTcdz","wcdTadz","wadTadz","SW","LW",\
          "SH","LH","Residuals"]
VAR_NAME = ["tc_mld","ta_mld","uc_mld","ua_mld","vc_mld","va_mld",\
"wc_e","wa_e","dTcdx","dTadx","dTcdy","dTady","(tc_mld-tc_sub)/hmxl","(ta_mld-ta_sub)/hmxl"]
SEASON = ["DJF","MAM","JJA","SON"]

# Component index
# 0. Temperature tendency dTadt: 0
# 1. Advection due to mean zonal and meridional currents ucdTadx+vcdTady: 2,3
# 2. Zonal advection uadTcdx: 4
# 3. Meridional advection vadTcdx: 5
# 4. Thermocline feedback wcdTadz: 11
# 5. Ekman feedback wadTcdz: 10
# 6. Flux: 13, 14, 15, 16
# 7. Nonlinear terms: 6,7,12 + 8,9

LABELS = ['Temperature tendency','Advection due to mean currents','Zonal anomalous advection','Meridional anomalous advection','Thermocline feedback','Ekman feedback','Flux','Nonlinearity']
# COLORS = ['red','green','blue','orange','purple','yellow','Lime','silver']

# set width of bar
barWidth = 1./12.
fig = plt.subplots(figsize =(12, 8))

num_bars = len(LABELS)
num_seasons = 4
num_years = 2

# Set position of bar on X axis
# br1 = np.arange(num_seasons)
# br2 = [x + barWidth for x in br1]
# br3 = [x + barWidth for x in br2]
# br4 = [x + barWidth for x in br3]
# br5 = [x + barWidth for x in br4]
# br6 = [x + barWidth for x in br5]
# br = [br1,br2,br3,br4,br5,br6]
# print(br)

br = []

for i in range(num_bars):
    br_temp = np.arange(num_seasons) + i * barWidth
    br.append(br_temp)

br = np.array(br)

##############
fig = plt.figure(figsize=(15,10))
# Adjust spacing between subplots and titles
# plt.subplots_adjust(hspace=0.5)
plt.style.use('seaborn-paper')

# iyr = 0

TITLE = ['   DJF','   MAM','   JJA',"   SON"]
YEAR = ['-1','0']
CAP_LABEL = ['a','b','c','d','e','f']

# for isea in range(4):
for im, ik in enumerate((0,2, 6, 1)):

    plt.subplot(2,2,im+1)
    # Make the plot
    # plt.figure(figsize=(10,5))
    for it in range(num_bars):
        plt.bar(br[it], 
                [
                    hb_ssp1[ik,it], #isea * num_years + iyr
                    hb_ge1[ik,it],
                    hb_ssp2[ik,it],
                    hb_ge2[ik,it]
                ],
                yerr=[
                2*std_ssp1[ik,it],
                2*std_ge1[ik,it],
                2*std_ssp2[ik,it],
                2*std_ge2[ik,it]
                ],
                # color=COLORS[it], 
                width=barWidth,
                edgecolor='grey', 
                label=LABELS[it],
                capsize=3 
                )
    # plt.bar(br2, [hb_ssp1[0,isea+iyr*4],hb_ge1[0,isea+iyr*4],hb_ssp2[0,isea+iyr*4],hb_ge2[0,isea+iyr*4]], color ='g', width = barWidth,
    # 		edgecolor ='grey', label ='ECE')
    # plt.bar(br3, CSE, color ='b', width = barWidth,
    # 		edgecolor ='grey', label ='CSE')

    # Adding Xticks
    # plt.xlabel(SEASON[isea]+' before the El Nino peak phase ('+SLAT+'-'+NLAT+', '+WLON+'-'+ELON+')', fontweight ='bold', fontsize = 11)
    plt.ylabel('degC/mon', fontweight ='bold', fontsize = 13)
    plt.xticks([r + barWidth for r in range(num_seasons)],
            # [MODEL1_SSP, MODEL1_GE, MODEL2_SSP, MODEL2_GE])
            # ["CESM2-WACCM6", "ARISE-SAI", "CESM2-CAM6", "MCB"], fontsize = 11)
            ["SSP2-4.5(WACCM)", "SAI", "SSP2-4.5(CAM)", "MCB-abrupt"], fontsize = 13)
    plt.ylim(-0.6,0.45)#-0.11, 0.45)
    plt.yticks(fontsize = 13)
    plt.title(CAP_LABEL[im]+' '+TITLE[(ik//2)%4]+'('+YEAR[ik%2]+')', loc = 'left',fontweight ='bold', fontsize = 13)

    
plt.subplot(2, 2, 1)  # legend goes to the first one
plt.legend(fontsize = 11)
plt.show()
plt.savefig('fig_sup_hb_bar.pdf',  dpi=300)#bbox_inches='tight',

plt.clf()
isea = 2
iyr = 0

# plt.subplot(2,2,1)
# Make the plot
plt.figure(figsize=(10,5))
plt.style.use('seaborn-paper')

for it in range(num_bars):
    plt.bar(br[it], 
            [
                hb_ssp1[isea * num_years + iyr,it],
                hb_ge1[isea * num_years + iyr,it],
                hb_ssp2[isea * num_years + iyr,it],
                hb_ge2[isea * num_years + iyr,it]
            ],
            yerr=[
                2*std_ssp1[isea * num_years + iyr,it],
                2*std_ge1[isea * num_years + iyr,it],
                2*std_ssp2[isea * num_years + iyr,it],
                2*std_ge2[isea * num_years + iyr,it]
            ],
            # color=COLORS[it], 
            width=barWidth,
            edgecolor='grey', 
            label=LABELS[it],
            capsize=3 
            )

# Adding Xticks
plt.xlabel(SEASON[isea]+' before the El Nino peak phase ('+SLAT+'-'+NLAT+', '+WLON+'-'+ELON+')', fontweight ='bold', fontsize = 11)
plt.ylabel('degC/mon', fontweight ='bold', fontsize = 15)
plt.xticks([r + barWidth for r in range(num_seasons)],
        # [MODEL1_SSP, MODEL1_GE, MODEL2_SSP, MODEL2_GE])
        # ["CESM2-WACCM6", "ARISE-SAI", "CESM2-CAM6", "MCB"], fontsize = 11)
        ["SSP2-4.5 (WACCM)", "SAI", "SSP2-4.5 (CAM)", "MCB-abrupt"], fontsize = 15)
plt.yticks(fontsize = 15)

plt.ylim(-0.2,0.55)#-0.11, 0.45)

# plt.subplot(2, 2, 1)  # legend goes to the first one
plt.legend(fontsize = 11)
plt.show()
plt.savefig('fig4_hb_bar.pdf',  dpi=300)#bbox_inches='tight',

# ### 
# fig, axs = plt.subplots(2, 2, figsize=(10, 10))  # Create a 9x2 grid of subplots
# fig.suptitle('Heat budget of El Nino in each year')
# for isea in range(4):
#     for it in range(num_bars):
#         row = isea // 2  # Calculate the row index
#         col = isea % 2   # Calculate the column index
#         axs[row, col].bar(br[it], [hb_ssp1[isea + iyr * num_seasons,it],
#                         hb_ge1[isea + iyr * num_seasons,it],
#                         hb_ssp2[isea + iyr * num_seasons,it],
#                         hb_ge2[isea + iyr * num_seasons,it]],
#                 color=COLORS[it], width=barWidth,
#                 edgecolor='grey', label=LABELS[it])
#         axs[row, col].set_xlabel(SEASON[isea]+' before the El Nino peak phase ('+SLAT+'-'+NLAT+', '+WLON+'-'+ELON+')', fontweight ='bold', fontsize = 15)
#         axs[row, col].set_ylabel('degC/mon', fontweight ='bold', fontsize = 15)
#         axs[row, col].set_xticklabels(["SAI_Reference", "ARISE-SAI", "MCB_Reference", "MCB"], fontsize=17)
#         # axs[row, col].set_xticks([r + barWidth for r in range(num_seasons)],
#         #         ["SAI_Reference", "ARISE-SAI", "MCB_Reference", "MCB"])#, fontsize = 17)
#         # axs[row, col].set_legend(fontsize = 17)

# fig.savefig('allseason_hb.pdf')
