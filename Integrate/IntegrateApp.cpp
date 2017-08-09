//#include "StdAfx.h"
#include "IntegrateApp.h"


CIntegrateApp::CIntegrateApp()
	: cols_( 640 ), rows_( 480 )
	, volume_( cols_, rows_ )
	, exit_( false )
	, registration_( false )
	, time_ms_( 0 )
	, frame_id_( 0 )
	, traj_filename_( "" )
	, pose_filename_( "" )
	, seg_filename_( "" )
	, camera_filename_( "" )
	, ctr_filename_( "" )
	, pcd_filename_( "world.pcd" )
	, ctr_num_( 0 )
	, ctr_resolution_( 8 )
	, ctr_interval_( 50 )
	, ctr_length_( 3.0 )
	, start_from_( -1 )
	, end_at_( 100000000 )
  , reduce_by_ (1)
{
	depth_.resize( cols_ * rows_ );
	scaled_depth_.resize( cols_ * rows_ );

#ifdef IMAGE_VIEWER
	viewer_depth_.setWindowTitle( "Depth stream" );
	viewer_depth_.setPosition( 0, 0 );
#endif
}

CIntegrateApp::~CIntegrateApp(void)
{
}

void CIntegrateApp::Init()
{
	if ( boost::filesystem::exists( camera_filename_ ) ) {
		volume_.camera_.LoadFromFile( camera_filename_ );
	}

	if ( ctr_num_ > 0 && boost::filesystem::exists( ctr_filename_ ) && boost::filesystem::exists( seg_filename_ ) ) {
		grids_.resize( ctr_num_ );
		FILE * f = fopen( ctr_filename_.c_str(), "r" );
		for ( int i = 0; i < ctr_num_; i++ ) {
			grids_[ i ].Load( f, ctr_resolution_, ctr_length_ );
		}
		fclose( f );
	} else {
		ctr_num_ = 0;
	}

	if ( boost::filesystem::exists( traj_filename_ ) ) {
		traj_.LoadFromFile( traj_filename_ );
	}

	if ( boost::filesystem::exists( seg_filename_ ) ) {
		seg_traj_.LoadFromFile( seg_filename_ );

		if ( boost::filesystem::exists( pose_filename_ ) ) {
			pose_traj_.LoadFromFile( pose_filename_ );
			traj_.data_.clear();
			for ( int i = 0; i < ( int )pose_traj_.data_.size(); i++ ) {
				for ( int j = 0; j < ctr_interval_; j++ ) {
					int idx = i * ctr_interval_ + j;
					traj_.data_.push_back( FramedTransformation( idx, idx, idx + 1, pose_traj_.data_[ i ].transformation_ * seg_traj_.data_[ idx ].transformation_ ) );
 				}
			}
			PCL_WARN( "Trajectory created from pose and segment trajectories.\n" );
		}
	}
}

void CIntegrateApp::StartMainLoop()
{
  //cv::Mat depthFrame;
  cv::Mat colourFrame;

  string depthPath = imageDir + "depthframes/";
  string colourPath = imageDir + "colourframes/";

  size_t numFrames =  std::count_if(boost::filesystem::directory_iterator(boost::filesystem::path(depthPath)),
                                    boost::filesystem::directory_iterator(),
                                    [](const boost::filesystem::directory_entry& e)
                                      { return e.path().extension() == ".png";  }
                                   );

  for (int i = 0; i < numFrames; ++i) {

    string depthName = depthPath + "Image" + to_string(i) + ".png";

    cv::Mat depthFrame = cv::imread(depthName, cv::IMREAD_ANYDEPTH);

		if ( depthFrame.cols != cols_ || depthFrame.rows != rows_ ) {
			cols_ = depthFrame.cols;
			rows_ = depthFrame.rows;
			depth_.resize(cols_ * rows_);
			scaled_depth_.resize(cols_ * rows_);
		}

    for (int j = 0; j < rows_; ++j)
      for (int k = 0; k < cols_; ++ k)
        depth_[j * cols_ + k] = depthFrame.at<unsigned short>(j, k);


    frame_id_ = i + 1;


    try {
      this->Execute( true );
    }
    catch (const std::bad_alloc& /*e*/) { cout << "Bad alloc" << endl; break; }
    catch (const std::exception& /*e*/) { cout << "Exception" << endl; break; }

    if(exit_)
      break;

  }

  cout << "Total " << frame_id_ << " frames processed." << endl;

  volume_.SaveWorld( pcd_filename_ ,  reduce_by_);
}


