#!/bin/sh
#
#
#########################################################################
#                                                                       #
# Name:         new_frameview.sh                                        #
#                                                                       #
# Started:      29 Mar 2016                                             #
#                                                                       #
# Completed:    29 Mar 2016                                             #
#                                                                       #
# Arguments:    <NONE>                                                  #
#                                                                       #
# Purpose:      Generates Frameview html and HMC Scan Output            #
#		http://huxp0021.unix.marksandspencer.com/frameview2	# 
#									# 
#                                                                       #
# Author:       Alex Ring alex.ring@marks-and-spencers.com              #
#                                                                       #
# Inputs:       /usr/local/cluster/bin/common_variables                 #
#                                                                       #
# Outputs:      STDOUT:  <None>                                         #
#               STDERR:  <None>                                         #
#               FILES: 	/usr/local/apache/htdocs/frameview		#
#			/usr/local/apache/htdocs/HMC-Scanner            #
#                                                                       #
# Version:      @(#)1.0.0 Original>                                     #
#                                                                       #
# Notes:                                                                #
#                                                                       #
# --------------------------------------------------------------------- #
#                                                                       #
# Change-Date:                                                          #
# Change-Version:                                                       #
# Change-Reason:                                                        #
# Change-Author:                                                        #
#                                                                       #
#########################################################################

# Enable debugging
set -x

#Variables

SPHMCUSER="frameview"
SPHMCADDR="10.144.5.183"
#SPHMCADDR="10.144.5.182"
SWHMCUSER="frameview"
SWHMCADDR="10.146.5.50"
PREFIX="/home/frameview"
CODOUTFILE="enterprise_pool_info"
HTMLFILE="${PREFIX}/index.html"
TARGETFILE="/var/www/frameview/index.html"
HMCSCAN="/home/frameview/HMC-Scanner/hmcScanner.ksh"
HMCSCANOPT="/var/www/HMC-Scanner"
FRAMES="Blue-9119-MHE-SN21C30C7_R3 Red-9119-MHE-SN21C3097_R4 Gold-9119-MHE-SN21C30A7_R1 Silver-9119-MHE-SN21C30B7_R2 Grey-8408-E8E-SN21447FW_R4 Purple-8408-E8E-SN214480W_R2 Pink-9119-MHE-SN21C30F7_R1 Green-9119-MHE-SN21C3107_R2 Orange-9119-MHE-SN21C30E7_R3"
CMDS="lshwres_-r_proc_--level_sys_-m lshwres_-r_mem_--level_sys_-m lssyscfg_-r_lpar_-F__-m lshwres_-r_proc_--level_lpar_-F_-m lshwres_-r_mem_--level_lpar_-F_-m lslic_-t_sys_-m "


