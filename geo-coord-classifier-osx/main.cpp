#include <algorithm>
#include <cmath> // For std::sqrt
#include <fstream>
#include <iostream>
#include <map>
#include <onnxruntime/onnxruntime_cxx_api.h> // The main ONNX Runtime C++ header
#include <print>
#include <sstream>
#include <string>
#include <vector>

struct TestEntry {
    int label;
    std::vector<std::vector<float>> coords;
};

// Corrected test data with a zero-based label for Paris
std::map<std::string, TestEntry> test_data = {
    {"Paris",
     {1, // label (changed from 1 to 0 for zero-based indexing)
      {{48.8575f, 2.3514f},
       {48.8584f, 2.2945f},
       {48.8530f, 2.3499f},
       {48.8606f, 2.3376f},
       {48.8606f, 2.3522f},
       {48.8475f, 2.3789f}}}}};

/**
 * @brief Applies the same normalization or standardization to coordinates as
 * used during training.
 * @param coord The input coordinate vector to normalize.
 * @return The normalized coordinate vector.
 */
std::vector<float> normalize_coords(const std::vector<float> &coord) {
    // You provided these values from your Python script:
    // min_vals=tensor([47.4979, -0.1270])
    // max_vals=tensor([52.5251, 19.0514])

    const float min_lat = 47.4979f;
    const float max_lat = 52.5251f;
    const float min_lon = -0.1270f;
    const float max_lon = 19.0514f;
    const float epsilon = 1e-8f; // To prevent division by zero

    // Apply min-max scaling: (value - min) / (max - min)
    float normalized_lat = (coord[0] - min_lat) / (max_lat - min_lat + epsilon);
    float normalized_lon = (coord[1] - min_lon) / (max_lon - min_lon + epsilon);

    return {normalized_lat, normalized_lon};
}

// The function implementation. The declaration is in ONNXWrapper.h.
void runONNXDemo() {
    try {
        // Create an ONNX Runtime environment
        Ort::Env env(ORT_LOGGING_LEVEL_WARNING, "ONNXHelloWorld");

        // Print a confirmation message
        std::cout << "ONNX Runtime environment created successfully!"
                  << std::endl;

        Ort::SessionOptions session_options;
        session_options.SetIntraOpNumThreads(1);

        std::string model_path =
            "model.onnx";
        Ort::Session session(env, model_path.c_str(), session_options);

        // Get model input/output names
        Ort::AllocatorWithDefaultOptions allocator;

        // Use RAII-safe name getters
        Ort::AllocatedStringPtr input_name_ptr =
            session.GetInputNameAllocated(0, allocator);
        Ort::AllocatedStringPtr output_name_ptr =
            session.GetOutputNameAllocated(0, allocator);

        // Convert to const char* (safe while ptr is alive)
        const char *input_name = input_name_ptr.get();
        const char *output_name = output_name_ptr.get();

        std::cout << "Input name: " << input_name << std::endl;
        std::cout << "Output name: " << output_name << std::endl;
        std::cout << "Model loaded: " << model_path << std::endl;

        ////
        int total = 0;
        int correct = 0;
        Ort::MemoryInfo memory_info =
            Ort::MemoryInfo::CreateCpu(OrtDeviceAllocator, OrtMemTypeCPU);

        // Iterate through test cases
        for (auto &kv : test_data) {
            const auto &entry = kv.second;
            for (auto &coord : entry.coords) {
                // Apply normalization to the coordinates before inference
                std::vector<float> input_tensor_values =
                    normalize_coords(coord);

                std::array<int64_t, 2> input_shape{1, 2};
                std::println("{},{} -> {}", coord[0], coord[1], entry.label);
                Ort::Value input_tensor = Ort::Value::CreateTensor<float>(
                    memory_info, input_tensor_values.data(),
                    input_tensor_values.size(), input_shape.data(),
                    input_shape.size());

                auto output_tensors =
                    session.Run(Ort::RunOptions{nullptr}, &input_name,
                                &input_tensor, 1, &output_name, 1);

                float *output_arr =
                    output_tensors.front().GetTensorMutableData<float>();
                size_t num_classes = output_tensors.front()
                                         .GetTensorTypeAndShapeInfo()
                                         .GetElementCount();

                int pred_class = static_cast<int>(std::distance(
                    output_arr,
                    std::max_element(output_arr, output_arr + num_classes)));

                total++;
                if (pred_class == entry.label) {
                    correct++;
                }
            }
        }

        double accuracy = (double)correct / total;
        std::cout << "Accuracy: " << accuracy * 100.0 << "% (" << correct << "/"
                  << total << ")" << std::endl;

        // Load test data

        // A simple example of creating a tensor just to show the API is
        // working.
        const int64_t input_shape[] = {1, 2, 2, 3}; // Example tensor shape
        float input_data[] = {1.0, 2.0, 3.0, 4.0,  5.0,  6.0,
                              7.0, 8.0, 9.0, 10.0, 11.0, 12.0};
        size_t input_data_length = 12;

        Ort::MemoryInfo memoryInfo =
            Ort::MemoryInfo::CreateCpu(OrtDeviceAllocator, OrtMemTypeCPU);

        Ort::Value input_tensor = Ort::Value::CreateTensor<float>(
            memoryInfo, input_data, input_data_length, input_shape, 4);

        // Print success message
        std::cout << "Successfully created a dummy ONNX tensor." << std::endl;

    } catch (const Ort::Exception &e) {
        std::cerr << "Error with ONNX Runtime: " << e.what() << std::endl;
    } catch (const std::exception &e) {
        std::cerr << "An unexpected error occurred: " << e.what() << std::endl;
    }
}

int main(int argc, const char *argv[]) {
    // insert code here...
    std::cout << "Hello, World!\n";
    runONNXDemo();
    return 0;
}
