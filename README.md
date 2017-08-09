# What is this:
* This is a cleaned-up version of the git: git@github.com:Spoonman376/Elastic-Reconstruction-Port.git

* Where the history is tagged onto the origonal authors git/work, (Ie, it's a fork now), and with some git rewritting-history and cleanup.

# Elastic reconstruction Port.
Ported/tested by:
* Erik Spooner
* Scott Saunders


# pcl_kinfu_largeScale

* Part of PCL ( with cuda / gpu / openni(?) )
* Generates cloud_bin\*.pcd
* Generates 100-0.log - A inital log, (Inner-Segment Trajectory log (Camera or Position?)

# Global Registration

* Calculates init.log (doesn't actually use .pcd's, based off of 100-0.log, with duplicating the reset element.)

* Takes in .pcd's, and checks them for alignment/loop closures. - These are all in the RGBDTrajectory format from his site. 
  * results.txt
  * odometry.log 
  * pose.log

# Graph Optmizer

* pose.log

# Build Correspondence

* corres\_\*\_.txt - Indexed per-point pairings.
* reg\_ref\_all.log 

# Fragment Optimizer

* output.ctr (???)
* pose.log

# Integrate

## Outputs:
* world.pcd 

## Inputs:
* `-ref_traj <file>` - Reference trajectory to use (Every matrix is a position in global space) (Can be used without seg/pose/interval, good for testing things.)
* `-seg_traj <file>` - Usually the 100-0.log, information internal to the fragments movement
* `-pose_traj <file>` - Usually the last pose.log from the pipeline that succedded. (The pose? or traj? between fragments)
* `-interval <number>` - The number of frames in a fragment.
* `-num <number of .pcd's>`  - See below
* `-ctr <file>` - Combined with num, used for processing the output of fragment optimizer. (Optional)

