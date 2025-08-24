# Geo Coordinate Classifier

This is a C++ command-line application designed to classify selected geographical coordinates using a pre-trained machine learning model. The project demonstrates the ability to run a model in a native C++ environment outside of a Python ecosystem.

### Model Details

The model used by this application was initially created with **PyTorch**, **quantized** to 8-bits for efficiency, and then converted to the **ONNX** (Open Neural Network Exchange) format. This process allows the model to be deployed and run on a variety of platforms and frameworks, including ONNX Runtime.

### Features

* **Offline inference:** Runs the ONNX model without needing a network connection.

* **High performance:** Utilizes the ONNX Runtime C++ API for efficient model execution.

* **Portable deployment:** Validates the model's functionality in a native environment, a crucial step for target deployment scenarios.

### Dependencies

* **ONNX Runtime:** The core library required for loading and running the ONNX model.

* **Data File:** This application requires a data file to be present in the build directory.

### Building the Project

This project can be built from the command line using `xcodebuild`. Ensure you have the ONNX Runtime library downloaded and the `ONNXRUNTIME_PATH` environment variable set to the root directory of your ONNX Runtime installation.

```bash
xcodebuild -project geo-coord-classifier-osx.xcodeproj \
           -scheme geo-coord-classifier-osx \
           -configuration Debug \
           "ONNXRUNTIME_PATH=$HOME/path/to/onnxruntime" \
           "ARCHS=arm64"
```

### Running the Application

```bash
	cd DerivedData/geo-coord-classifier-osx/Build/Products/Debug
	./geo-coord-classifier-osx
```
