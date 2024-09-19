#!/bin/bash

# Define variables
CONDA_INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
CONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
CONDA_PATH="$HOME/miniconda3"
ENV_NAME="myenv_7"
PYTHON_VERSION="3.7"
PROJECT_DIR="$(pwd)"
YML_FILE="$PROJECT_DIR/myenv_7.yml"
REQUIREMENTS_FILE="$PROJECT_DIR/requirements.txt"

# Function to check for GPU
check_gpu() {
    if command -v nvidia-smi &> /dev/null; then
        echo "GPU detected."
        return 0  # GPU is available
    else
        echo "No GPU detected."
        return 1  # GPU is not available
    fi
}

# Function to verify CUDA installation
verify_cuda() {
    if command -v nvcc &> /dev/null; then
        echo "CUDA installed correctly. Version:"
        nvcc --version
    else
        echo "CUDA installation not found. Please check the installation."
    fi
}

# Function to verify cuDNN installation
verify_cudnn() {
    if [ -f /usr/local/cuda/lib64/libcudnn.so ]; then
        echo "cuDNN installed correctly."
        echo "cuDNN version:"
        dpkg -s libcudnn8 | grep Version
    else
        echo "cuDNN installation not found. Please check the installation."
    fi
}

# Step 0: Fix Windows line endings if necessary
if command -v dos2unix &> /dev/null; then
    echo "Converting script to Unix line endings..."
    dos2unix "$0"
fi

# Step 1: Install Miniconda if not already installed
if [ ! -d "$CONDA_PATH" ]; then
    echo "Downloading Miniconda..."
    wget -q $CONDA_INSTALLER_URL -O $CONDA_INSTALLER
    chmod +x $CONDA_INSTALLER

    echo "Installing Miniconda..."
    bash $CONDA_INSTALLER -b -p $CONDA_PATH
    rm $CONDA_INSTALLER
else
    echo "Miniconda already installed at $CONDA_PATH."
fi

# Step 2: Initialize Conda if not already initialized
if ! grep -q "conda initialize" ~/.bashrc; then
    echo "Initializing Conda..."
    eval "$($CONDA_PATH/bin/conda shell.bash hook)"
    $CONDA_PATH/bin/conda init bash
    source ~/.bashrc
else
    echo "Conda is already initialized in .bashrc."
    eval "$($CONDA_PATH/bin/conda shell.bash hook)"
fi

# Step 3: Verify Conda installation
if ! command -v conda &> /dev/null; then
    echo "Conda command not found. Please check the installation."
    exit 1
else
    echo "Conda installation verified. Version:"
    conda --version
fi

# Step 4: Create or Update Conda Environment
if [ -f "$YML_FILE" ]; then
    echo "Environment file found at $YML_FILE. Creating or updating environment from it..."
    conda env create -f "$YML_FILE"
else
    echo "No .yml file found. Creating a new environment '$ENV_NAME' with Python $PYTHON_VERSION..."
    conda create --name $ENV_NAME python=$PYTHON_VERSION -y
    conda activate $ENV_NAME

    echo "Exporting the new environment to $YML_FILE..."
    conda env export > "$YML_FILE"
fi

# Step 5: Activate Conda environment
echo "Activating environment '$ENV_NAME'..."
conda activate $ENV_NAME

# Step 6: Install packages from requirements.txt if it exists
if [ -f "$REQUIREMENTS_FILE" ]; then
    echo "Installing packages from $REQUIREMENTS_FILE..."
    pip install -r "$REQUIREMENTS_FILE"
else
    echo "Requirements file not found. Skipping package installation."
fi

# Step 7: Check if a GPU is available and install GPU dependencies
if check_gpu; then
    echo "Installing CUDA and cuDNN dependencies..."

    # Add NVIDIA CUDA repository key and repo
    sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
    sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
    sudo apt-get update

    # Install CUDA
    sudo apt-get install -y cuda

    # Add cuDNN repository key and repo
    sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
    sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/ /"
    sudo apt-get update

    # Install cuDNN
    sudo apt-get install -y libcudnn8 libcudnn8-dev

    # Create symbolic links for cuDNN libraries if not present
    if [ ! -f /usr/local/cuda/lib64/libcudnn.so ]; then
        sudo ln -s /usr/lib/x86_64-linux-gnu/libcudnn.so /usr/local/cuda/lib64/libcudnn.so
        sudo ln -s /usr/lib/x86_64-linux-gnu/libcudnn.so.8 /usr/local/cuda/lib64/libcudnn.so.8
        sudo ln -s /usr/lib/x86_64-linux-gnu/libcudnn.so.8.9.7 /usr/local/cuda/lib64/libcudnn.so.8.9.7
    fi

    # Verify CUDA and cuDNN installations
    verify_cuda
    verify_cudnn
else
    echo "Skipping GPU dependencies since no GPU was detected."
fi

# Step 8: Run Nonstationary_Transformer scripts
echo "Running Nonstationary_Transformer scripts..."
bash ./scripts/ILI_script/ns_Transformer.sh
bash ./scripts/Exchange_script/ns_Transformer.sh
bash ./scripts/ETT_script/ns_Transformer.sh

echo "Scripts are executing..."
