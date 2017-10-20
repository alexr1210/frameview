#!/usr/bin/ksh

function f_cec_description
{
  # Function Parameters
  typeset   l_managed_system=${1:-"NULL"}
  typeset   l_model=${2:-"NULL"}
  typeset   l_serial=${3:-"NULL"}
  typeset   l_total_CPUAllocation=${4:-"NULL"}
  typeset   l_total_MemAllocation=${5:-"NULL"}
  typeset   l_cpu_free=${6:-"NULL"}
  typeset   l_memory_unused=${7:-"NULL"}
  typeset   l_total_PageTable=${8:-"NULL"}
  typeset   l_lpar_overhead=${9:-"NULL"}
  typeset   l_total_cpu=${10:-"NULL"}
  typeset   l_total_memory=${11:-"NULL"}

  # Function Main
  printf "      <TABLE style='width:850;background: grey; border: thin solid;'>\n"
  printf "        <TR>\n"
  printf "          <TD>\n"
  printf "            <DIV class=classCECname>$l_managed_system</DIV>\n"
  printf "          </TD>\n"
  printf "        </TR>\n"
  printf "        <TR>\n"
  printf "          <TD>\n"
  printf "            <TABLE>\n"
  printf "              <TR>\n"
  printf "                <TD>\n"
  printf "                  <TABLE>\n"
  printf "                    <TR>\n"
  printf "                      <TD>\n"
  printf "                        <DIV class=classtext>Model: </DIV>\n"
  printf "                      </TD>\n"
  printf "                      <TD>\n"
  printf "                        <DIV class=classtext> ${l_model} </DIV>\n"
  printf "                      </TD>\n"
  printf "                    </TR>\n"
  printf "                    <TR>\n"
  printf "                      <TD>\n"
  printf "                        <DIV class=classtext>CEC Serial No: </DIV>\n"
  printf "                      </TD>\n"
  printf "                      <TD>\n"
  printf "                        <DIV class=classtext> ${l_serial} </DIV>\n"
  printf "                      </TD>\n"
  printf "                    </TR>\n"
  printf "                  </TABLE>\n"
  printf "                  <TABLE>\n"
  printf "                    <TR>\n"
  printf "                      <TD>\n"
  printf "                        <DIV class=classtext></DIV>\n"
  printf "                      </TD>\n"
  printf "                      <TD>\n"
  printf "                        <DIV class=classheading>Processors</DIV>\n"
  printf "                      </TD>\n"
  printf "                      <TD>\n"
  printf "                        <DIV class=classheading>Memory (MBytes)</DIV>\n"
  printf "                      </TD>\n"
  printf "                    </TR>\n"
  printf "                    <TR>\n"
  printf "                      <TD>\n"
  printf "                        <DIV class=classtext>Allocated</DIV>\n"
  printf "                      </TD>\n"
  printf "                      <TD>\n"
  printf "                        <DIV class=classtext>${total_cpu}</DIV>\n"
  printf "                      </TD>\n"
  printf "                      <TD>\n"
  printf "                        <DIV class=classtext>${total_memory}</DIV>\n"
  printf "                      </TD>\n"
  printf "                    </TR>\n"
  printf "                    <TR>\n"
  printf "                  </TABLE>\n"
  printf "                </TD>"
  printf "                <TD>\n"
  printf "                  <TABLE>\n"
  printf "                    <TR>\n"
  printf "                      <TD>\n"
  printf "                        <DIV class=classtext>Key:</DIV>\n"
  printf "                      </TD>\n"
  printf "                    </TR>\n"

  for string in Empty:white PCI_10/100/1000Mbps_Ethernet_UTP_2-port:lightblue PCI_1Gbps_Ethernet_UTP:thistle PCI_10/100Mbps_Ethernet_w/_IPSec:lightgreen Other_Mass_Storage_Controller:pink Storage_controller:khaki Universal_Serial_Bus_UHC_Spec:MediumPurple Fibre_Channel_Serial_Bus:turquoise Fibre_Channel-2_PORT,_TAPE/DISK_CONTROLLER:lightsalmon SCSI_bus_controller:tan SAS_RAID_Controller:tomato
  do
    bgcolour=${string##*:} 
    description=`printf "${string%%:*}\n" | tr "_" " "`
    printf "                    <TR>\n"
    printf "                      <TD  style='height:10px;width:10px;border:thin solid;border-color:black;background-color:${bgcolour}'>\n"
    printf "                      </TD>\n"
    printf "                      <TD>\n"
    printf "                        <DIV class=classtext>${description}</DIV>\n"
    printf "                      </TD>\n"
    printf "                    </TR>\n"
  done
  printf "                  </TABLE>\n"
  printf "                </TD>\n"
  printf "              </TR>\n"
  printf "            </TABLE>\n"

}

function slots
{

typeset l_hmcname=${1:-NULL}
typeset l_managed_system=${2:-NULL}
typeset l_HMCVersion=${3:-NULL}

cat - <<EOF
<TABLE style='cellpadding:0;cellpadding:0'>
  <TR>
    <TD>
      <TABLE>
        <TR>
EOF

    ssh -i ~/.ssh/id_rsa_mrss mrss@$l_hmcname "lshwres -m $l_managed_system -r io --rsubtype slot -F unit_phys_loc:phys_loc:description:lpar_name" |  sort -t: -k1,1 -k2,2n| tr " " "_" | tr ":" " " | while read drawer_id slot_id slot_type assigned_to
    do
      [ $assigned_to = "null" ] && assigned_to="unalloc"
      if [ "${drawer_id}" != "${previous_drawer_id}" ]
      then
        printf "        </TR>\n"
        printf "      </TABLE>\n"
        printf "    </TD>\n"
        printf "  </TR>\n"
        printf "  <TR>\n"
        printf "    <TD>\n"
        printf "      <TABLE>\n"
        printf "          <CAPTION align=center>\n"
        printf "            <DIV class=classheading>${drawer_id}</DIV>\n"
        printf "          </CAPTION>\n"
        printf "        <TR>\n"
        previous_drawer_id=${drawer_id}
      fi
      printf "          <TD>\n"
      printf "            <TABLE style='border:thin solid;border-color:black;vertical-align:top;cellspacing:0;cellpadding:0;'>\n"
      printf "              <TR>\n"
      printf "                <TD align=center >\n"
      printf "                  <DIV class=classtext>${slot_id}</DIV>\n"
      printf "                </TD>\n"
      printf "              </TR>\n"
      printf "              <TR>\n"

      case ${slot_type} in
        "Empty")                    		bgcolour="white" ;;
        "PCI_10/100/1000Mbps_Ethernet_UTP_2-port")      		bgcolour="lightblue" ;;
        "PCI_1Gbps_Ethernet_UTP")       	bgcolour="thistle" ;;
        "PCI_10/100Mbps_Ethernet_w/_IPSec")     bgcolour="lightgreen" ;;
        "Other_Mass_Storage_Controller")        bgcolour="pink" ;;
        "Storage_controller")       		bgcolour="khaki" ;;
        "Universal_Serial_Bus_UHC_Spec")        bgcolour="MediumPurple" ;;
        "Fibre_Channel_Serial_Bus") 		bgcolour="turquoise" ;;
        "Fibre_Channel-2_PORT,_TAPE/DISK_CONTROLLER")              	 	bgcolour="lightsalmon" ;;
        "SCSI_bus_controller")      		bgcolour="tan" ;;
        "SAS_RAID_Controller")   		bgcolour="tomato" ;;
        *)   					bgcolour="grey" ;;
      esac
      printf "                <TD style='width:20;height:120px;background-color:${bgcolour}'>\n"
      printf "                  <DIV class=verticaltext>${assigned_to}</DIV>\n"
      printf "                </TD>\n"
      printf "              </TR>\n"
      printf "            </TABLE>\n"
      printf "          </TD>\n"
    done
  printf "        </TR>"
  printf "      </TABLE>"
  printf "    </TABLE>\n"
}

