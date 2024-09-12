**Nonstationary Transformer**
**Overview**
This project implements a Nonstationary Transformer model designed for forecasting nonstationary time series data. The model adapts to changing statistical properties in time series, improving its prediction capabilities.
**Prerequisites**
Miniconda: The project uses Miniconda for managing the Python environment. If Miniconda is not installed, the script will automatically download and install it.
bash: Ensure you're running on a Unix-based system, such as Linux or macOS, or use WSL on Windows.
**Run the setup script: This script installs Miniconda, sets up the required Python environment, and installs dependencies.**
Command: source./setup.sh
**Setup**
The project uses Miniconda for environment management. Running the setup.sh script will handle:

Installing Miniconda (if not installed).
Creating a Conda environment with Python 3.7.
Installing required dependencies from requirements.txt.
Running scripts for various datasets like ILI, Exchange, and ETT.
Project Structure
data_provider/: Handles data processing and loading.
dataset/: Contains datasets for experiments.
exp/: Manages experiment configurations.
layers/: Custom layers for the transformer.
models/: Implementation of the Nonstationary Transformer.
ns_layers/: Nonstationary-specific layers.
scripts/: Scripts for running the model on different datasets.
setup.sh: Script to automate environment setup and model execution.
requirements.txt: Lists required Python packages.
