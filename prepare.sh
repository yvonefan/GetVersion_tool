#!/bin/sh

#################################################################################################
# checkImageDir()
# param  $1         image dir
#                     such as "/remote/pbi_archive8/archives/images/ase/157/sp61/cycle1/output"
# param  $2         plat
# sets              check if the Image dir is corrent or if there is image tar file in it
#`checkImageDir "/remote/pbi_archive8/archives/images/ase/157/sp61/cycle1/output" "linuxamd64"`
#`checkImageDir "/remote/pbi_archive8/archives/images/ase/157/sp61/cycle1/output" ""`
#################################################################################################
checkImageDir()
{
    local imgDir="$1"
    local subDir="$2"

    local plat_imgDir=""
    local plat_setupDir=""

    if [ ! -d "$imgDir" ]; then
        echo "no such dir '$imgDir'"
        exit 1
    fi

    if [ "$subDir" != "" ] ; then
        plat_imgDir="$imgDir/$subDir"
        echo "CHECK IMAGE DIR : $plat_imgDir"
        if [ ! -d "$plat_imgDir" ]; then
            echo "no such dir '$plat_imgDir'"
            exit 1
        fi

        plat_setupDir=`find $plat_imgDir -name 'ASE*_Suite'`
        if [ "$plat_setupDir" = "" ] ; then
            plat_setupDir=`find $plat_imgDir -name 'ase_mm'`
            if [ "$plat_setupDir" = "" ] ; then
                plat_setupDir=`find $plat_imgDir -name 'ase_sdc_mm'`
                if [ "$plat_setupDir" = "" ] ; then
                    echo "CHECK DONE: INVALID"
                else 
                    echo "CHECK DONE: VALID"                
                fi
            else 
                echo "CHECK DONE: VALID"  
            fi          
        else
           echo "CHECK DONE: VALID"
        fi

    else
        local plat_setupDir1=`find $imgDir -name 'ASE*_Suite'`
        local plat_setupDir2=`find $imgDir -name 'ase_mm'`
        local plat_setupDir3=`find $imgDir -name 'ase_sdc_mm'`
        plat_setupDir="$plat_setupDir1 $plat_setupDir2 $plat_setupDir3"

        if [ "$plat_setupDir" = "  " ] ; then
            local istgz=`ls $imgDir | grep .tar`
            local istar=`ls $imgDir | grep .tgz`
            local istar="$istar $istgz"
            local iszip=`ls $imgDir | grep .zip`

            if [ "$istar" != "" -o "$iszip" != "" ] ; then
                if [ -x /usr/bin/tar ] ; then
                    local TAR_CMD="/usr/bin/tar"
                elif [ -x /bin/tar ] ; then
                    local TAR_CMD="/bin/tar"
                elif [ -x /usr/sbin/tar] ; then
                    local TAR_CMD="usr/sbin/tar"
                else
                    local TAR_CMD="tar"
                fi

                if [ -x /usr/bin/unzip ] ; then
                    local UNZIP_CMD="/usr/bin/unzip"
                elif [ -x /usr/sbin/unzip ] ; then
                    local UNZIP_CMD="/usr/sbin/unzip"
                elif [ -x /usr/local/bin/unzip ] ; then
                    local UNZIP_CMD="/usr/local/bin/unzip"
                else
                    local UNZIP_CMD="unzip"
                fi

                local isimg=0
                for fName in $istar
                do
                    local file=$imgDir/$fName
                    local tarfile=`$TAR_CMD -tf $file`
                    local ismpimg1=`echo $tarfile | grep ASE_Suite`
                    local ismpimg2=`echo $tarfile | grep ase_mm`
                    local isdcimg1=`echo $tarfile | grep ASE_CE_Suite`
                    local isdcimg2=`echo $tarfile | grep ase_sdc_mm`
                    if [ "$ismpimg1" != "" -o "$ismpimg2" != "" -o "$isdcimg1" != "" -o "$isdcimg2" != "" ] ; then
                        isimg=`expr $isimg + 1`
                        break
                    fi
                done

                if [ $isimg -eq 0 ] ; then
                    for fName in $iszip
                    do
                        local file=$imgDir/$fName
                        local tarfile=`$UNZIP_CMD -v $file | head -n 5`
                        local ismpimg1=`echo $tarfile | grep ASE_Suite`
                        local ismpimg2=`echo $tarfile | grep ase_mm`
                        local isdcimg1=`echo $tarfile | grep ASE_CE_Suite`
                        local isdcimg2=`echo $tarfile | grep ase_sdc_mm`
                    if [ "$ismpimg1" != "" -o "$ismpimg2" != "" -o "$isdcimg1" != "" -o "$isdcimg2" != "" ] ; then

                            isimg=`expr $isimg + 1`
                            break
                        fi
                    done
                fi

                if [ $isimg -eq 0 ] ; then
                    echo "CHECK ZIP FINE DONE: INVALID"
                else
                    echo "CHECK ZIP FINE DONE: VALID"
                fi

            else
                echo "CHECK DONE: INVALID"
            fi
        else
            echo "CHECK DONE: VALID"
        fi
    fi
}