populate_p8() {
#set -x
	L_NAME="`echo $2 | tr '#' ' '`"
	LINE1="`cat ${PREFIX}/$1_lpar | grep \"^${L_NAME},\"`"
	L_SYSTEM="`echo $LINE1 | cut -f3 -d,`"
	L_STATE="`echo $LINE1 | cut -f4 -d,`"
	L_PMODE="`echo $LINE1 | cut -f30 -d,`"
	L_VERSION="`echo $LINE1 | cut -f6 -d,`"
	test "$L_STATE" == "" && L_STATE="Not Activated"
	LINE2="`cat ${PREFIX}/$1_proclpar | grep \"^${L_NAME},\"`"
	LINE3="`cat ${PREFIX}/$1_memlpar | grep \"^${L_NAME},\"`"
	L_CPUMIN="`echo $LINE2 | cut -f6 -d,`"
	L_CPUDES="`echo $LINE2 | cut -f7 -d,`"
	L_CPUMAX="`echo $LINE2 | cut -f8 -d,`"
	L_CPUMAX="`echo $LINE2 | cut -f8 -d,`"
	L_CPURUN="`echo $LINE2 | cut -f25 -d,`"
	L_MINVP="`echo $LINE2 | cut -f9 -d,`"
	L_DESVP="`echo $LINE2 | cut -f10 -d,`"
	L_MAXVP="`echo $LINE2 | cut -f11 -d,`"
	L_RUNVP="`echo $LINE2 | cut -f26 -d,`"
	L_POOL="`echo $LINE2 | cut -f4 -d,`"
	L_CAPPING="`echo $LINE2 | cut -f12 -d,`"
	L_WEIGHT="`echo $LINE2 | cut -f27 -d,`"
	L_MEMMIN="`echo $LINE3 | cut -f3 -d,`"
	L_MEMDES="`echo $LINE3 | cut -f4 -d,`"
	L_MEMMAX="`echo $LINE3 | cut -f5 -d,`"
	L_MEMRUN="`echo $LINE3 | cut -f10 -d,`"
	L_MEMEXP="`echo $LINE3 | cut -f26 -d,`"
	echo "
							<td class='lpar`test \"$L_STATE\" == Running || echo 2`'>
								(`test $L_SYSTEM == aixlinux && echo AIX || echo VIOS` -- `test \"$L_STATE\" == Running && echo \<font color=#27BB27\>Activated\</font\> || echo \<font color=red\>Not\ Activated\</font\>`)<br>
								<a href="http://hlxp0m0008.unix.marksandspencer.com/cfg2html/$L_NAME/$L_NAME.html"><font size="2"><b>$L_NAME</b><br></font></a>
								$L_VERSION<br>
								<table>
									<tr height='2px'></tr>
									<tr>
										<td class='ent'>
											<center><u>PUs</u></center>
											min = ${L_CPUMIN}<br>
											des = ${L_CPUDES}<br>
											max = ${L_CPUMAX}<br>
											run = ${L_CPURUN}<br><br>
											<center><u>VPs</u></center>
											min = ${L_MINVP}<br>
											des = ${L_DESVP}<br>
											max = ${L_MAXVP}<br>
											run = ${L_RUNVP}<br><br>
										</td>
										<td width='10px'>
										</td>
										<td class='ent'>
											<center><u>Memory</u></center>
											min = `echo \"scale=1;${L_MEMMIN}/1024\" | bc`<br>
											des = `echo \"scale=1;${L_MEMDES}/1024\" | bc`<br>
											max = `echo \"scale=1;${L_MEMMAX}/1024\" | bc`<br>
											run = `echo \"scale=1;${L_MEMRUN}/1024\" | bc`<br>
											ame = `echo \"scale=2;${L_MEMEXP}\" | bc`<br>
											exp = `echo \"scale=1;${L_MEMRUN}*${L_MEMEXP}/1024\" | bc`<br><br>
											<center><u>Processor Mode</u></center>
											mode = ${L_PMODE}<br>
											`test ${L_CAPPING} == share_idle_procs && echo "share" || echo ${L_CAPPING}ped`<br>
											weight = ${L_WEIGHT}<br>
											pool = ${L_POOL}<br>
										</td>
									</tr>
								</table>
							</td>" >> $HTMLFILE
	return 0
}

sys_populate() {
	S_CPUCONF="`cat ${PREFIX}/$1_procsys | cut -f1 -d, | cut -f2 -d= | cut -f1 -d\.`"
	S_CPUAVAIL="`cat ${PREFIX}/$1_procsys | cut -f2 -d, | cut -f2 -d=`"
	S_CPUINST="`cat ${PREFIX}/$1_procsys | cut -f4 -d, | cut -f2 -d= | cut -f1 -d\.`"
	S_MEMCONF="`cat ${PREFIX}/$1_memsys | cut -f1 -d, | cut -f2 -d=`"
	S_MEMAVAIL="`cat ${PREFIX}/$1_memsys | cut -f2 -d, | cut -f2 -d=`"
	S_MEMINST="`cat ${PREFIX}/$1_memsys | cut -f4 -d, | cut -f2 -d=`"
	S_MEMAVAIL2="`echo \"scale=2;${S_MEMAVAIL}/1024\" | bc`"
	S_LPARS="`wc -l ${PREFIX}/$1_lpar | awk '{ print $1 }'`"
	S_FWARE1="`cat ${PREFIX}/$1_sys | cut -f4 -d, | cut -f2 -d=`"
	S_FWARE2="`cat ${PREFIX}/$1_sys | cut -f5 -d, | cut -f2 -d=`"
	S_CODPROC1="`cat ${PREFIX}/$1_lscodpool | cut -f5 -d, | cut -f2 -d=`"
	S_CODPROC2="`cat ${PREFIX}/$1_lscodpool | cut -f4 -d, | cut -f2 -d=`"
	S_CODMEM1="`cat ${PREFIX}/$1_lscodpool | cut -f10 -d, | cut -f2 -d=`"
	S_CODMEM2="`cat ${PREFIX}/$1_lscodpool | cut -f9 -d, | cut -f2 -d=`"

	test "`echo $S_MEMAVAIL2 | cut -c1`" == "." && S_MEMAVAIL="0$S_MEMAVAIL2" || S_MEMAVAIL=$S_MEMAVAIL2
	echo "
						<tr>
							<td align='center' colspan='2'>
                                                                Activated firmware = ${S_FWARE2} ${S_FWARE1} 
                                                        </td>
						<tr>

							<td align='right'>
								installed CPUs = ${S_CPUINST}&nbsp;&nbsp;&nbsp;<br>
								activated CPUs = ${S_CPUCONF}&nbsp;&nbsp;&nbsp;<br>
								static cores = ${S_CODPROC1}&nbsp;&nbsp;&nbsp;<br>
								mobile cores = ${S_CODPROC2}&nbsp;&nbsp;&nbsp;<br>
								CPUs in shared pool = ${S_CPUAVAIL}&nbsp;&nbsp;&nbsp;<br>
							</td>
							<td align='right'>
								installed memory = `echo \"scale=2;${S_MEMINST}/1024\" | bc` GB<br>
								activated memory = `echo \"scale=2;${S_MEMCONF}/1024\" | bc` GB<br>
								static memory = `echo \"scale=2;${S_CODMEM1}/1024\" | bc` GB<br>
								mobile memory = `echo \"scale=2;${S_CODMEM2}/1024\" | bc` GB<br>
								available memory =  ${S_MEMAVAIL} GB<br>
							</td>
						</tr>
						<tr>
							<td align='center' colspan='2'>
								number of LPARs = ${S_LPARS} (`grep Running ${PREFIX}/$1_lpar | wc -l | awk '{ print $1 }'` Activated)
							</td>
						</td>" >> $HTMLFILE
}

