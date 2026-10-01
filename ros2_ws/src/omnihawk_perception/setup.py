from setuptools import find_packages, setup

package_name = "omnihawk_perception"

setup(
    name=package_name,
    version="0.1.0",
    packages=find_packages(exclude=["test"]),
    data_files=[
        ("share/ament_index/resource_index/packages", ["resource/" + package_name]),
        ("share/" + package_name, ["package.xml"]),
        ("share/" + package_name + "/launch", ["launch/tier1_bringup.launch.py"]),
    ],
    install_requires=["setuptools"],
    zip_safe=True,
    maintainer="Abishek",
    maintainer_email="abishek@multicorewareinc.com",
    description="YOLO perception for OmniHawk on Windows WSL2.",
    license="Apache-2.0",
    entry_points={"console_scripts": ["yolo_node = omnihawk_perception.yolo_node:main"]},
)
