#!/bin/false

build_nvidia_main() {
    build_nvidia_install_deps
    build_common_run_tests
    build_nvidia_run_tests
}

build_nvidia_install_deps() {
    $APT_INSTALL \
        nvidia-cuda-dev
        
    short_cuda_version="cu$(cut -d '.' -f 1,2 <<< "${CUDA_VERSION}" | tr -d '.')"
    "$FORGE_VENV_PIP" install \
        cmake \
        ninja
    "$FORGE_VENV_PIP" install \
        nvidia-ml-py3 \
        torch==${PYTORCH_VERSION} \
        torchvision \
        torchaudio \
        --extra-index-url=https://download.pytorch.org/whl/$short_cuda_version
    export FORCE_CUDA=1
    export TORCH_CUDA_ARCH_LIST="12.0+PTX"
    # $FORGE_VENV_PIP install --no-binary xformers --no-cache-dir --force-reinstall -v git+https://github.com/LagPixelLOL/xformers.git@blackwell
    "$FORGE_VENV_PIP" install git+https://github.com/LagPixelLOL/xformers.git@blackwell
    # $FORGE_VENV_PIP install -U xformers --index-url https://download.pytorch.org/whl/cu128
}

build_nvidia_run_tests() {
    installed_pytorch_cuda_version=$("$FORGE_VENV_PYTHON" -c "import torch; print(torch.version.cuda)")
    if [[ "$CUDA_VERSION" != "$installed_pytorch_cuda"* ]]; then
        echo "Expected PyTorch CUDA ${CUDA_VERSION} but found ${installed_pytorch_cuda}\n"
        exit 1
    fi
}

build_nvidia_main "$@"