#!/bin/bash

# Define variables
CONDA_INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
CONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
CONDA_PATH="$HOME/miniconda3"
ENV_NAME="myenv_7"
PYTHON_VERSION="3.7"  # Define Python version
PROJECT_DIR="$(pwd)"  # Current project directory
YML_FILE="$PROJECT_DIR/myenv_7.yml"  # .yml file path
REQUIREMENTS_FILE="$PROJECT_DIR/requirements.txt"

# Step 0: Fix Windows line endings if necessary (for .sh file itself)
if command -v dos2unix &> /dev/null; then
    echo "Converting script to Unix line endings..."
    dos2unix "$0"
else
    echo "dos2unix is not installed. Please install it to fix line endings, or ensure the script is in Unix format."
fi

# Step 1: Check if Python is installed
if ! command -v python &> /dev/null; then
    echo "Python not found. Installing Python..."
    sudo apt update
    sudo apt install python3 -y
    sudo apt install python3-pip -y
    echo "Python installation complete."
else
    echo "Python is already installed. Version:"
    python --version
fi

# Step 2: Install Miniconda if not already installed
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

# Step 3: Initialize Conda if not already initialized
if ! grep -q "conda initialize" ~/.bashrc; then
    echo "Initializing Conda..."
    eval "$($CONDA_PATH/bin/conda shell.bash hook)"
    $CONDA_PATH/bin/conda init bash
    source ~/.bashrc
else
    echo "Conda is already initialized in .bashrc."
    eval "$($CONDA_PATH/bin/conda shell.bash hook)"
fi

# Step 4: Verify Conda installation
if ! command -v conda &> /dev/null; then
    echo "Conda command not found. Please check the installation."
    exit 1
else
    echo "Conda installation verified. Version:"
    conda --version
fi

# Step 5: Create or Update Conda Environment with required Python version
if [ -f "$YML_FILE" ]; then
    echo "Environment file found at $YML_FILE. Creating or updating environment from it..."
    conda env create --force -f "$YML_FILE"
else
    echo "No .yml file found. Creating a new environment '$ENV_NAME' with Python $PYTHON_VERSION..."
    conda create --name $ENV_NAME python=$PYTHON_VERSION -y
    conda activate $ENV_NAME

    echo "Exporting the new environment to $YML_FILE..."
    conda env export > "$YML_FILE"
fi

# Step 6: Activate Conda environment
echo "Activating environment '$ENV_NAME'..."
conda activate $ENV_NAME

# Step 7: Install packages from requirements.txt if it exists
if [ -f "$REQUIREMENTS_FILE" ]; then
    echo "Installing packages from $REQUIREMENTS_FILE..."
    pip install -r "$REQUIREMENTS_FILE"
else
    echo "Requirements file not found at $REQUIREMENTS_FILE. Skipping package installation."
fi

echo "Environment setup complete. '$ENV_NAME' environment with Python $PYTHON_VERSION is ready with necessary packages installed."

# Step 8: Run Nonstationary_Transformer scripts
echo "Running Nonstationary_Transformer scripts..."

# Run these scripts and display any errors
bash ./scripts/ILI_script/ns_Transformer.sh
bash ./scripts/Exchange_script/ns_Transformer.sh
bash ./scripts/ETT_script/ns_Transformer.sh

echo "Scripts are executing..."