#################################################################################################
# getPlatform()
# param  $1         a file or directory name
# sets              $getPlatfrom used to return the platform of the image
# for example :
# getPlatform  "/remote/pbi_archive8/archives/images/ase/157/sp61/cycle1/output/linuxamd64"
#################################################################################################
getPlatform()
{
    local imgDir="$1"
    local PLAT=""

    local sysam_Dir=`find ${imgDir} -name 'sysam_utilities' | head -n 1`

    if [ ! -d "$sysam_Dir" ] ; then
        echo "Please make sure the dir is the correct image dir"
        exit 2
    fi

    cd ${sysam_Dir}/bin
    local VER=`strings cpuinfo* | grep "Sybase Licensing API"`

    if [ "`echo $VER | grep x86_64 | grep Linux`" != "" ] ; then
        PLAT=lam
    elif [ "`echo $VER | grep Sun_svr4`" != "" ] ; then
        PLAT=sol
    elif [ "`echo $VER | grep Solaris | grep AMD64`" != "" ] ; then
        PLAT=solam
    elif [ "`echo $VER | grep PPC64 | grep Linux`" != "" ] ; then
        PLAT=lps
    elif [ "`echo $VER | grep NT | grep Windows`" != "" ] ; then
        PLAT=nt32
    elif [ "`echo $VER | grep X64 | grep Windows`" != "" ] ; then
        PLAT=nt64
    elif [ "`echo $VER | grep RS | grep AIX`" != "" ] ; then
        PLAT=i51
    elif [ "`echo $VER | grep ia64 | grep HP-UX`" != "" ] ; then
        PLAT=hpia
    else
        echo "Can not get the platfrom"
    fi

    echo "$PLAT"
}

#################################################################################################
# getPlatimage()
# param  $1         a file or directory name
# PLAT   $2         return the image for PLAT
# sets              $getPlatfrom used to return the platform of the image
# for example :
# getPlatimage "/remote/pbi_archive8/archives/images/ase/157/sp62/cycle1/output" lam  SDC
#################################################################################################
getPlatimage()
{
    local imgDir="$1"
    local PLAT=$2

    local plat_setupDir=""
    local plat_sub=""
    local imgPLAT=""
    local fimgPLAT=""

    if [ "`echo $PLAT | grep sdc`" != ""  ] ; then
        plat_setupDir=`find ${imgDir} -name 'ase_sdc_mm' |grep 'archives/ase_sdc_mm'`
    else 
        plat_setupDir=`find ${imgDir} -name 'ase_mm' |grep 'archives/ase_mm'`
    fi
    
    for plat_sub in `echo $plat_setupDir`
    do
        plat_stupDir=${plat_sub%/archives*}
        imgPLAT=`getPlatform "$plat_stupDir"`

    if [ "`echo $PLAT | grep sdc`" != ""  ] ; then
        fimgPLAT="${imgPLAT}_sdc"
    else
        fimgPLAT=$imgPLAT
    fi

        if [ "$PLAT" = "$fimgPLAT" ] ; then
            echo $plat_stupDir
            break
        fi          
    done
}

