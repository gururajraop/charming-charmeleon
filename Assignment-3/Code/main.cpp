/*
 * main.cpp
 *
 *  Created on: 28 May 2016
 *      Author: Minh Ngo @ 3DUniversum
 */
#include <iostream>
#include <boost/format.hpp>

#include <pcl/point_types.h>
#include <pcl/point_cloud.h>
#include <pcl/features/integral_image_normal.h>
#include <pcl/visualization/pcl_visualizer.h>
#include <pcl/common/transforms.h>
#include <pcl/kdtree/kdtree_flann.h>
#include <pcl/surface/marching_cubes.h>
#include <pcl/surface/marching_cubes_hoppe.h>
#include <pcl/filters/passthrough.h>
#include <pcl/surface/poisson.h>
#include <pcl/surface/impl/texture_mapping.hpp>
#include <pcl/features/normal_3d_omp.h>

#include <eigen3/Eigen/Core>

#include <opencv2/opencv.hpp>
#include <opencv2/core/mat.hpp>
#include <opencv2/core/eigen.hpp>

#include "Frame3D/Frame3D.h"
#include <pcl/search/kdtree.h>

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


pcl::PointCloud<pcl::PointXYZRGBNormal>::Ptr mergingPointClouds(Frame3D frames[]) {
    pcl::PointCloud<pcl::PointXYZRGBNormal>::Ptr modelCloud(new pcl::PointCloud<pcl::PointXYZRGBNormal>);
    pcl::PointCloud<pcl::PointXYZRGBNormal>::Ptr transformedCloud(new pcl::PointCloud<pcl::PointXYZRGBNormal>);

    const float maxDepth = 1.3;
    for (int i = 0; i < 8; i++) {
        std::cout << boost::format("Merging frame %d") % i << std::endl;

        Frame3D frame = frames[i];
        cv::Mat depthImage = frame.depth_image_;
        double focalLength = frame.focal_length_;
        const Eigen::Matrix4f cameraPose = frame.getEigenTransform();

	// Depth to point cloud conversion using depth image and focal length
	pcl::PointCloud<pcl::PointXYZ>::Ptr pointCloud = mat2IntegralPointCloud(depthImage, focalLength, maxDepth);

	// Compute the normals for the point cloud
	pcl::PointCloud<pcl::PointNormal>::Ptr PCNormal = computeNormals(pointCloud);

	// Transform the point cloud normals
	pcl::PointCloud<pcl::PointNormal>::Ptr transformedPCNormals = transformPointCloudNormals<pcl::PointNormal>(PCNormal, cameraPose);

	// Convert the point clouds from PointNormal to PointXYZRGBNormal
	pcl::copyPointCloud(*transformedPCNormals, *transformedCloud);

	// Concat the point clouds
	*modelCloud += *transformedCloud;

	std::cout << boost::format("Finished merging frame %d") % i << std::endl;
    }
    // Remove NAN values if any
    pcl::PassThrough<pcl::PointXYZRGBNormal> filter;
    filter.setInputCloud(modelCloud);
    filter.filter(*modelCloud);

    std::cout << boost::format("Merged point cloud contains %d points") % modelCloud->size() << std::endl;

    return modelCloud;
}

bool checkPointOccluded(pcl::PointCloud<pcl::PointXYZRGBNormal>::Ptr cloud, pcl::Vertices polygon) {
    pcl::PointXYZ pointXYZ = pcl::PointXYZ();

    // Create an OCTree and texture mapping to check the polygon visibility
    const double resolution = 0.05f;
    pcl::octree::OctreePointCloudSearch<pcl::PointXYZRGBNormal>::Ptr ocTree(new pcl::octree::OctreePointCloudSearch<pcl::PointXYZRGBNormal>(resolution));
    pcl::TextureMapping<pcl::PointXYZRGBNormal> textureMapping;

    // Check the point of every vertex for visibility wrt the camera/cloud
    for (size_t i=0; i< polygon.vertices.size(); ++i) {
	// Get the coordinated of the vertices using the point cloud
	pointXYZ.x = (*cloud)[polygon.vertices[i]].x;
	pointXYZ.y = (*cloud)[polygon.vertices[i]].y;
	pointXYZ.z = (*cloud)[polygon.vertices[i]].z;

	// If any of the vertices are occluded, then the polygon is occluded. Hence, return true
	if(textureMapping.isPointOccluded(pointXYZ, ocTree)) {
	    return true;
	}
    }
    return false;
}

