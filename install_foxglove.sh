#!/bin/bash
# Script to install Foxglove Bridge package to ROS 2 system

set -e

ROS_DISTRO=${ROS_DISTRO:-humble}
ROS_PREFIX="/opt/ros/${ROS_DISTRO}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Foxglove Bridge package to ROS 2 ${ROS_DISTRO}..."
echo "Source directory: ${SCRIPT_DIR}"
echo "Target directory: ${ROS_PREFIX}"

# 1. Copy library files
echo "Copying library files..."
mkdir -p "${ROS_PREFIX}/lib"
cp -v "${SCRIPT_DIR}/lib/libfoxglove_bridge_base.so" "${ROS_PREFIX}/lib/"
cp -v "${SCRIPT_DIR}/lib/libfoxglove_bridge_component.so" "${ROS_PREFIX}/lib/"

# 2. Copy include files
echo "Copying include files..."
mkdir -p "${ROS_PREFIX}/include/foxglove_bridge"
cp -v "${SCRIPT_DIR}/include/"*.hpp "${ROS_PREFIX}/include/foxglove_bridge/"

# 3. Copy share directory (package metadata, launch files, etc.)
echo "Copying share directory..."
mkdir -p "${ROS_PREFIX}/share/foxglove_bridge"
cp -rv "${SCRIPT_DIR}/share/"* "${ROS_PREFIX}/share/foxglove_bridge/"

# 4. Create lib/foxglove_bridge directory and copy executable
echo "Setting up executable..."
mkdir -p "${ROS_PREFIX}/lib/foxglove_bridge"
if [ -f "${SCRIPT_DIR}/lib/foxglove_bridge" ]; then
    cp -v "${SCRIPT_DIR}/lib/foxglove_bridge" "${ROS_PREFIX}/lib/foxglove_bridge/"
    chmod +x "${ROS_PREFIX}/lib/foxglove_bridge/foxglove_bridge"
    echo "Foxglove bridge executable installed"
else
    echo "Warning: foxglove_bridge executable not found in source package"
    echo "Creating a component wrapper executable..."
    cat > "${ROS_PREFIX}/lib/foxglove_bridge/foxglove_bridge" << 'EOF'
#!/bin/bash
# Foxglove Bridge executable wrapper
# This script loads the Foxglove Bridge component and runs it

# Start the component container in the background
ros2 run rclcpp_components component_container --ros-args -r __node:=foxglove_bridge_node &
CONTAINER_PID=$!

# Wait a moment for the container to start
sleep 2

# Load the Foxglove bridge component
ros2 component load /foxglove_bridge_node foxglove_bridge foxglove_bridge::FoxgloveBridge

# Wait for the container process
wait $CONTAINER_PID
EOF
    chmod +x "${ROS_PREFIX}/lib/foxglove_bridge/foxglove_bridge"
    echo "Created wrapper executable"
fi

# 5. Register package in ament index
echo "Registering package in ament index..."
mkdir -p "${ROS_PREFIX}/share/ament_index/resource_index/packages"
echo "" > "${ROS_PREFIX}/share/ament_index/resource_index/packages/foxglove_bridge"

# 6. Register component in rclcpp_components index
echo "Registering component..."
mkdir -p "${ROS_PREFIX}/share/ament_index/resource_index/rclcpp_components"
echo "foxglove_bridge::FoxgloveBridge;lib/libfoxglove_bridge_component.so" > "${ROS_PREFIX}/share/ament_index/resource_index/rclcpp_components/foxglove_bridge"

echo ""
echo "✅ Foxglove Bridge installation completed successfully!"
echo ""
echo "Package location: ${ROS_PREFIX}/share/foxglove_bridge"
echo "Libraries: ${ROS_PREFIX}/lib/libfoxglove_bridge_*.so"
echo "Executable: ${ROS_PREFIX}/lib/foxglove_bridge/foxglove_bridge"
echo ""
echo "To verify installation, run:"
echo "  ros2 pkg list | grep foxglove"
echo "  ros2 launch foxglove_bridge foxglove_bridge_launch.xml"