//////////////////////////////////////////////
// Capture functions
//////////////////////////////////////////////
void CIntegrateApp::source_cb2( const boost::shared_ptr< openni_wrapper::Image >& image_wrapper, const boost::shared_ptr< openni_wrapper::DepthImage >& depth_wrapper, float )
{
	{
		boost::mutex::scoped_try_lock lock( data_ready_mutex_ );
		if ( exit_ || !lock )
			return;

		if ( depth_wrapper->getWidth() != image_wrapper->getWidth() || depth_wrapper->getHeight() != image_wrapper->getHeight() ) {
			PCL_ERROR( "Resolution of depth stream and image stream must match." );
			return;
		}

		if ( depth_wrapper->getWidth() != cols_ || depth_wrapper->getHeight() != rows_ ) {
			cols_ = depth_wrapper->getWidth();
			rows_ = depth_wrapper->getHeight();
			depth_.resize( cols_ * rows_ );
			scaled_depth_.resize( cols_ * rows_ );
		}
                  
		depth_wrapper->fillDepthImageRaw( cols_, rows_, &depth_[ 0 ] );
	}
	data_ready_cond_.notify_one();
}

void CIntegrateApp::source_cb2_trigger( const boost::shared_ptr< openni_wrapper::Image >& image_wrapper, const boost::shared_ptr< openni_wrapper::DepthImage >& depth_wrapper, float )
{
	{
		boost::mutex::scoped_lock lock( data_ready_mutex_ );
		if ( exit_ )
			return;

		if ( depth_wrapper->getWidth() != cols_ || depth_wrapper->getHeight() != rows_ ) {
			cols_ = depth_wrapper->getWidth();
			rows_ = depth_wrapper->getHeight();
			depth_.resize( cols_ * rows_ );
			scaled_depth_.resize( cols_ * rows_ );
		}
                  
		depth_wrapper->fillDepthImageRaw( cols_, rows_, &depth_[ 0 ] );
		frame_id_ = depth_wrapper->getDepthMetaData().FrameID();
	}
	data_ready_cond_.notify_one();
}

void CIntegrateApp::Execute( bool has_data )
{
	if ( !has_data ) {
		return;
	}


	if ( frame_id_ >= traj_.data_.size() ) {
    PCL_WARN("Exiting due to potental segfault. %d of %d  \n", frame_id_, traj_.data_.size());
		exit_ = true;
		return;
	}
	
  if ( traj_.data_[ frame_id_ - 1 ].frame_ == -1 ) {
		return;
	}

	if ( frame_id_ % 100 == 0 ) {
		PCL_WARN( "Frames processed : %d / %d\n", frame_id_, traj_.data_.size() );
	}

	if ( frame_id_ < start_from_ || frame_id_ > end_at_ ) {
		if ( frame_id_ > end_at_ ) {
			PCL_WARN( "Reaching the specified end point.\n" );
			exit_ = true;
		}
		return;
	}

	if ( ctr_num_ > 0 ) {
		Reproject();
		if ( exit_ ) {
			return;
		}
	}

	volume_.ScaleDepth( depth_, scaled_depth_ );
	volume_.Integrate( depth_, scaled_depth_, traj_.data_[ frame_id_ - 1 ].transformation_ );
}

void CIntegrateApp::Reproject()
{
	if ( frame_id_ > ctr_interval_ * ctr_num_ ) {
		exit_ = true;
		return;
	}

	depth_buffer_.resize( depth_.size() );
	for ( int i = 0; i < cols_ * rows_; i++ ) {
		depth_buffer_[ i ] = depth_[ i ];
		depth_[ i ] = 0;
	}

	int chunk = ( frame_id_ - 1 ) / ctr_interval_;
	Eigen::Matrix4d TiT0Ai_adj = traj_.data_[ frame_id_ - 1 ].transformation_.inverse() * traj_.data_[ 0 ].transformation_ * seg_traj_.data_[ 0 ].transformation_.inverse();

	int uu, vv;
	unsigned short dd;
	double x, y, z;
	for ( int v = 0; v < rows_; v += 1 ) {
		for ( int u = 0; u < cols_; u += 1 ) {
			unsigned short d = depth_buffer_[ v * cols_ + u ];
			if ( volume_.UVD2XYZ( u, v, d, x, y, z ) ) {
				Eigen::Vector4d dummy = seg_traj_.data_[ frame_id_ - 1 ].transformation_ * Eigen::Vector4d( x, y, z, 1 );
				Coordinate coo;
				Eigen::Vector3f pos;

				if ( grids_[ chunk ].GetCoordinate( Eigen::Vector3f( dummy( 0 ), dummy( 1 ), dummy( 2 ) ), coo ) ) {		// in the box, thus has the right coo
					grids_[ chunk ].GetPosition( coo, pos );
					Eigen::Vector4d reproj_pos = TiT0Ai_adj * Eigen::Vector4d( pos( 0 ), pos( 1 ), pos( 2 ), 1.0 );

					if ( volume_.XYZ2UVD( reproj_pos( 0 ), reproj_pos( 1 ), reproj_pos( 2 ), uu, vv, dd ) ) {
						unsigned short ddd = depth_[ vv * cols_ + uu ];
						if ( ddd == 0 || ddd > dd ) {
							depth_[ vv * cols_ + uu ] = dd;
						}
					}
				}
			}
		}
	}
}
