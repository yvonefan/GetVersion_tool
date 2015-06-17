echo "Platform ibm"
echo "--------------------"
echo "Version string:"
echo "==="
source /remote/aseqa_archive2/yanming3/downloadandinstalltest/install/ASE1503esd45/AIX64/inbox/SYBASE.sh >/dev/null 2>&1
cd /remote/aseqa_archive2/yanming3/downloadandinstalltest/install/ASE1503esd45/AIX64/inbox/ASE-*/bin
echo "dataserver===>"
VER=`strings dataserver | grep EBF | grep Server`
echo -e "$VER\n"
echo "backupserver===>"
VER=`strings backupserver | grep EBF | grep Backup`
echo -e "$VER\n"
echo "charset===>"
VER=`strings charset | grep EBF | grep Charset`
echo -e "$VER\n"
echo "langinstall===>"
VER=`strings langinstall | grep EBF | grep Langinstall`
echo -e "$VER\n"
echo "sqlupgraderes===>"
VER=`strings sqlupgraderes | grep EBF | grep sqlupgrade`
echo -e "$VER\n"
echo "srvbuildres===>"
VER=`strings srvbuildres | grep EBF | grep srvbuild`
echo -e "$VER\n"
echo "sybmigrate===>"
BINDIR=/usr/u/huijuanf/GetVersion_tool/bin
export BINDIR
source /usr/u/huijuanf/GetVersion_tool/prepare.sh
sshCmd p6vm3qa "source /remote/aseqa_archive2/yanming3/downloadandinstalltest/install/ASE1503esd45/AIX64/inbox/SYBASE.csh;cd /remote/aseqa_archive2/yanming3/downloadandinstalltest/install/ASE1503esd45/AIX64/inbox/ASE-*/bin;sybmigrate -v | grep -i SybMigrate" 
echo -e "\n"
echo "sybmultbufe===>"
VER=`strings sybmultbuf | grep EBF | grep Emulator`
echo -e "$VER\n"
echo "xpserver===>"
VER=`strings xpserver | grep EBF | grep XP`
echo -e "$VER\n"
echo "diagbs===>"
VER=`strings diagbs | grep EBF | grep Backup`
echo -e "$VER\n"
echo "diagjsag===>"
VER=`strings diagjsag | grep EBF | grep JS`
echo -e "$VER\n"
echo "diagoptd===>"
VER=`strings diagoptd | grep EBF | grep OptDiag`
echo -e "$VER\n"
echo "diagserver===>"
VER=`strings diagserver | grep EBF | grep Server`
echo -e "$VER\n"
echo "diagsmb===>"
VER=`strings diagsmb | grep EBF | grep Emulator`
echo -e "$VER\n"
echo "diagxpsb===>"
VER=`strings diagxps | grep EBF | grep XP`
echo -e "$VER\n"
cd /remote/aseqa_archive2/yanming3/downloadandinstalltest/install/ASE1503esd45/AIX64/inbox/OCS-*/bin
echo "isql===>"
VER=`strings isql | grep CTISQL`
echo -e "$VER\n"
echo "bcp===>"
VER=`strings bcp | grep CTBCP`
echo -e "$VER\n"
cd /remote/aseqa_archive2/yanming3/downloadandinstalltest/install/ASE1503esd45/AIX64/inbox/OCS-*/lib3p64
echo "CSI===>"
filename=`ls -t *syb*csi*core* | grep -m 1 '.'`
if [ ! -z  ];then
    VER=`strings $filename | grep CSI | grep '2\.'`
    echo -e "$VER\n"
fi
