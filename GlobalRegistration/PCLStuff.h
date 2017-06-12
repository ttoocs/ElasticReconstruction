//
//

#ifndef MyVoxelGridFilter_h
#define MyVoxelGridFilter_h

#include <stdio.h>
#include <pcl/point_types.h>
#include <pcl/point_cloud.h>
#include <pcl/common/time.h>
#include <pcl/common/transforms.h>
#include <pcl/common/distances.h>
#include <pcl/console/print.h>
#include <pcl/features/normal_3d_omp.h>
#include <pcl/features/fpfh_omp.h>
#include <pcl/filters/filter.h>
#include <pcl/filters/voxel_grid.h>
#include <pcl/io/pcd_io.h>
#include <pcl/registration/icp.h>
#include "helper.h"


typedef pcl::PointXYZ PointT;
typedef pcl::PointNormal PointNT;
typedef pcl::PointCloud<PointNT> PointCloudT;
typedef pcl::FPFHSignature33 FeatureT;
typedef pcl::FPFHEstimationOMP<PointNT,PointNT,FeatureT> FeatureEstimationT;
typedef pcl::PointCloud<FeatureT> FeatureCloudT;


struct cloud_point_index_idx 
{
  unsigned int idx;
  unsigned int cloud_point_index;

  cloud_point_index_idx (unsigned int idx_, unsigned int cloud_point_index_) : idx (idx_), cloud_point_index (cloud_point_index_) {}
  bool operator < (const cloud_point_index_idx &p) const { return (idx < p.idx); }
};


class VoxelGridFilter : public pcl::VoxelGrid<PointNT>
{
public:

  void myFilter(PointCloudT &output);

  void myApplyFilter(PointCloudT &output);
};


class FeatureEstimationOMP : public pcl::FPFHEstimationOMP<PointNT,PointNT,FeatureT>
{
  void computeFeature(PointCloudOut &output);
};







#endif /* MyVoxelGridFilter_h */