pcl::PointCloud<pcl::PointXYZRGB>::Ptr colorPointCloud(pcl::PointCloud<pcl::PointXYZ>::Ptr pointCloud, Frame3D frame) {

    pcl::PointCloud<pcl::PointXYZRGB>::Ptr coloredCloud(new pcl::PointCloud<pcl::PointXYZRGB>);

    // Get the image size and focal length from the frame
    int height = frame.depth_image_.size().height;
    int width = frame.depth_image_.size().width;
    float focalLength = frame.focal_length_;

    for (size_t i=0; i<pointCloud->size(); ++i) {
	// Caclulate the UV coordinates
	float U = (focalLength * pointCloud->points[i].x / pointCloud->points[i].z) + (width / 2);
	float V = (focalLength * pointCloud->points[i].y / pointCloud->points[i].z) + (height / 2);

	// Normalize them to unit size using the image size
	U = U / width;
	V = V / height;

	// Upscale them to the original RGB image size and get the UV coordinates
	int U_coor = std::floor(frame.rgb_image_.cols * U);
	int V_coor = std::floor(frame.rgb_image_.rows * V);

	pcl::PointXYZRGB point;

	// Extract the RGB values from the rgb images at position UV coordinates
	if (U > 0 && U < 1 && V > 0 && V < 1) {
	    // Extract the RGB values from the figure using UV coordinates
	    cv::Vec3b rgb = frame.rgb_image_.at<cv::Vec3b>(V_coor,U_coor);

	    // Assign the color to cloud point
	    point.r = rgb[2];
	    point.g = rgb[1];
	    point.b = rgb[0];
	}

	// Assign the color values to the color cloud
	coloredCloud->push_back(point);
    }

    return coloredCloud;
}

pcl::PointCloud<pcl::PointXYZRGBNormal>::Ptr mergingPointCloudsWithTexture(Frame3D frames[]) {
    pcl::PointCloud<pcl::PointXYZRGBNormal>::Ptr modelCloud(new pcl::PointCloud<pcl::PointXYZRGBNormal>);
    pcl::PointCloud<pcl::PointXYZRGBNormal>::Ptr transformedCloud(new pcl::PointCloud<pcl::PointXYZRGBNormal>);

    const float maxDepth = 1.3;
    for (int i = 0; i < 8; i++) {
        std::cout << boost::format("Merging frame %d") % i << std::endl;

        Frame3D frame = frames[i];
        cv::Mat depthImage = frame.depth_image_;
        double focalLength = frame.focal_length_;
        const Eigen::Matrix4f cameraPose = frame.getEigenTransform();

	// Depth to point cloud conversion using depth image and focal length
	pcl::PointCloud<pcl::PointXYZ>::Ptr pointCloud = mat2IntegralPointCloud(depthImage, focalLength, maxDepth);

	// Compute the normals for the point cloud
	pcl::PointCloud<pcl::PointNormal>::Ptr PCNormal = computeNormals(pointCloud);
	
	// Transform the point cloud normals
	pcl::PointCloud<pcl::PointNormal>::Ptr transformedPCNormals = transformPointCloudNormals<pcl::PointNormal>(PCNormal, cameraPose);

	// Color the point cloud
	pcl::PointCloud<pcl::PointXYZRGB>::Ptr colorCloud = colorPointCloud(pointCloud, frame);

	// Merge the colored cloud and transformed normals. Also converts the point clouds to PointXYZRGBNormal type
	pcl::concatenateFields(*colorCloud, *transformedPCNormals, *transformedCloud);

	// Concat the point clouds
	*modelCloud += *transformedCloud;

	std::cout << boost::format("Finished merging frame %d") % i << std::endl;
    }
    // Remove NAN values if any
    pcl::PassThrough<pcl::PointXYZRGBNormal> filter;
    filter.setInputCloud(modelCloud);
    filter.filter(*modelCloud);

    std::cout << boost::format("Merged point cloud contains %d points") % modelCloud->size() << std::endl;

    return modelCloud;
}