# get data from HMC
#set -x

# Get Shared Pool info
 ssh -i ~/.ssh/id_rsa_frameview ${SPHMCUSER}@${SPHMCADDR} "lscodpool --level sys --id 0369" > ${PREFIX}/$CODOUTFILE

for i in $FRAMES; do
	POOLOUTFILE="`echo $i | cut -f1 -d\-`_``lscodpool"
	grep $i ${PREFIX}/$CODOUTFILE > ${PREFIX}/$POOLOUTFILE
done

for i in $FRAMES; do
	for j in $CMDS; do
		OUTFILE="`echo $i | cut -f1 -d\-`_`echo $j | cut -f3,5 -d_ | tr -d '_'`"
		case "$i" in
			"Red-9119-MHE-SN21C3097_R4")
				ssh -i ~/.ssh/id_rsa_frameview ${SPHMCUSER}@${SPHMCADDR} \
				"`echo $j | tr '_' ' '` $i" > ${PREFIX}/$OUTFILE;;
			"Blue-9119-MHE-SN21C30C7_R3")
				ssh -i ~/.ssh/id_rsa_frameview ${SPHMCUSER}@${SPHMCADDR} \
				"`echo $j | tr '_' ' '` $i" > ${PREFIX}/$OUTFILE;;
			"Gold-9119-MHE-SN21C30A7_R1")
				ssh -i ~/.ssh/id_rsa_frameview ${SPHMCUSER}@${SPHMCADDR} \
				"`echo $j | tr '_' ' '` $i" > ${PREFIX}/$OUTFILE;;
			"Silver-9119-MHE-SN21C30B7_R2")
				ssh -i ~/.ssh/id_rsa_frameview ${SPHMCUSER}@${SPHMCADDR} \
				"`echo $j | tr '_' ' '` $i" > ${PREFIX}/$OUTFILE;;
			"Grey-8408-E8E-SN21447FW_R4")
				ssh -i ~/.ssh/id_rsa_frameview ${SPHMCUSER}@${SPHMCADDR} \
				"`echo $j | tr '_' ' '` $i" > ${PREFIX}/$OUTFILE;;
			"Purple-8408-E8E-SN214480W_R2")
				ssh -i ~/.ssh/id_rsa_frameview ${SPHMCUSER}@${SPHMCADDR} \
				"`echo $j | tr '_' ' '` $i" > ${PREFIX}/$OUTFILE;;
			"Pink-9119-MHE-SN21C30F7_R1")
				ssh -i ~/.ssh/id_rsa_frameview ${SWHMCUSER}@${SWHMCADDR} \
				"`echo $j | tr '_' ' '` $i" > ${PREFIX}/$OUTFILE;;
			"Orange-9119-MHE-SN21C30E7_R3")
				ssh -i ~/.ssh/id_rsa_frameview ${SWHMCUSER}@${SWHMCADDR} \
				"`echo $j | tr '_' ' '` $i" > ${PREFIX}/$OUTFILE;;
			"Green-9119-MHE-SN21C3107_R2")
				ssh -i ~/.ssh/id_rsa_frameview ${SWHMCUSER}@${SWHMCADDR} \
				"`echo $j | tr '_' ' '` $i" > ${PREFIX}/$OUTFILE;;
		esac
	done
