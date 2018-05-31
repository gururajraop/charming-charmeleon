/*
 * main.cpp
 *
 *  Created on: 28 May 2016
 *      Author: Minh Ngo @ 3DUniversum
 *
 * Adapted on: 6 June 2017
 *      Authors: Ward Heij, Hella Haanstra
 *
 */
#include <iostream>
#include <boost/format.hpp>

#include <pcl/point_types.h>
#include <pcl/point_cloud.h>
#include <pcl/features/integral_image_normal.h>
#include <pcl/visualization/pcl_visualizer.h>
#include <pcl/common/transforms.h>
#include <pcl/kdtree/kdtree_flann.h>
#include <pcl/filters/passthrough.h>
#include <pcl/surface/poisson.h>
#include <pcl/surface/impl/texture_mapping.hpp>
#include <pcl/features/normal_3d_omp.h>
#include <pcl/surface/poisson.h>
#include <pcl/PCLPointCloud2.h>
#include <pcl/octree/octree.h>
#include <eigen3/Eigen/Core>
#include <pcl/filters/voxel_grid.h>

#include <opencv2/opencv.hpp>
#include <opencv2/core/mat.hpp>
#include <opencv2/core/eigen.hpp>
    
#include "Frame3D/Frame3D.h"

using namespace cv;

pcl::PointCloud<pcl::PointXYZ>::Ptr mat2IntegralPointCloud(const cv::Mat& depth_mat, const float focal_length, const float max_depth) {
    // This function converts a depth image to a point cloud
    assert(depth_mat.type() == CV_16U);
    pcl::PointCloud<pcl::PointXYZ>::Ptr point_cloud(new pcl::PointCloud<pcl::PointXYZ>());
    const int half_width = depth_mat.cols / 2;
    const int half_height = depth_mat.rows / 2;
    const float inv_focal_length = 1.0 / focal_length;
    point_cloud->points.reserve(depth_mat.rows * depth_mat.cols);
    for (int y = 0; y < depth_mat.rows; y++) {
        for (int x = 0; x < depth_mat.cols; x++) {
            float z = depth_mat.at<ushort>(cv:: Point(x, y)) * 0.001;
            if (z < max_depth && z > 0) {
                point_cloud->points.emplace_back(static_cast<float>(x - half_width)  * z * inv_focal_length,
                                                 static_cast<float>(y - half_height) * z * inv_focal_length,
                                                 z);
            } else {
                point_cloud->points.emplace_back(x, y, NAN);
            }
        }
    }
    point_cloud->width = depth_mat.cols;
    point_cloud->height = depth_mat.rows;
    return point_cloud;
}


pcl::PointCloud<pcl::PointNormal>::Ptr computeNormals(pcl::PointCloud<pcl::PointXYZ>::Ptr cloud) {
    // This function computes normals given a point cloud
    // !! Please note that you should remove NaN values from the pointcloud after computing the surface normals.
    pcl::PointCloud<pcl::PointNormal>::Ptr cloud_normals(new pcl::PointCloud<pcl::PointNormal>); // Output datasets
    pcl::IntegralImageNormalEstimation<pcl::PointXYZ, pcl::PointNormal> ne;
    ne.setNormalEstimationMethod(ne.AVERAGE_3D_GRADIENT);
    ne.setMaxDepthChangeFactor(0.02f);
    ne.setNormalSmoothingSize(10.0f);
    ne.setInputCloud(cloud);
    ne.compute(*cloud_normals);
    pcl::copyPointCloud(*cloud, *cloud_normals);
    return cloud_normals;
}

pcl::PointCloud<pcl::PointXYZRGB>::Ptr transformPointCloud(pcl::PointCloud<pcl::PointXYZRGB>::Ptr cloud, const Eigen::Matrix4f& transform) {
    pcl::PointCloud<pcl::PointXYZRGB>::Ptr transformed_cloud(new pcl::PointCloud<pcl::PointXYZRGB>());
    pcl::transformPointCloud(*cloud, *transformed_cloud, transform);
    return transformed_cloud;
}