pcl::PolygonMesh transferColor2Mesh(pcl::PointCloud<pcl::PointXYZRGBNormal>::Ptr texturedCloud, pcl::PolygonMesh mesh) {
    std::vector<pcl::Vertices> polygons = mesh.polygons;
    pcl::PointCloud<pcl::PointXYZRGBNormal>::Ptr pointCloud(new pcl::PointCloud<pcl::PointXYZRGBNormal>);
    pcl::fromPCLPointCloud2(mesh.cloud, *pointCloud);

    pcl::KdTreeFLANN<pcl::PointXYZRGBNormal>::Ptr mappingTree(new pcl::KdTreeFLANN<pcl::PointXYZRGBNormal>);
    mappingTree->setInputCloud(texturedCloud);

    //pcl::PointXYZRGBNormal &point = pcl::PointXYZRGBNormal();

    for(size_t i=0; i<polygons.size(); ++i) {
	// Check if the polygon is visible
	if(!checkPointOccluded(pointCloud, polygons[i])) {
	// Transfer the color for visible polygons
	for (size_t j=0; j<polygons[i].vertices.size(); ++j) {
	    pcl::PointXYZRGBNormal &point = pointCloud->points[polygons[i].vertices[j]];

	    // Get the nearest points in the polygon mesh
	    std::vector<int> indices;
            std::vector<float> distances;
            mappingTree->nearestKSearch(point, 1, indices, distances);

	    // Get the closest point from the texturedCloud and assign itś RGB values
	    pcl::PointXYZRGBNormal& texturedPoint = texturedCloud->points[indices[0]];
	    if(texturedPoint.r != 0 && texturedPoint.g != 0 && texturedPoint.b != 0) {
                point.r = texturedPoint.r;
                point.g = texturedPoint.g;
                point.b = texturedPoint.b;
            }

	}}
    }

    // Update the mesh cloud values with colored point cloud
    pcl::toPCLPointCloud2(*pointCloud, mesh.cloud);

    return mesh;
}

// Different methods of constructing mesh
enum CreateMeshMethod { PoissonSurfaceReconstruction = 0, MarchingCubes = 1};

// Create mesh from point cloud using one of above methods
pcl::PolygonMesh createMesh(pcl::PointCloud<pcl::PointXYZRGBNormal>::Ptr pointCloud, CreateMeshMethod method) {
    std::cout << "Creating meshes" << std::endl;

    // The variable for the constructed mesh
    pcl::PolygonMesh triangles;
    // Convert the provided point cloud from PointXYZRGBNormal to PointNormal type
    pcl::PointCloud<pcl::PointNormal>::Ptr pointCloudNormal(new pcl::PointCloud<pcl::PointNormal>);
    pcl::copyPointCloud(*pointCloud, *pointCloudNormal);

    switch (method) {
        case PoissonSurfaceReconstruction: {
	    // Create the poisson object and set the parameters 
            pcl::Poisson<pcl::PointNormal> poisson;
            
	    // High depth for high resolution
	    poisson.setDepth(10);

	    // Smooth noise by using more samples per octree node
	    poisson.setSamplesPerNode(20.0f);
            poisson.setInputCloud(pointCloudNormal);

	    // Reconstruct the mesh using the provided point clouds
            poisson.reconstruct(triangles);
            break;
	}
        case MarchingCubes: {
            pcl::MarchingCubesHoppe<pcl::PointNormal> mc;
	    mc.setInputCloud(pointCloudNormal);

            // Possible memory errors, set to 100 for results (Piazza)
            mc.setGridResolution(100, 100, 100);
            mc.reconstruct(triangles);
            break;
	}
    }
    return triangles;
}


