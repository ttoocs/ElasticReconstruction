
export PCL_BIN="/home/scott/pcl_merging/pcl_copyin_funcs/build/bin"
export ER_BIN="/home/scott/s2017/ER_port/bin"

export PATH=$PCL_BIN:$ER_BIN:$PATH

PCL_KINFU(){
  PCL_ARGS=" -r -ic -sd 10 -oni ../in.oni -vs 4 --fragment "$SAMPLES" --rgbd_odometry --record_log ./100-0.log --camera ../cam.param"
  pcl_kinfu_largeScale $PCL_ARGS
}

GR(){
  ARGS=" ./kinfu/ ./kinfu/100-0.log $1"
  GlobalRegistration $ARGS
}

GO(){
  ARGS="-w 100 --odometry ./gr/odometry.log --odometryinfo ./gr/odometry.info --loop ./gr/result.txt --loopinfo ./gr/result.info --pose ./pose.log --keep keep.log --refine ./reg_refine_all.log"
  GraphOptimizer $ARGS
}

BC(){
  #UGLY HACK:
  echo "Ugly hack for BC."
  mkdir -p hack
  cd hack
  OLDIFS=$IFS
  IFS=$(echo -en "\n\b")
  for i in `find  ../../ -type f `; do ln -s $i ./ ; done
  cd ..
  IFS=$OLDIFS
  ARGS=" --reg_traj ./hack/reg_refine_all.log --registration --reg_dist 0.05 --reg_ratio 0.25 --reg_num 0 --save_xyzn "

  #ARGS=" --reg_traj ./go/reg_refine_all.log --registration --reg_dist 0.05 --reg_ratio 0.25 --reg_num 0 --save_xyzn "
#  BuildCorrespondence $ARGS
  BuildCorrespondence $ARGS
  echo "BC DONE: $?"
#  exit 
}

FO(){

  NUMPCDS=$(ls -l ./bc/go/gr/kinfu/cloud_bin_*.pcd | wc -l | tr -d ' ')
  
  #UGLY HACK:
  echo "Ugly hack for BC."
  mkdir -p hack
  cd hack
  OLDIFS=$IFS
  IFS=$(echo -en "\n\b")
  for i in `find  ../../ -type f `; do ln -s $i ./ ; done
  cd ..
  IFS=$OLDIFS

  
  ARGS=" --slac --rgbdslam ./hack/init.log --registration ./hack/reg_output.log --dir ./hack/ --num $NUMPCDS --resolution 12 --iteration 10 --length 4.0 --write_xyzn_sample 10"
  #ARGS=" --slac --rgbdslam ./bc/go/gr/init.log --registration ./bc/reg_output.log --dir ./bc/go/gr/kinfu --num $NUMPCDS --resolution 12 --iteration 10 --length 4.0 --write_xyzn_sample 10"

  FragmentOptimizer $ARGS
  echo "Done fragment"
}

INTEGRATE(){
  NUMPCDS=$(ls -l ./fo/bc/go/gr/kinfu/cloud_bin_*.pcd | wc -l | tr -d ' ')
  ARGS=" --pose_traj ./fo/pose.log --seg_traj ./fo/bc/go/gr/kinfu/100-0.log --ctr ./fo/output.ctr --num $NUMPCDS --resolution 12 --camera ../cam.param -oni ../in.oni --length 4.0 --interval "$1
  Integrate $ARGS
}

Pipeline() {
  ONI=$1
  
  NAME=$( basename $ONI)
  
  if [ "$2" == "" ]; then
    SAMPLES="50"
  else
    SAMPLES="$2"
  fi

  CURDIR=$(pwd)
  DIR=$CURDIR/ER.$NAME
  mkdir -p $DIR
  cd $DIR
 
  if [ ! -e $ONI ]; then
    echo "$ONI is not an absolute path (or doesn't exist)"
    exit
  fi

  ln -s $ONI ./in.oni

  if [ ! -e kinfu.$NAME.tar.xz ]; then
   rm -rf kinfu
   mkdir -p kinfu
   cd kinfu
   PCL_KINFU $SAMPELS &>kinfu_log.txt
   cd ..
   tar -c ./kinfu | xz -9 -T8 > kinfu.$NAME.tar.xz
  fi

  if [ ! -e gr.$NAME.tar.xz ]; then
    rm -rf gr
    mkdir -p gr
    cd gr
    ln -s ../kinfu ./
    GR $SAMPLES &>gr_log.txt
    cd ..
    tar -c ./gr | xz -9 -T8 > gr.$NAME.tar.xz
  fi

  if [ ! -e go.$NAME.tar.xz ]; then
    rm -rf go
    mkdir -p go
    cd go
    ln -s ../gr ./
    GO $SAMPLES &>go_log.txt
    cd ..
    tar -c ./go | xz -9 -T8 > go.$NAME.tar.xz
  fi
  
  if [ ! -e bc.$NAME.tar.xz ]; then
    rm -rf bc
    mkdir -p bc
    cd bc
    ln -s ../go ./
    BC $SAMPLES &>bc_log.txt
    cd ..
    tar -c ./bc | xz -9 -T8 > bc.$NAME.tar.xz
  fi
  
  if [ ! -e fo.$NAME.tar.xz ]; then
    rm -rf fo
    mkdir -p fo
    cd fo
    ln -s ../bc ./
    FO $SAMPLES &>fo_log.txt
    cd ..
    tar -c ./fo | xz -9 -T8 > fo.$NAME.tar.xz
  fi

  if [ ! -e integrate.$NAME.tar.xz ]; then
    rm -rf integrate
    mkdir -p integrate
    cd integrate
    ln -s ../fo ./
    INTEGRATE $SAMPLES &>integrate_log.txt
    cd ..
    tar -c ./integrate | xz -9 -T8 > integrate.$NAME.tar.xz
  fi

}


Pipeline $1 $2

