#! /bin/sh

# getVersion.sh
# The scripts is used to show the ASE version details of the specified dir
##
#
# Variables:
# -h|-help
#     Optional command. Input value: help.
#     Test will display the usage of the scirpt
#
# -r|-relasedir
#     Mandatory command. Input value: release dir of the ASE.
#
# -o|-outputdir
#     Mandatory command. Input value: dir used to store the output file of this script in lam.
#
# -p|-platform
#    Mandatory command. Input value: platform of installed ASE,such as lam,sol. 
#
# -m|-machine
#    Mandatory command. Input value: The machine whose platform is same with the installed machine.
#
###############################################################################################################

PROGNAME=`basename $0`
USAGE="Usage: $PROGNAME -r <release dir> -o <output dir> -p <ase platform> -m <machine>
"

platform="ase platform options:
hpia | Hpia | HPIA | hpia64
ibm | i51 | aix | ibmaix64
lps | ibmplinux64 | ibmplinux
lam | linuxamd64 | linuxamd
linux32
sol | sunsparc64 | sunsparc
sunsparc32
solam | sunx64
nt32 | nt386
nt64 | winx64
"

rls_dir="release dir options:
the ase release dir.
Especially, the release dir of windows should be like 'D:/157sp122_nt64/nt64_05_14_00.44.57'
"

out_dir="output dir options:
your working dir which is used to save files such as versionid.out versionid.temp
"

machine="machine options:
which is the same platform with ase
"

result="After executed successfully you will see the versionid.out in your output dir and receive an email.
"

examples="Examples:
/usr/u/huijuanf/GetVersion_tool/getversion.sh -r /remote/aseqa_archive1/golden_releases/ase/160sp01smp/sol -o /usr/u/huijuanf/test_0610 -p sol -m solstrs1
"
USAGE=`echo -e "${USAGE}\n${platform}\n${rls_dir}\n${out_dir}\n${machine}\n${result}\n${examples}"`
if [ $# -lt 8 ]
then
    echo "$USAGE"
    exit 1
fi

EXITCODE=0
imgDIR=""
destDIR=""
instPlat=""

while [ "$1" != "" -a "$EXITCODE" -eq 0 ]
do
    case "$1" in
    -h|-help)  echo $USAGE
               exit;;

    -r|-rlsdir) shift
                  rlsdir=$1

                  if [ "$rlsdir" = "" ] ; then
                      echo "Please input the release directory."
                      exit 1
                  #elif [ ! -d $rlsdir ] ; then
                  #    echo "Please input the correct release directory."
                  #    exit 1
                  else
                      echo "#########################################################################"
                      echo "release dir:             $rlsdir"
                  fi;;

    -o|-outdir) shift
                  outdir=$1    
                  if [ "$outdir" = "" ] ; then
                      echo "Please input the destination dir where you want to store the output files."
                      exit 1
                  elif [ ! -d $outdir ] ; then
                      echo "Outout dir:         $outdir"
                      echo "                            no $outdir, will create it"
                      mkdir_succeed=`mkdir $outdir`
                      R_mkdir=$?
                      if [ $R_mkdir -ne 0 ] ; then  
                          echo "Please input the correct directory of the output dir."
                          exit 1
                      else
                          chmod -R 777 $outdir
                          echo "                            dir is created"
                      fi
                  else
                      chmod -R 777 $outdir 
                      echo "Output dir:         $outdir"
                  fi;;

    -p|-platfrom) shift
                  instPlat=$1;;

    -m|-machine) shift
                  HOST=$1;;

    esac
    shift
done

case $instPlat in
    hpia | Hpia | HPIA | hpia64)
        PLAT="hpia"
        ;;
    ibm | i51 | aix | ibmaix64)
        PLAT="ibm"
        ;;
    lps | ibmplinux64 | ibmplinux)
        PLAT="lps"
        ;;
    lam | linuxamd64 | linuxamd)
        PLAT="lam"
        ;;
    linux32)
        PLAT="linux32"
        ;;
    sol | sunsparc64 | sunsparc)
        PLAT="sol"
        ;;
    sunsparc32)
        PLAT="sunsparc32"
        ;;
    solam | sunx64)
        PLAT="solam"
        ;;
    nt32 | nt386)
        PLAT="nt32"
        ;;
    nt64 | winx64)
        PLAT="nt64"
        ;;
    *)
        echo "The platform cannot be known. Please input the correct platform."
        echo "$USAGE"
        exit;;
esac


SCRIPTDIR="/usr/u/huijuanf/GetVersion_tool"
export SCRIPTDIR
BINDIR="/usr/u/huijuanf/GetVersion_tool/bin"
export BINDIR

source "$SCRIPTDIR/prepare.sh"


echo "#########################################################################"
        echo "GET THE VERSION DETAILS OF ASE"
        if [ $PLAT = "nt32" -o $PLAT = "nt64" ]; then
            rlsdir=${rlsdir//:/}
            winrlsdir="/cygdrive/$rlsdir"
            getverErr_path="/cygdrive/D"
            putFile2NT $HOST "$SCRIPTDIR/prepare.sh" "$winrlsdir"
            sleep 2
            sshCmd2NT $HOST "rm $getverErr_path/getverErr.out
                             if [ ! -d $winrlsdir ];then
                                 echo \"Please input the correct ASE release directory!\" >> $getverErr_path/getverErr.out
                                 exit 1
                             fi"
            rm $outdir/getverErr.out
            getFile5NT $HOST "$getverErr_path/getverErr.out" "$outdir"
            if [ -f "$outdir/getverErr.out" ];then
                echo "Please input the correct ASE release directory!"
                exit
            fi
            sshCmd2NT $HOST "source $winrlsdir/prepare.sh @$HOST;getNTVersionDetails \"$winrlsdir\" \"$PLAT\""
            sleep 2
            sshCmd2NT $HOST "if [ -f "$winrlsdir/versionid.sh" ] ; then
                                 rm $winrlsdir/versionid.out
                                 sh $winrlsdir/versionid.sh >> $winrlsdir/versionid.out &
                             fi" 0
            echo "get $winrlsdir/versionid.out from NT machine"
            sleep 10
           # getFile5NT $HOST "$getverErr_path/getverErr.out" "$outdir"
            getFile5NT $HOST "$winrlsdir/versionid.out" "$outdir"
        else 
            getUnixVerDetail "$rlsdir" "$outdir" "$PLAT" "$HOST"
            if [ -f "$outdir/versionid.sh" ] ; then
                rm $outdir/versionid.temp
                sh $outdir/versionid.sh >> $outdir/versionid.temp
                rm $outdir/versionid.out
                sed '/is available/d' $outdir/versionid.temp >> $outdir/versionid.out
                rm $outdir/versionid.temp
            fi
    
        fi 
        ##send the email
        mail_title="version detailes for $PLAT"
        sendMail $outdir/versionid.out "$mail_title"
    echo "#########################################################################"