int main(int argc, char *argv[]) {
    if (argc != 4) {
        std::cout << "./final [3DFRAMES PATH] [RECONSTRUCTION MODE] [TEXTURE_MODE]" << std::endl;

        return 0;
    }

    const CreateMeshMethod reconMode = static_cast<CreateMeshMethod>(std::stoi(argv[2]));
    std::cout<<"Mesh reconstruction method: "<<reconMode<<std::endl;

    // Loading 3D frames
    Frame3D frames[8];
    for (int i = 0; i < 8; ++i) {
        frames[i].load(boost::str(boost::format("%s/%05d.3df") % argv[1] % i));
    }

    pcl::PointCloud<pcl::PointXYZRGBNormal>::Ptr texturedCloud;
    pcl::PolygonMesh triangles;

    if (argv[3][0] == 't') {
	std::cout<<"Merging point clouds with texture support"<<std::endl;

        // SECTION 4: Coloring 3D Model
        // Create one point cloud by merging all frames with texture using
        // the rgb images from the frames
        texturedCloud = mergingPointCloudsWithTexture(frames);

        // Create a mesh from the textured cloud using a reconstruction method,
        // Poisson Surface or Marching Cubes
        triangles = createMesh(texturedCloud, reconMode);
	std::cout<<"Finished mesh creation"<<std::endl;

	std::cout<<"Transfering the color/texture to mesh"<<std::endl;
	triangles = transferColor2Mesh(texturedCloud, triangles);
    } else {
	std::cout<<"Merging point clouds without texture support"<<std::endl;
        // SECTION 3: 3D Meshing & Watertighting

        // Create one point cloud by merging all frames with texture using
        // the rgb images from the frames
        texturedCloud = mergingPointClouds(frames);

        // Create a mesh from the textured cloud using a reconstruction method,
        // Poisson Surface or Marching Cubes
        triangles = createMesh(texturedCloud, reconMode);
    }

    // Sample code for visualization.

    // Show viewer
    std::cout << "Finished texturing" << std::endl;
    boost::shared_ptr<pcl::visualization::PCLVisualizer> viewer(new pcl::visualization::PCLVisualizer("3D Viewer"));

    // Add colored point cloud to viewer, because it does not support colored meshes
    pcl::visualization::PointCloudColorHandlerRGBField<pcl::PointXYZRGBNormal> rgb(texturedCloud);
    //viewer->addPointCloud<pcl::PointXYZRGBNormal>(texturedCloud, rgb, "cloud");

    // Add mesh
    viewer->setBackgroundColor(1, 1, 1);
    viewer->addPolygonMesh(triangles, "meshes", 0);
    // viewer->addCoordinateSystem(1.0);
    viewer->initCameraParameters();
    viewer->setCameraPosition(0.3,0.3,-1,0.3,0.3,0.1,0,-1,0);
    usleep(15000000);
    viewer->setCameraPosition(0.3,0.3,-1,0.3,0.3,0.1,0,-1,0);
    usleep(15000000);
    viewer->setCameraPosition(-1.1,0.3,0.1,0.3,0.3,0.1,0,-1,0);
    usleep(15000000);
    viewer->setCameraPosition(0.25,0.3,1.5,0.3,0.3,0.1,0,-1,0);
    usleep(15000000);
    viewer->setCameraPosition(0.6,-0.6,-0.5,0.3,0.3,0.1,0,-1,0);
    // Keep viewer open
    while (!viewer->wasStopped()) {
        viewer->spinOnce(100);
        boost::this_thread::sleep(boost::posix_time::microseconds(100000));
    }


    return 0;
}