#################################################################################################
# sshCmd()
# param  $1         host machine where ssh to
# param  $2         cmd or sciprt
# sets              exec the inst scripts on remote server using ssh
# for example :
# sshCmd lnxpw08 "sh /remote/vldbqa_archive2/jiasun/current_work/ht.sh"
#################################################################################################

sshCmd()
{
    local HOST=$1
    local CMD=$2
    local USER=`whoami`
    local PASS=`cat ~/.q | awk '{print $1}' `

    ## check if the host can be use
    local png_Result=`/bin/ping  -c 3 -i 0.5 $HOST`

    if [ "`echo $png_Result | grep '3 received'`" = "" ] ; then
        echo "$HOST is unavailable, please change machine"
    else
        echo "$HOST is available"
        #curl "http://10.173.0.195:8080/box/download/execCMD?username=$USER&password=$PASS&host=$HOST&cmd=$ICMD"
        $BINDIR/plink -ssh $USER@$HOST -pw $PASS "$CMD"

    fi
}

#################################################################################################
# sshCmd2NT()
# param  $1         host machine where ssh to
# param  $2         cmd or sciprt
# param  $3         flag if need to check the host is alive
# sets              exec the inst scripts on remote  windows machines
# for example :
# sshCmd2NT winpw07 "wmic logicaldisk where "drivetype=3" get name,FreeSpace"
#################################################################################################

sshCmd2NT()
{
    local HOST=$1
    local CMD=$2
    if [ "$3" == "" ]; then
        local isCheck=1
    else
        local isCheck=$3
    fi

    local USER=bart
    local PASS=Sybase123

    #CMD=${CMD//\//\\\\}

    ## check if the host can be use
    if [ $isCheck -eq 1 ]; then
        local png_Result=`/bin/ping  -c 3 -i 0.5 $HOST`

        if [ "`echo $png_Result | grep '3 received'`" = "" ] ; then
            echo "$HOST is unavailable, please change machine"
        else
            echo "$HOST is available"
            $BINDIR/plink -ssh $USER@$HOST -pw $PASS "$CMD"
        fi
    else
        $BINDIR/plink -ssh $USER@$HOST -pw $PASS "$CMD"
    fi
}

#################################################################################################
# putFile2NT()
# param  $1         host machine where copy the file to
# param  $2         source file in local machine
# param  $3         target dir in remote window machine
# sets              exec copy the file from local to remote window machine
# for example :
# putFile2NT winpw07 "$SFILE" "TDIR"
#################################################################################################