function html_report
{

cat - <<EOF 
<HTML>
<HEAD>
<STYLE>
A:link { color:#000000; font-size: 14pt; }
A:visited { color:#000000; font-size: 14pt; }
A:active { color:#000000; font-size: 14pt; }
A:hover { color:red; font-size: 14pt; }
<!--
 .classHMC   
 {
   font-size:10.0pt;
   font-weight:bold;
   font-family:Arial;
   white-space: nowrap; 
  }
 .classCECname
 {
   font-size:11.0pt;
   font-weight:bold;
   font-family:Arial;
   white-space: nowrap; 
  }
 .classhostname   
 {
   font-size:10.0pt;
   font-weight:bold;
   font-family:Arial;
   white-space: nowrap; 
  }
 .classtext   
 {
   font-size:9.0pt;
   font-family:Arial;
  }
 .classheading
 {
   font-size:9.0pt;
   font-family:Arial;
   text-decoration: underline;
 }
 .verticaltext 
 {
   font-size:10.0pt;
   font-family:Arial;
   writing-mode: tb-rl;
   filter: flipv fliph;
   white-space: nowrap;
  }


</STYLE>
</HEAD>
<BODY>
<a href="http://huxp0021.unix.marksandspencer.com/frameview/">go back</a>
<br>
<br>
EOF

printf "<TABLE>\n"
echo '<TABLE width=100% cellspacing="0">'
echo '<TR height="45" bgcolor="#ffffff">'
echo '<TD width=80%><IMG SRC="mands08.gif"></TD>'
echo '<TD width=20%>'
echo '<TABLE><TR><TD COLSPAN=2 align=center><FONT face=arial size=1 color=#676767></FONT></TD></TR>'
echo '<TR>'
echo '<TD align=center></TD>'
echo '<TD align=center></TD>'
echo '</TR>'
echo '</TABLE>'


#for HMCname in hilp0001 10.146.5.7
for HMCname in hilp0001 hilp0005 hilp8001 hilp8004 hild0002
do
  [ $HMCname = "hilp0001" ] && LOCATION="Stockley Park Datacentre Frame Configuration @ " || LOCATION="Swindon Datacentre Frame Configuration @ "
  printf "  <TR>\n"
  printf "    <TD style='border:none'>\n"
  printf "      <DIV class=classHMC> ${LOCATION}`date +\"%d/%m/%Y %H:%M:%S\"`</DIV>\n"
  HMCVersion=`ssh -i ~/.ssh/id_rsa_mrss mrss@${HMCname} lshmc -V | grep Release | awk '{print $2}'`

    for managed_system in `ssh -i ~/.ssh/id_rsa_mrss mrss@${HMCname} lssyscfg -r sys -F name | sort | grep "$1"`
    do

      ssh -i ~/.ssh/id_rsa_mrss mrss@${HMCname} "lssyscfg -r sys -m $managed_system -F type_model:serial_num" | awk -F: '{print $1,$2}' | read model serial
      integer total_cpu=$(ssh -i ~/.ssh/id_rsa_mrss mrss@${HMCname} "lshwres -r proc -m $managed_system --level sys -F configurable_sys_proc_units")

      ssh -i ~/.ssh/id_rsa_mrss mrss@${HMCname} "lshwres -r mem -m $managed_system --level sys -F configurable_sys_mem sys_firmware_mem" | read total_memory lpar_overhead


      ssh -i ~/.ssh/id_rsa_mrss mrss@${HMCname} "lshwres -m $managed_system -r proc --level sys -F curr_avail_sys_proc_units" |  read cpu_free

      count_1=0
      total_CPUAllocation=0
      ssh -i ~/.ssh/id_rsa_mrss mrss@${HMCname} "lshwres -m $managed_system -r proc --level lpar -F lpar_name curr_procs" |grep -v "-" | while read PName CPUNo
      do
         let count_1=${count_1}+1
         PartitionName[${count_1}]=${PName}
         Nodename[${count_1}]=${PName}
         Hostname[${count_1}]=`echo ${Nodename[${count_1}]} | cut -d"_" -f1`
         CPUAllocation[${count_1}]=${CPUNo}
         let total_CPUAllocation=${total_CPUAllocation}+${CPUNo}
      done
      
      total_MemAllocation=0
      count_2=0
      ssh -i ~/.ssh/id_rsa_mrss mrss@${HMCname} "lshwres -m $managed_system -r mem --level lpar -F lpar_name curr_mem" | grep -v "-" | while read PName Mem 
      do
         let count_2=${count_2}+1
         MemAllocation[${count_2}]=${Mem}
         let total_MemAllocation=${total_MemAllocation}+${Mem}

      done
      total_PageTable="-"
      let memory_unused=${total_memory}-${lpar_overhead}-${total_MemAllocation}

      f_cec_description ${managed_system} ${model} ${serial} ${total_CPUAllocation} ${total_MemAllocation} ${cpu_free} ${memory_unused} ${total_PageTable} ${lpar_overhead} ${total_cpu} ${total_memory}

      slots ${HMCname} ${managed_system} ${HMCVersion}

      printf "          </TD>\n"
      printf "        </TR>\n"
      printf "      </TABLE>\n"
      printf "      <BR>\n"
    done  
    printf "    </TD>\n"
    printf "  </TR>\n"
done
printf "</TABLE>\n"
printf "</BODY>\n"
printf "</HTML>\n"

}

function initialise
{
DAY=$(date +%d-%m-%Y)
LOGFILE_BLUE=/usr/local/apache/htdocs/frameview/slots_blue_${DAY}.html
LOGFILE_RED=/usr/local/apache/htdocs/frameview/slots_red_${DAY}.html
LOGFILE_SILVER=/usr/local/apache/htdocs/frameview/slots_silver_${DAY}.html
LOGFILE_GOLD=/usr/local/apache/htdocs/frameview/slots_gold_${DAY}.html
LOGFILE_GREEN=/usr/local/apache/htdocs/frameview/slots_green_${DAY}.html
LOGFILE_PINK=/usr/local/apache/htdocs/frameview/slots_pink_${DAY}.html
LOGFILE_PURPLE=/usr/local/apache/htdocs/frameview/slots_purple_${DAY}.html
LOGFILE_BLACK=/usr/local/apache/htdocs/frameview/slots_black_${DAY}.html
LOGFILE_GREY=/usr/local/apache/htdocs/frameview/slots_grey_${DAY}.html
/usr/bin/rm -f /usr/local/apache/htdocs/frameview/slots_*_current.html
/usr/bin/ln -s $LOGFILE_BLUE /usr/local/apache/htdocs/frameview/slots_blue_current.html
/usr/bin/ln -s $LOGFILE_RED /usr/local/apache/htdocs/frameview/slots_red_current.html
/usr/bin/ln -s $LOGFILE_SILVER /usr/local/apache/htdocs/frameview/slots_silver_current.html
/usr/bin/ln -s $LOGFILE_GOLD /usr/local/apache/htdocs/frameview/slots_gold_current.html
/usr/bin/ln -s $LOGFILE_GREEN /usr/local/apache/htdocs/frameview/slots_green_current.html
/usr/bin/ln -s $LOGFILE_PINK /usr/local/apache/htdocs/frameview/slots_pink_current.html
/usr/bin/ln -s $LOGFILE_PURPLE /usr/local/apache/htdocs/frameview/slots_purple_current.html
/usr/bin/ln -s $LOGFILE_BLACK /usr/local/apache/htdocs/frameview/slots_black_current.html
/usr/bin/ln -s $LOGFILE_GREY /usr/local/apache/htdocs/frameview/slots_grey_current.html
}

initialise 

# html_report
html_report "06EA33R" > $LOGFILE_BLUE
html_report "06EA31R" > $LOGFILE_RED
html_report "838B4B4" > $LOGFILE_SILVER
html_report "838B4E4" > $LOGFILE_GOLD
html_report "8395BDD" > $LOGFILE_GREEN
html_report "838B4A4" > $LOGFILE_PINK
html_report "10DC08C" > $LOGFILE_PURPLE
html_report "06F07F4" > $LOGFILE_BLACK
html_report "100BEDP" > $LOGFILE_GREY