done

RED_LPARS=$(cat ${PREFIX}/Red_proclpar | sort -nt "," -k2,2 | cut -f1 -d, | tr ' ' '#')
BLUE_LPARS=$(cat ${PREFIX}/Blue_proclpar | sort -nt "," -k2,2 | cut -f1 -d, | tr ' ' '#')
GREEN_LPARS=$(cat ${PREFIX}/Green_proclpar | sort -nt "," -k2,2 | cut -f1 -d, | tr ' ' '#')
GOLD_LPARS=$(cat ${PREFIX}/Gold_proclpar | sort -nt "," -k2,2 | cut -f1 -d, | tr ' ' '#')
SILVER_LPARS=$(cat ${PREFIX}/Silver_proclpar | sort -nt "," -k2,2 | cut -f1 -d, | tr ' ' '#')
PINK_LPARS=$(cat ${PREFIX}/Pink_proclpar | sort -nt "," -k2,2 | cut -f1 -d, | tr ' ' '#')
PURPLE_LPARS=$(cat ${PREFIX}/Purple_proclpar | sort -nt "," -k2,2 | cut -f1 -d, | tr ' ' '#')
GREY_LPARS=$(cat ${PREFIX}/Grey_proclpar | sort -nt "," -k2,2 | cut -f1 -d, | tr ' ' '#')
ORANGE_LPARS=$(cat ${PREFIX}/Orange_proclpar | sort -nt "," -k2,2 | cut -f1 -d, | tr ' ' '#')

>$HTMLFILE
cat ${PREFIX}/h_head ${PREFIX}/h_redhead | sed -e "s/DATE/`date`/g" >> $HTMLFILE
sys_populate Red
alt=0
for i in $RED_LPARS; do
	test $alt -eq 0 && echo -e "\t\t\t\t\t\t<tr>" >> $HTMLFILE
	populate_p8 Red $i || continue
	if [ $alt -eq 1 ]; then echo -e "\t\t\t\t\t\t</tr>" >> $HTMLFILE; alt=0; else alt=1; fi
done
cat ${PREFIX}/h_redtail ${PREFIX}/h_bluehead >> $HTMLFILE
sys_populate Blue
alt=0
for i in $BLUE_LPARS; do
	test $alt -eq 0 && echo -e "\t\t\t\t\t\t<tr>" >> $HTMLFILE
	populate_p8 Blue $i || continue
	if [ $alt -eq 1 ]; then echo -e "\t\t\t\t\t\t</tr>" >> $HTMLFILE; alt=0; else alt=1; fi
done
cat ${PREFIX}/h_bluetail ${PREFIX}/h_goldhead >> $HTMLFILE
sys_populate Gold
alt=0
for i in $GOLD_LPARS; do
	test $alt -eq 0 && echo -e "\t\t\t\t\t\t<tr>" >> $HTMLFILE
	populate_p8 Gold $i || continue
	if [ $alt -eq 1 ]; then echo -e "\t\t\t\t\t\t</tr>" >> $HTMLFILE; alt=0; else alt=1; fi
done
cat ${PREFIX}/h_goldtail ${PREFIX}/h_silverhead >> $HTMLFILE
sys_populate Silver
alt=0
for i in $SILVER_LPARS; do
	test $alt -eq 0 && echo -e "\t\t\t\t\t\t<tr>" >> $HTMLFILE
	populate_p8 Silver $i || continue
        if [ $alt -eq 1 ]; then echo -e "\t\t\t\t\t\t</tr>" >> $HTMLFILE; alt=0; else alt=1; fi
done
cat ${PREFIX}/h_silvertail ${PREFIX}/h_purplehead >> $HTMLFILE
sys_populate Purple
alt=0
for i in $PURPLE_LPARS; do
	test $alt -eq 0 && echo -e "\t\t\t\t\t\t<tr>" >> $HTMLFILE
	populate_p8 Purple $i || continue
	if [ $alt -eq 1 ]; then echo -e "\t\t\t\t\t\t</tr>" >> $HTMLFILE; alt=0; else alt=1; fi
done
cat ${PREFIX}/h_purpletail ${PREFIX}/h_greyhead >> $HTMLFILE
sys_populate Grey
alt=0
for i in $GREY_LPARS; do
	test $alt -eq 0 && echo -e "\t\t\t\t\t\t<tr>" >> $HTMLFILE
	populate_p8 Grey $i || continue
	if [ $alt -eq 1 ]; then echo -e "\t\t\t\t\t\t</tr>" >> $HTMLFILE; alt=0; else alt=1; fi
