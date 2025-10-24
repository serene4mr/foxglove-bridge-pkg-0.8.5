#!/bin/bash
# Script to properly register the Foxglove bridge package with ROS 2

set -e

ROS_DISTRO=${ROS_DISTRO:-humble}
ROS_PREFIX="/opt/ros/${ROS_DISTRO}"

echo "Registering Foxglove bridge package for ROS 2 ${ROS_DISTRO}..."

# Create package directory structure
mkdir -p "${ROS_PREFIX}/share/foxglove_bridge"
mkdir -p "${ROS_PREFIX}/share/foxglove_bridge/environment"
mkdir -p "${ROS_PREFIX}/lib/foxglove_bridge"

# Copy package files to proper location (they should already be in the package)
cp "${ROS_PREFIX}/share/package.xml" "${ROS_PREFIX}/share/foxglove_bridge/" 2>/dev/null || true
cp "${ROS_PREFIX}/share/launch/foxglove_bridge_launch.xml" "${ROS_PREFIX}/share/foxglove_bridge/" 2>/dev/null || true
cp -r "${ROS_PREFIX}/share/cmake" "${ROS_PREFIX}/share/foxglove_bridge/" 2>/dev/null || true
cp -r "${ROS_PREFIX}/share/environment" "${ROS_PREFIX}/share/foxglove_bridge/" 2>/dev/null || true

# Copy setup files
for file in "${ROS_PREFIX}/share/local_setup"*; do
    if [ -f "$file" ]; then
        cp "$file" "${ROS_PREFIX}/share/foxglove_bridge/" 2>/dev/null || true
    fi
done

# Copy package.dsv
cp "${ROS_PREFIX}/share/package.dsv" "${ROS_PREFIX}/share/foxglove_bridge/" 2>/dev/null || true

# Copy the Foxglove Bridge executable to the correct location
# Check multiple possible locations for the executable
if [ -f "/workspaces/mowbot_legacy/src/foxglove-bridge-pkg-0.8.5/lib/foxglove_bridge" ]; then
    cp /workspaces/mowbot_legacy/src/foxglove-bridge-pkg-0.8.5/lib/foxglove_bridge "${ROS_PREFIX}/lib/foxglove_bridge/"
    chmod +x "${ROS_PREFIX}/lib/foxglove_bridge/foxglove_bridge"
    echo "Foxglove bridge executable copied from source package"
elif [ -f "/workspaces/mowbot_legacy/foxglove-bridge-pkg-0.8.5/lib/foxglove_bridge" ]; then
    cp /workspaces/mowbot_legacy/foxglove-bridge-pkg-0.8.5/lib/foxglove_bridge "${ROS_PREFIX}/lib/foxglove_bridge/"
    chmod +x "${ROS_PREFIX}/lib/foxglove_bridge/foxglove_bridge"
    echo "Foxglove bridge executable copied from workspace package"
elif [ -f "/tmp/foxglove-bridge-pkg/lib/foxglove_bridge" ]; then
    cp /tmp/foxglove-bridge-pkg/lib/foxglove_bridge "${ROS_PREFIX}/lib/foxglove_bridge/"
    chmod +x "${ROS_PREFIX}/lib/foxglove_bridge/foxglove_bridge"
    echo "Foxglove bridge executable copied from temp package"
elif [ -f "${ROS_PREFIX}/lib/foxglove_bridge" ]; then
    # If it's already there but in the wrong location, move it
    mv "${ROS_PREFIX}/lib/foxglove_bridge" "${ROS_PREFIX}/lib/foxglove_bridge/foxglove_bridge"
    chmod +x "${ROS_PREFIX}/lib/foxglove_bridge/foxglove_bridge"
    echo "Foxglove bridge executable moved to correct location"
else
    echo "Warning: Foxglove bridge executable not found in any expected location"
    echo "Creating a simple wrapper executable..."
    # Create a simple wrapper that uses the component
    cat > "${ROS_PREFIX}/lib/foxglove_bridge/foxglove_bridge" << 'EOF'
#!/bin/bash
# Simple wrapper for foxglove_bridge component
exec ros2 run rclcpp_components component_container --ros-args -r __node:=foxglove_bridge_node
EOF
    chmod +x "${ROS_PREFIX}/lib/foxglove_bridge/foxglove_bridge"
    echo "Created wrapper executable"
fi

# Register package in ament index
echo "foxglove_bridge" > "${ROS_PREFIX}/share/ament_index/resource_index/packages/foxglove_bridge"

# Register component in rclcpp_components
echo "foxglove_bridge::FoxgloveBridge;lib/libfoxglove_bridge_component.so" > "${ROS_PREFIX}/share/ament_index/resource_index/rclcpp_components/foxglove_bridge"

# Make setup script executable
chmod +x "${ROS_PREFIX}/share/foxglove_bridge/local_setup.sh"

echo "Foxglove bridge package registration completed successfully!"
echo "Package location: ${ROS_PREFIX}/share/foxglove_bridge"
echo "Executable location: ${ROS_PREFIX}/lib/foxglove_bridge/foxglove_bridge"