putFile2NT()
{
    local HOST=$1
    local SFILE=$2
    local TDIR=$3
    local USER=bart
    local PASS=Sybase123

    TDIR=${TDIR//\\/\\\\}
    $BINDIR/pscp -pw $PASS $SFILE $USER@$HOST:$TDIR
}

#################################################################################################
# getFile5NT()
# param  $1         host machine where copy the file to
# param  $2         source file in remote window machine
# param  $3         target dir in local machine
# sets              exec copy the file from remote window machine to local 
# for example :
# getFile5NT winpw07 "$SFILE" "TDIR"
#################################################################################################

getFile5NT()
{
    local HOST=$1
    local SFILE=$2
    local TDIR=$3
    local OPT=$4
    local USER=bart
    local PASS=Sybase123

    SFILE=${SFILE//\\/\\\\}

    if [ "$OPT" != "" ]; then
        $BINDIR/pscp -pw $PASS -$OPT $USER@$HOST:$SFILE $TDIR
    else
        $BINDIR/pscp -pw $PASS $USER@$HOST:$SFILE $TDIR
    fi
}

#################################################################################################
# getResult()
# param  $1         install work dir used to resotre the install scripts and response files
#################################################################################################
getResult()
{
    local wrkDir="$1"
    local instScrpt=`find $wrkDir -name 'install.out'`
    local script=""

    for script in $instScrpt
    do
        local isreint=`grep "please re-install" $script`
        if [ "$isreint" = "" ]; then
            local RESULT=`grep "Check the Dir Done" $script`
            echo "$RESULT"
            echo ""
            echo ""
            RESULT=`grep -B9 "Begin to check the Dir" $script | grep -v "Begin to check the Dir"`
            echo "$RESULT"
            return 0
        else
            local PLAT=${script%/*}
            PLAT=${PLAT##*/}
            echo "$PLAT"   
            echo "===="   
            echo "INSTALL FAILED!"
            echo "please re-isntall it"
            return 1
        fi
    done
}

#################################################################################################
# getUnixVerDetail()
# param  $1         ASE release Dir
# param  $2         output Dir
#                     note: you need to specify a local Dir even install the windonw image
# param  $3         plat
# param  $4         HOST
#The machine whose platform is same with the installed machine.

#################################################################################################
getUnixVerDetail()
{
    local inst_Dir="$1"
    local out_DIr="$2"
	local PLAT="$3"
    local HOST="$4"
    local destDir="$out_DIr"

    rm $destDir/versionid.sh
    echo "echo \"Platform $PLAT\""  >>  $destDir/versionid.sh
    echo "echo \"--------------------\""  >>  $destDir/versionid.sh
    echo "echo \"Version string:\""  >>  $destDir/versionid.sh
    echo "echo \"===\""  >>  $destDir/versionid.sh
    echo "source $inst_Dir/SYBASE.sh >/dev/null 2>&1" >>  $destDir/versionid.sh
    echo "cd $inst_Dir/ASE-*/bin" >>  $destDir/versionid.sh
    echo "echo \"dataserver===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings dataserver | grep EBF | grep Server\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "echo \"backupserver===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings backupserver | grep EBF | grep Backup\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "echo \"charset===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings charset | grep EBF | grep Charset\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "echo \"langinstall===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings langinstall | grep EBF | grep Langinstall\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh
    
    echo "echo \"sqlupgraderes===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings sqlupgraderes | grep EBF | grep sqlupgrade\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "echo \"srvbuildres===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings srvbuildres | grep EBF | grep srvbuild\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh
   
    echo "echo \"sybmigrate===>\""  >>  $destDir/versionid.sh
    if [ $PLAT != "lam" ];then
        echo "BINDIR=/usr/u/huijuanf/GetVersion_tool/bin" >>  $destDir/versionid.sh
        echo "export BINDIR" >>  $destDir/versionid.sh
        echo "source /usr/u/huijuanf/GetVersion_tool/prepare.sh" >>  $destDir/versionid.sh
         
        echo """sshCmd $HOST \"source $inst_Dir/SYBASE.csh;cd $inst_Dir/ASE-*/bin;sybmigrate -v | grep -i SybMigrate\" """ >>  $destDir/versionid.sh 
        echo "echo -e \"\n\"" >>  $destDir/versionid.sh
    else
        echo "source $inst_Dir/SYBASE.sh >/dev/null 2>&1" >>  $destDir/versionid.sh
        echo "VER=\`sybmigrate -v | grep -i SybMigrate\`" >>  $destDir/versionid.sh
        echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh
    fi

    echo "echo \"sybmultbufe===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings sybmultbuf | grep EBF | grep Emulator\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "echo \"xpserver===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings xpserver | grep EBF | grep XP\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "echo \"diagbs===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings diagbs | grep EBF | grep Backup\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "echo \"diagjsag===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings diagjsag | grep EBF | grep JS\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "echo \"diagoptd===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings diagoptd | grep EBF | grep OptDiag\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "echo \"diagserver===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings diagserver | grep EBF | grep Server\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "echo \"diagsmb===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings diagsmb | grep EBF | grep Emulator\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "echo \"diagxpsb===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings diagxps | grep EBF | grep XP\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "cd $inst_Dir/OCS-*/bin" >>  $destDir/versionid.sh
    echo "echo \"isql===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings isql | grep CTISQL\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "echo \"bcp===>\""  >>  $destDir/versionid.sh
    echo "VER=\`strings bcp | grep CTBCP\`" >>  $destDir/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh

    echo "cd $inst_Dir/OCS-*/lib3p64" >>  $destDir/versionid.sh
    echo "echo \"CSI===>\""  >>  $destDir/versionid.sh
    echo "filename=\`ls -t *syb*csi*core* | grep -m 1 '.'\`" >>  $destDir/versionid.sh
    echo "if [ ! -z $filename ];then"  >>  $destDir/versionid.sh
    echo "    VER=\`strings \$filename | grep CSI | grep '2\.'\`" >>  $destDir/versionid.sh
    echo "    echo -e \"\$VER\n\"" >>  $destDir/versionid.sh
    echo "else" >>  $destDir/versionid.sh
    echo "    echo -e \"cannot get CSI!\n\""  >>  $destDir/versionid.sh
    echo "fi" >>  $destDir/versionid.sh

    echo "echo \"scc.sh===>\""  >>  $destDir/versionid.sh
    if [ ! -f $inst_Dir/SCC-*/bin/scc.sh ];then
         echo "echo -e \"cannot get scc.sh!\n\""  >>  $destDir/versionid.sh
         return 1
    fi
    
    subfilepath=`ls -t $inst_Dir/shared |grep JRE | grep -m 1 '.'`
    if [ $PLAT != "lam" ];then
        rm $destDir/testbash.sh
        echo "subfilepath=$subfilepath" >>  $destDir/testbash.sh
        echo "source $inst_Dir/SYBASE.sh;
              SCC_JAVA_HOME=$inst_Dir/shared/\$subfilepath;
              export SCC_JAVA_HOME;
              cd $inst_Dir/SCC-*/bin;
              VER=\`scc.sh -v |grep Server\`;
              echo \"\$VER\"" >>  $destDir/testbash.sh
        echo "sshCmd $HOST \"sh $destDir/testbash.sh\"" >> $destDir/versionid.sh
        #echo "rm $destDir/testbash.sh" >>  $destDir/versionid.sh
    else
        echo "SCC_JAVA_HOME=$inst_Dir/shared/$subfilepath" >> $destDir/versionid.sh
        echo "export SCC_JAVA_HOME" >> $destDir/versionid.sh
        echo "cd $inst_Dir/SCC-*/bin" >>  $destDir/versionid.sh
        echo "VER=\`scc.sh -v |grep Server\`" >>  $destDir/versionid.sh
        echo "echo -e \"\$VER\n\"" >>  $destDir/versionid.sh
    fi
}


#################################################################################################
# getNTVersionDetails()
# param  $1         remote install Dir
#                     such as "D:\\test_autoinstnt\\nt64_05_07_20.08.10"
# param  $2         remote work Dir
#                     such as "D:\\test_autoinstnt\\WAKESPACE\\nt64_05_07_20.08.10"
#################################################################################################

getNTVersionDetails()
{
    local rmtwkDIR="$1"
    local PLAT="$2"
   
    rm $rmtwkDIR/versionid.sh
    echo "echo \"Platform $PLAT\""  >>  $rmtwkDIR/versionid.sh
    echo "echo \"--------------------\""  >>  $rmtwkDIR/versionid.sh
    echo "echo \"Version string:\""  >>  $rmtwkDIR/versionid.sh
    echo "echo \"===\""  >>  $rmtwkDIR/versionid.sh
    echo "cd $rmtwkDIR" >>  $rmtwkDIR/versionid.sh
    echo "cd ASE-*" >>  $rmtwkDIR/versionid.sh
    echo "cd bin" >>  $rmtwkDIR/versionid.sh
    echo "echo \"sqlsrvr.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`sqlsrvr.exe -v | grep EBF | grep Server\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh

    echo "echo \"bcksrvr.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`bcksrvr.exe -v | grep EBF | grep Backup\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh
    echo "echo \"charset.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`charset.exe -v | grep EBF | grep Charset\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh
    
    echo "echo \"langinst.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`langinst.exe -v | grep EBF | grep  Langinstall\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh
   # echo "VER=\`sybatch.exe -v | grep EBF | grep SyBatch\`" >>  $rmtwkDIR/versionid.sh
    #echo "echo \"\$VER\"" >>  $rmtwkDIR/versionid.sh
    
    #echo "echo \"sybmigrate.bat===>\""  >>  $rmtwkDIR/versionid.sh
    #echo "VER=\`sybmigrate.bat -v | grep SybMigrate\`" >>  $rmtwkDIR/versionid.sh
    #echo "echo \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh

    echo "echo \"sybmbuf.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`sybmbuf.exe -v | grep EBF | grep Emulator\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh

    echo "echo \"xpserver.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`xpserver.exe -v | grep EBF | grep XP\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh

    echo "echo \"diagbs.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`diagbs.exe -v | grep EBF | grep Backup\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh

    echo "echo \"diagjsag.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`diagjsag.exe -v | grep EBF | grep JS\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh

    echo "echo \"diagoptd.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`diagoptd.exe -v | grep EBF | grep OptDiag\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh

    echo "echo \"diagsrvr.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`diagsrvr.exe -v | grep EBF | grep Server\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh

    echo "echo \"diagsmb.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`diagsmb.exe -v | grep EBF\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh

    echo "echo \"diagxps.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`diagxps.exe -v | grep EBF | grep XP\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh

    #echo "VER=\`strings libsybct64.dll | grep EBF\`" >>  $rmtwkDIR/versionid.sh
    #echo "echo \"\$VER\"" >>  $rmtwkDIR/versionid.sh
    #echo "filename=\`ls -t *syb*csi*core* | grep -m 1 '.'\`" >>  $rmtwkDIR/versionid.sh
    #echo "VER=\`strings \$filename | grep CSI | grep '2\.'\`" >>  $rmtwkDIR/versionid.sh
    #echo "echo \"\$VER\"" >>  $rmtwkDIR/versionid.sh

    echo "cd $rmtwkDIR/OCS-*/bin" >>  $rmtwkDIR/versionid.sh
    echo "echo \"isql.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`isql.exe -v | grep EBF | grep CTISQL\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh

    echo "echo \"bcp.exe===>\""  >>  $rmtwkDIR/versionid.sh
    echo "VER=\`bcp.exe -v | grep CTBCP\`" >>  $rmtwkDIR/versionid.sh
    echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh

#    if [ "$PLAT" = "nt32" -o "$PLAT" = "nt386" ];then
#        echo "cd $rmtwkDIR/OCS-*/lib3p" >>  $rmtwkDIR/versionid.sh
#        echo "filename=\`ls -t syb*csi*core* | grep -m 1 '.'\`" >>  $rmtwkDIR/versionid.sh
#        echo "VER=\`strings \$filename | grep EBF | grep '2\.'\`" >>  $rmtwkDIR/versionid.sh
#        echo "echo \"\$VER\"" >>  $rmtwkDIR/versionid.sh
#    else
#        echo "cd $rmtwkDIR/OCS-*/lib3p64" >>  $rmtwkDIR/versionid.sh
#        echo "filename=\`ls -t syb*csi*core* | grep -m 1 '.'\`" >>  $rmtwkDIR/versionid.sh
#        echo "VER=\`strings \$filename | grep EBF | grep '2\.'\`" >>  $rmtwkDIR/versionid.sh
#        echo "echo \"\$VER\"" >>  $rmtwkDIR/versionid.sh
#    fi
#
    #echo "cd $rmtwkDIR/SCC-*/bin" >>  $rmtwkDIR/versionid.sh
    #echo "echo \"scc.bat===>\""  >>  $rmtwkDIR/versionid.sh
    #echo "VER=\`scc.bat -v |grep Server\`" >>  $rmtwkDIR/versionid.sh
    #echo "echo -e \"\$VER\n\"" >>  $rmtwkDIR/versionid.sh
}

#################################################################################################
# updateLic()
# param  $1         install dir
#################################################################################################
updateLic()
{
    local wrkDir="$1"
    local instScrpt=`find $wrkDir -name 'install.out'`
    local script=""

    for script in $instScrpt
    do
        local isok=`grep "Check the Dir Done" ${script}`
        if [ "$isok" = "" ]; then
            continue
        fi

        local lwrkDir=${script%/*}
        local resFile="$lwrkDir/rescord.res"
        local instDir=`sed -n '/USER_INSTALL_DIR/p' $resFile |awk 'BEGIN{ FS="=";}{print $2;}'|sed 's/ //'`

        echo "Update the licenses to $instDir"
        if [ "`echo $script | grep nt32`" != "" -o "`echo $script | grep nt64`" != "" ]; then
            local llic="/usr/u/jiasun/licenses/Nightly.lic_smp"
            local rlic="$instDir\\SYSAM-2_0\\licenses\\Nightly.lic"
            local HOST=`awk '/^HOST/{print $2}' $lwrkDir/HOST`
            putFile2NT $HOST $llic $rlic
        else
            echo "Change the permission of the $instDir to 777"
            `chmod -R 777 $instDir`
            if [ "`echo $script | grep sdc`" != "" ]; then
                `cp /usr/u/jiasun/licenses/Nightly.lic_sdc  $instDir/SYSAM-2_0/licenses/Nightly.lic`
            else
                `cp /usr/u/jiasun/licenses/Nightly.lic_smp $instDir/SYSAM-2_0/licenses/Nightly.lic`
            fi
        fi
    done
    echo "DONE"
}


#################################################################################################
# updateLic1b1()
# param  $1         install dir
#################################################################################################
updateLic1b1()
{
    local scrptDir="$1"
    local script="$scrptDir/install.out"

    local isok=`grep "Check the Dir Done" ${script}`
    if [ "$isok" = "" ]; then
        continue
    fi

    local resFile="$scrptDir/rescord.res"
    local instDir=`sed -n '/USER_INSTALL_DIR/p' $resFile |awk 'BEGIN{ FS="=";}{print $2;}'|sed 's/ //'`

    echo "Update the licenses to $instDir"
    echo "Update the licenses to $instDir" >> $script
    if [ "`echo $script | grep nt32`" != "" -o "`echo $script | grep nt64`" != "" ]; then
        local llic="/usr/u/jiasun/licenses/Nightly.lic_smp"
        local rlic="$instDir\\SYSAM-2_0\\licenses\\Nightly.lic"
        local HOST=`awk '/^HOST/{print $2}' $lwrkDir/HOST`
        putFile2NT $HOST $llic $rlic
    else
        echo "Change the permission of the $instDir to 777"
        echo "Change the permission of the $instDir to 777" >> $script
        `chmod -R 777 $instDir`
        if [ "`echo $script | grep sdc`" != "" ]; then
            `cp /usr/u/jiasun/licenses/Nightly.lic_sdc  $instDir/SYSAM-2_0/licenses/Nightly.lic`
        else
            `cp /usr/u/jiasun/licenses/Nightly.lic_smp $instDir/SYSAM-2_0/licenses/Nightly.lic`
        fi
    fi
    echo "DONE"
}

#added by huijuanf
#################################################################################################
# sendMail()
# param  $1         filename
# param  $2         platform
# param  $3         mail_title
#################################################################################################
sendMail()
{
    local filename="$1"
    local mail_title="$2"

    ##send the email
    if [ -x /usr/bin/mail ] ; then
        EMAIL_CMD="/usr/bin/mail"
    elif [ -x /bin/mail ] ; then
        EMAIL_CMD="/bin/mail"
    elif [ -x /usr/ucb/mail ] ; then
        EMAIL_CMD="/usr/ucb/mail"
    else
        EMAIL_CMD="mail"
    fi
    username=`whoami`
    cat $filename | $EMAIL_CMD -s "$mail_title" $username@sybase.com

}