done
cat ${PREFIX}/h_greytail ${PREFIX}/h_greenhead >> $HTMLFILE
sys_populate Green 
alt=0
for i in $GREEN_LPARS; do
	test $alt -eq 0 && echo -e "\t\t\t\t\t\t<tr>" >> $HTMLFILE
	populate_p8 Green $i || continue
	if [ $alt -eq 1 ]; then echo -e "\t\t\t\t\t\t</tr>" >> $HTMLFILE; alt=0; else alt=1; fi
done
cat ${PREFIX}/h_greentail ${PREFIX}/h_pinkhead >> $HTMLFILE
sys_populate Pink
alt=0
for i in $PINK_LPARS; do
	test $alt -eq 0 && echo -e "\t\t\t\t\t\t<tr>" >> $HTMLFILE
	populate_p8 Pink $i || continue
	if [ $alt -eq 1 ]; then echo -e "\t\t\t\t\t\t</tr>" >> $HTMLFILE; alt=0; else alt=1; fi
done
cat ${PREFIX}/h_pinktail ${PREFIX}/h_orangehead >> $HTMLFILE
sys_populate Orange
alt=0
for i in $ORANGE_LPARS; do
        test $alt -eq 0 && echo -e "\t\t\t\t\t\t<tr>" >> $HTMLFILE
        populate_p8 Orange $i || continue
        if [ $alt -eq 1 ]; then echo -e "\t\t\t\t\t\t</tr>" >> $HTMLFILE; alt=0; else alt=1; fi
done
cat ${PREFIX}/h_orangetail ${PREFIX}/h_tail >> $HTMLFILE

cp $HTMLFILE $TARGETFILE

# HMC Scanner Collection
for i in $FRAMES; do
                case "$i" in
                        "Red-9119-MHE-SN21C3097_R4")
                                ${HMCSCAN} ${SPHMCADDR} ${SPHMCUSER} -key ~/.ssh/id_rsa_frameview -html -htmldir ${HMCSCANOPT}/$i -m $i ;;
			"Blue-9119-MHE-SN21C30C7_R3")
                                ${HMCSCAN} ${SPHMCADDR} ${SPHMCUSER} -key ~/.ssh/id_rsa_frameview -html -htmldir ${HMCSCANOPT}/$i -m $i ;;
                        "Gold-9119-MHE-SN21C30A7_R1")
                                ${HMCSCAN} ${SPHMCADDR} ${SPHMCUSER} -key ~/.ssh/id_rsa_frameview -html -htmldir ${HMCSCANOPT}/$i -m $i ;;
                        "Silver-9119-MHE-SN21C30B7_R2")
                                ${HMCSCAN} ${SPHMCADDR} ${SPHMCUSER} -key ~/.ssh/id_rsa_frameview -html -htmldir ${HMCSCANOPT}/$i -m $i ;;
                        "Grey-8408-E8E-SN21447FW_R4")
                                ${HMCSCAN} ${SPHMCADDR} ${SPHMCUSER} -key ~/.ssh/id_rsa_frameview -html -htmldir ${HMCSCANOPT}/$i -m $i ;;
                        "Purple-8408-E8E-SN214480W_R2")
                                ${HMCSCAN} ${SPHMCADDR} ${SPHMCUSER} -key ~/.ssh/id_rsa_frameview -html -htmldir ${HMCSCANOPT}/$i -m $i ;;
                        "Pink-9119-MHE-SN21C30F7_R1")
                                ${HMCSCAN} ${SWHMCADDR} ${SWHMCUSER} -key ~/.ssh/id_rsa_frameview -html -htmldir ${HMCSCANOPT}/$i -m $i ;;
                        "Orange-9119-MHE-SN21C30E7_R3")
                                ${HMCSCAN} ${SWHMCADDR} ${SWHMCUSER} -key ~/.ssh/id_rsa_frameview -html -htmldir ${HMCSCANOPT}/$i -m $i ;;
                        "Green-9119-MHE-SN21C3107_R2")
                                ${HMCSCAN} ${SWHMCADDR} ${SWHMCUSER} -key ~/.ssh/id_rsa_frameview -html -htmldir ${HMCSCANOPT}/$i -m $i ;;
                esac
done

# Cleanup HMC Scanner xls files
find ${PREFIX} -type f -name "*.xls" -exec rm {} \;