template<class T>
typename pcl::PointCloud<T>::Ptr transformPointCloudNormals(typename pcl::PointCloud<T>::Ptr cloud, const Eigen::Matrix4f& transform) {
    typename pcl::PointCloud<T>::Ptr transformed_cloud(new typename pcl::PointCloud<T>());
    pcl::transformPointCloudWithNormals(*cloud, *transformed_cloud, transform);
    return transformed_cloud;
}

pcl::PointCloud<pcl::PointNormal>::Ptr mergePointClouds(Frame3D (& frames)[8]) {
    /*
     * Merges point clouds for 8 consecutive frames into a single point cloud.
     */

    pcl::PointCloud<pcl::PointNormal>::Ptr model_point_cloud =  pcl::PointCloud<pcl::PointNormal>::Ptr(new pcl::PointCloud<pcl::PointNormal>());

    float depth = 0.9;
    float focal_length;
    Eigen::Matrix4f camera_pose;
    Mat depth_image;
    pcl::PointCloud<pcl::PointNormal>::Ptr point_cloud_transformed;

    int count = 1;

    for (Frame3D frame : frames) {
        focal_length = frame.focal_length_;
        depth_image = frame.depth_image_;
        camera_pose = frame.getEigenTransform();

        // convert depth image to point cloud
        pcl::PointCloud<pcl::PointXYZ>::Ptr point_cloud = mat2IntegralPointCloud(depth_image, focal_length, depth);

        // compute cloud normals
        pcl::PointCloud<pcl::PointNormal>::Ptr point_cloud_normals = computeNormals(point_cloud);

        // remove NaN values from cloud
        std::vector<int> indices;
        pcl::removeNaNNormalsFromPointCloud(*model_point_cloud, *model_point_cloud, indices);

        // transform cloud
        point_cloud_transformed = transformPointCloudNormals<pcl::PointNormal>(point_cloud_normals, camera_pose);

        // concatenate point clouds
        *model_point_cloud += *point_cloud_transformed;

        std::cout << "Finished processing frame " << std::to_string(count) << std::endl;
        count++;
    }

    return model_point_cloud;
}

