subfilepath=JRE-6_0_SR13FP2_64BIT
source /remote/aseqa_archive2/yanming3/downloadandinstalltest/install/ASE1503esd45/AIX64/inbox/SYBASE.sh;
              SCC_JAVA_HOME=/remote/aseqa_archive2/yanming3/downloadandinstalltest/install/ASE1503esd45/AIX64/inbox/shared/$subfilepath;
              export SCC_JAVA_HOME;
              cd /remote/aseqa_archive2/yanming3/downloadandinstalltest/install/ASE1503esd45/AIX64/inbox/SCC-*/bin;
              VER=`scc.sh -v |grep Server`;
              echo "$VER"
