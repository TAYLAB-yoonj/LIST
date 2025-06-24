# LIST
Microfluidic LIST platform, operational code

## Overview
This repository contains a collection of folders related to a software project, including:
- **AutoCAD Design**: Files and resources for AutoCAD designs, focusing on architectural and engineering blueprints.
- **GUI Code**: Codebase for the graphical user interface components to operate the LIST platform, built to enhance user interaction and experience.
- **Operational File for GUI**: Operational files supporting the GUI functionality, including configuration settings and runtime data.
- **Colony Tracking**: Tools and scripts for tracking colony and segmentation are aimed at monitoring and analyzing colony behavior.

## Structure

**1.1 1_AutoCAD_Design/**
Purpose: This folder contains design files for the microfluidic hardware, likely created in AutoCAD or similar CAD software. These files define the physical layout of microfluidic channels, chambers, and sensors on the chip.
Contents:
Design Files: .dwg or .dxf files for microfluidic chip layouts, specifying dimensions, flow paths, and integration points for actuators.
CAD Templates: Reusable templates for standard microfluidic components (e.g., valves, pumps, or mixing chambers) to streamline design.
Documentation: Guides for best practices in microfluidic design, including material selection (e.g., PDMS, glass) and fabrication techniques (e.g., soft lithography).
Sample Projects: Example designs for specific experiments, such as droplet generation or cell sorting.
Operational Role: These files are used to fabricate the physical microfluidic chip. The operational code may interface with these designs to map software controls to physical components (e.g., mapping GUI inputs to specific valves or pumps).
Potential Code Integration: Scripts (e.g., in Python or MATLAB) might parse CAD files to extract channel geometries or sensor locations, enabling the software to align control logic with the physical layout.
**1.2 2_GUI_Code/**
Purpose: This folder contains the source code for the GUI, which serves as the primary interface for users to control the microfluidic platform and visualize data.
Contents:
Source Code: Likely written in modern web technologies such as JavaScript (e.g., React, Vue.js), Python (e.g., PyQt, Tkinter), or a combination. The code is modular, with components for:
Control Panel: Interfaces to adjust parameters like flow rate, valve states, or temperature.
Data Visualization: Real-time plots or images of colony growth, fluid dynamics, or sensor data.
User Management: Authentication and user preference settings.
Setup Instructions: A README.md or similar file detailing dependencies (e.g., Node.js, Python libraries), installation steps, and how to run the GUI locally or deploy it to a server.
Modularity: Components are organized for scalability, allowing developers to add new features (e.g., support for additional sensors) without major refactoring.
Operational Code:
The GUI likely communicates with the microfluidic hardware via a backend (e.g., Flask or Django in Python) that interfaces with low-level hardware drivers.
Example workflow: A user adjusts a slider to set a pump’s flow rate. The GUI sends this command to the backend, which translates it into a hardware signal (e.g., via USB or serial communication).
Technologies like WebSocket or REST APIs may be used for real-time updates between the GUI and hardware.
Scalability: The modular design supports adding new modules, such as integrating machine learning for automated colony detection or expanding to control multiple chips simultaneously.
**1.3 3_Operational_File_for_GUI/**
Purpose: This folder contains configuration files and runtime data to support the GUI’s functionality.
Contents:
Configuration Files: JSON, YAML, or INI files defining settings like:
Hardware parameters (e.g., pump calibration constants, sensor ranges).
GUI preferences (e.g., default display settings, color schemes).
Connection details (e.g., IP addresses or ports for hardware communication).
Log Files: Records of system events, errors, or user actions for debugging and auditing.
Database Schemas: If the platform uses a database (e.g., SQLite, PostgreSQL), schemas define tables for storing experiment data, user profiles, or calibration settings.
Operational Role:
The GUI reads these files at startup to initialize settings and during runtime to update configurations dynamically.
Example: A JSON file might specify {"pump1_max_flow": 10.0, "units": "uL/min"}, which the GUI uses to set slider ranges.
Log files might be parsed by the GUI to display real-time system status or alert users to hardware issues.
Potential Code:
Python scripts using libraries like json or yaml to load configurations.
SQL queries or ORM (e.g., SQLAlchemy) for database interactions.
Error-handling routines to manage invalid configurations or hardware failures.
**1.4 4_Colony_Tracking/**
Purpose: This folder contains tools for tracking and analyzing biological colonies (e.g., bacterial or cell cultures) within the microfluidic chip.
Contents:
Tracking Scripts: Likely written in Python or MATLAB, using computer vision libraries (e.g., OpenCV, scikit-image) to detect and track colonies in images or video feeds.
Data Analysis Tools: Scripts for quantifying colony growth, segmentation, or behavior (e.g., motility, fluorescence intensity).
Visualization Assets: Code for generating plots (e.g., using Matplotlib, Plotly) or heatmaps to display colony data.
Sample Datasets: Example images or time-series data for testing tracking algorithms.
Integration Guide: Instructions for connecting tracking tools to external systems, such as microscope APIs or third-party analysis software.
Operational Code:
Example: A Python script processes a video feed from a microscope, applies image segmentation to identify colonies, and tracks their positions over time. Results are saved as CSV files or visualized in the GUI.
Machine learning models (e.g., trained with TensorFlow or PyTorch) might be used for advanced segmentation or anomaly detection.
Real-time tracking may involve multithreading to process image streams without delaying GUI responsiveness.
Integration with GUI: The tracking scripts likely send processed data (e.g., colony counts, growth rates) to the GUI via APIs or file-based communication (e.g., writing to a shared database).
**2. Operational Code Workflow**
Here’s an example of how the platform’s operational code might work together:

Startup:
The GUI (2_GUI_Code) loads configurations from 3_Operational_File_for_GUI (e.g., a JSON file specifying hardware settings).
The system connects to the microfluidic chip, using CAD-derived mappings from 1_AutoCAD_Design to align software controls with physical components.
User Interaction:
A user opens the GUI, selects an experiment type (e.g., bacterial colony tracking), and sets parameters (e.g., flow rate, imaging frequency).
The GUI sends commands to the hardware via a backend, which interprets settings and controls pumps, valves, or sensors.
Data Acquisition and Analysis:
The microfluidic chip generates data (e.g., images of colonies), which is processed by scripts in 4_Colony_Tracking.
Tracking algorithms analyze images, extract metrics (e.g., colony size), and store results in a database or file.
Visualization and Feedback:
The GUI retrieves analysis results and displays them as plots or tables.
Logs and errors are written to 3_Operational_File_for_GUI for monitoring.
Shutdown:
The system saves experiment data and updates configurations as needed.

## Contributions
Feel free to fork this repository and submit pull requests. Please ensure to follow the coding standards, include appropriate documentation, and test your changes thoroughly.

## License
This project is licensed under the License - see the [LICENSE](LICENSE) file for details.

## Contact
For any questions or suggestions, please contact the maintainers.

*Last updated: June,23 2025