int main(int argc, char *argv[]) {
    if (argc != 2)
        return 0;

    /*
     * Part 2: meshing and watertighting
     */
    
    Frame3D frames[8];
    
    // load 3d frames
    for (int i = 0; i < 8; ++i) {
        frames[i].load(boost::str(boost::format("%s/%05d.3df") % argv[1] % i));
    }

    // merge point clouds of all the frames
    pcl::PointCloud<pcl::PointNormal>::Ptr model_point_cloud = mergePointClouds(frames);
    pcl::PCLPointCloud2::Ptr cloud_filtered (new pcl::PCLPointCloud2 ());

    // downsampling the point cloud
    pcl::toPCLPointCloud2(*model_point_cloud, *cloud_filtered);

    float LeafSize = 0.01f;
    pcl::VoxelGrid<pcl::PCLPointCloud2> sor;
    sor.setInputCloud (cloud_filtered);
    sor.setLeafSize (LeafSize, LeafSize, LeafSize);
    sor.filter (*cloud_filtered);

    std::cout << "Finished point cloud reconstruction" << std::endl;

    // execute Poisson surface reconstruction to acquire 3D image mesh
    pcl::fromPCLPointCloud2(*cloud_filtered, *model_point_cloud);
    pcl::Poisson<pcl::PointNormal> poisson;
    poisson.setDepth (9);
    poisson.setInputCloud(model_point_cloud );
    pcl::PolygonMesh triangles;
    poisson.reconstruct(triangles);


    /*
     * Part 3: coloring 3D model
     */

    bool occluded;
    float focal_length;
    float depth = 0.9;
    float resolution = 0.008f;
    Eigen::Matrix4f camera_pose;
    Mat depth_image;

    std::vector<::pcl::Vertices> polygons = triangles.polygons;

    // conversion to XYZ pointcloud
    pcl::PointCloud<pcl::PointXYZRGB>::Ptr mesh_cloud(new pcl::PointCloud<pcl::PointXYZRGB>);
    pcl::fromPCLPointCloud2(triangles.cloud, *mesh_cloud);

    // initialise octree
    pcl::octree::OctreePointCloudSearch<pcl::PointXYZRGB>::Ptr octree (new pcl::octree::OctreePointCloudSearch<pcl::PointXYZRGB>(resolution));

    pcl::TextureMapping<pcl::PointXYZRGB> texture_mapping;

    // set cloud to octree
    octree->setInputCloud(mesh_cloud);

    for (Frame3D frame : frames) {

        depth_image = frame.depth_image_;
        int depth_height = depth_image.size().height;
        int depth_width = depth_image.size().width;
        focal_length = frame.focal_length_;

        // get inverse camera pose
        camera_pose = frame.getEigenTransform().inverse();

        // transform cloud with inverse camera pose
        pcl::PointCloud<pcl::PointXYZRGB>::Ptr trans_cloud = transformPointCloud(mesh_cloud, camera_pose);

        // initialise octree
        pcl::octree::OctreePointCloudSearch<pcl::PointXYZRGB>::Ptr octree (new pcl::octree::OctreePointCloudSearch<pcl::PointXYZRGB>(resolution));
        octree->setInputCloud(trans_cloud);

        // for every polygon, extract points and see if they're occluded
        for (pcl::Vertices polygon : polygons) {

            pcl::PointXYZ point = pcl::PointXYZ();

            // extract points that form the polygon and see if they're occluded
            for (int i = 0; i < polygon.vertices.size(); i++) {
                point.x = (*trans_cloud)[polygon.vertices[i]].x;
                point.y = (*trans_cloud)[polygon.vertices[i]].y;
                point.z = (*trans_cloud)[polygon.vertices[i]].z;

                occluded = texture_mapping.isPointOccluded(point, octree);

                if (occluded) {
                    break;
                }
            }

            // if a polygon is not occluded, colour
            if (!occluded) {
                for (int j = 0; j < polygon.vertices.size(); j++) {

                     pcl::PointXYZRGB point = trans_cloud->points[polygon.vertices[j]];

                     // principal points
                     int cx = depth_width / 2;
                     int cy = depth_height / 2;
                     int u_unscaled = std::round(focal_length * (point.x / point.z) + cx);
                     int v_unscaled = std::round(focal_length * (point.y / point.z) + cy);

                     float u = static_cast<float>( (float) u_unscaled / depth_width);
                     float v = static_cast<float>( (float) v_unscaled / depth_height);


                     // correspondent point in the RGB image
                     int rgb_width = frame.rgb_image_.cols;
                     int rgb_height = frame.rgb_image_.rows;

                     int x = std::floor(rgb_width * u);
                     int y = std::floor(rgb_height * v);

                     // assign colours
                    if ( u > 0 && u < 1 && v > 0 && v < 1) {
                        cv::Vec3b colors = frame.rgb_image_.at<cv::Vec3b>(y,x);
                        mesh_cloud->points[polygon.vertices[j]].r = colors[2];
                        mesh_cloud->points[polygon.vertices[j]].g = colors[1];
                        mesh_cloud->points[polygon.vertices[j]].b = colors[0];
                    }
                }

            }
            else {
                std::cout << "Found occluded point" << std::endl;
            }

        }
    }

    std::cout << "Finished colouring." << std::endl;

    // convert cloud to proper type for visualisation
    pcl::toPCLPointCloud2(*mesh_cloud, triangles.cloud);

    /*
     * Visualisation
     */
    
    std::cout << "Finished texturing" << std::endl;

    boost::shared_ptr<pcl::visualization::PCLVisualizer> viewer(new pcl::visualization::PCLVisualizer("3D Viewer"));
    viewer->setBackgroundColor(1, 1, 1);
    viewer->addPolygonMesh(triangles, "meshes", 0);
    viewer->addCoordinateSystem(1.0);
    viewer->initCameraParameters();
    viewer->setCameraPosition(0.3,0.3,-1,0.3,0.3,0.1,0,-1,0);

    while (!viewer->wasStopped()) {
         viewer->spinOnce(100);
         boost::this_thread::sleep(boost::posix_time::microseconds(100000));
    }

    return 0;
}
