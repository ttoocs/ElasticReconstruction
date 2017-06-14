
export PCL_BIN="/home/scott/pcl_merging/pcl_copyin_funcs/build/bin"
export ER_BIN="/home/scott/s2017/ER_port/bin"

export PATH=$PCL_BIN:$ER_BIN:$PATH


SET_SAMPLES(){
  if [ "$1" == "" ]; then
    SAMPLES="50"
    echo "Setting size of samples to 50. (50 frames per fragment)"
  else
    SAMPLES="$1"
  fi

}

SETUP(){
  ONI=$1
  
  NAME=$( basename $ONI)
  
  SET_SAMPLES $2  

  CURDIR=$(pwd)
  DIR=$CURDIR/ER.$NAME
  mkdir -p $DIR
  cd $DIR

  if [ ! -e $ONI ]; then
    echo "$ONI is not an absolute path (or doesn't exist)"
    exit
  fi

  ln -s $ONI ./in.oni
}

CDDIR(){
  cd $DIR
}

UGLYHACK(){
  echo "Ugly hack run in "`pwd`
  mkdir -p hack
  cd hack
  OLDIFS=$IFS
  IFS=$(echo -en "\n\b")
  for i in `find  ../../ -type f `; do ln -s $i ./ ; done
  cd ..
  IFS=$OLDIFS
}


ER_HELP(){
  echo "PCL_KINFU"
  echo "GR"
  echo "GO"
  echo "BC"
  echo "FP"
  echo "INTEGRATE"
  
  echo "or PIPELINE"

}
PCL_KINFU(){
  CDDIR
  SET_SAMPLES $1
  rm -rf kinfu
  mkdir -p kinfu
  cd kinfu
  PCL_ARGS=" -r -ic -sd 10 -oni ../in.oni -vs 4 --fragment "$SAMPLES" --rgbd_odometry --record_log ./100-0.log --camera ../cam.param"
  time ( pcl_kinfu_largeScale $PCL_ARGS )
  cd ..
}

GR(){
  SET_SAMPLES $1
  rm -rf gr
  mkdir -p gr
  cd gr
  ln -s ../kinfu ./
  ARGS=" ./kinfu/ ./kinfu/100-0.log $SAMPLES"
  time ( GlobalRegistration $ARGS )
  cd ..
}

GO(){
    rm -rf go
    mkdir -p go
    cd go
    ln -s ../gr ./
  ARGS="-w 100 --odometry ./gr/odometry.log --odometryinfo ./gr/odometry.info --loop ./gr/result.txt --loopinfo ./gr/result.info --pose ./pose.log --keep keep.log --refine ./reg_refine_all.log"
  time ( GraphOptimizer $ARGS )
    cd ..
}

BC(){

  rm -rf bc
  mkdir -p bc
  cd bc
  ln -s ../go ./

  UGLYHACK

  ARGS=" --reg_traj ./hack/reg_refine_all.log --registration --reg_dist 0.05 --reg_ratio 0.25 --reg_num 0 --save_xyzn "
  #ARGS=" --reg_traj ./go/reg_refine_all.log --registration --reg_dist 0.05 --reg_ratio 0.25 --reg_num 0 --save_xyzn "
  time ( BuildCorrespondence $ARGS )
  echo "BC DONE: $?"

  cd ..
}

FO(){

    rm -rf fo
    mkdir -p fo
    cd fo
    ln -s ../bc ./
  NUMPCDS=$(ls -l ./bc/go/gr/kinfu/cloud_bin_*.pcd | wc -l | tr -d ' ')
  
  UGLYHACK
 
  ARGS=" --slac --rgbdslam ./hack/init.log --registration ./hack/reg_output.log --dir ./hack/ --num $NUMPCDS --resolution 12 --iteration 10 --length 4.0 --write_xyzn_sample 10"
  #ARGS=" --slac --rgbdslam ./bc/go/gr/init.log --registration ./bc/reg_output.log --dir ./bc/go/gr/kinfu --num $NUMPCDS --resolution 12 --iteration 10 --length 4.0 --write_xyzn_sample 10"

  time ( FragmentOptimizer $ARGS )
  cd ..
  echo "Done fragment"
}

INTEGRATE(){
  SET_SAMPLES $1
    rm -rf integrate
    mkdir -p integrate
    cd integrate
    ln -s ../fo ./
  NUMPCDS=$(ls -l ./fo/bc/go/gr/kinfu/cloud_bin_*.pcd | wc -l | tr -d ' ')

  UGLYHACK

  ARGS=" --pose_traj ./hack/pose.log --seg_traj ./hack/100-0.log --ctr ./hack/output.ctr --num $NUMPCDS --resolution 12 --camera ../cam.param -oni ../in.oni --length 4.0 --interval "$SAMPLES
  Integrate $ARGS
  
  cd ..
}

Pipeline() {
 
  SETUP $1 $2

  if [ ! -e kinfu.$NAME.tar.xz ]; then
   PCL_KINFU $SAMPELS &>kinfu_log.txt
   tar -c ./kinfu | xz -9 -T8 > kinfu.$NAME.tar.xz
  fi

  if [ ! -e gr.$NAME.tar.xz ]; then
    GR $SAMPLES &>gr_log.txt
    tar -c ./gr | xz -9 -T8 > gr.$NAME.tar.xz
  fi

  if [ ! -e go.$NAME.tar.xz ]; then
    GO $SAMPLES &>go_log.txt
    tar -c ./go | xz -9 -T8 > go.$NAME.tar.xz
  fi
  
  if [ ! -e bc.$NAME.tar.xz ]; then
    BC $SAMPLES &>bc_log.txt
    tar -c ./bc | xz -9 -T8 > bc.$NAME.tar.xz
  fi
  
  if [ ! -e fo.$NAME.tar.xz ]; then
    FO $SAMPLES &>fo_log.txt
    tar -c ./fo | xz -9 -T8 > fo.$NAME.tar.xz
  fi

  if [ ! -e integrate.$NAME.tar.xz ]; then
    INTEGRATE $SAMPLES &>integrate_log.txt
    tar -c ./integrate | xz -9 -T8 > integrate.$NAME.tar.xz
  fi

}

if [ "$1" == "" ]; then
  echo "Ye need arguments (The oni file in absolute path)"
else
  Pipeline $1 $2
fi

