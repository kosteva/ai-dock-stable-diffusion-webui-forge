#!/bin/false

build_nvidia_main() {
    build_nvidia_install_deps
    build_common_run_tests
    build_nvidia_run_tests
}

build_nvidia_install_deps() {
    short_cuda_version="cu$(cut -d '.' -f 1,2 <<< "${CUDA_VERSION}" | tr -d '.')"
    "$FORGE_VENV_PIP" install --no-cache-dir \
        nvidia-ml-py3 \
        torch==${PYTORCH_VERSION} \
        torchvision \
        torchaudio \
        cmake \
        ninja \
        --extra-index-url=https://download.pytorch.org/whl/$short_cuda_version
    set FORCE_CUDA=1
    set TORCH_CUDA_ARCH_LIST=12.0+PTX
    "$FORGE_VENV_PIP" install --no-binary --no-cache-dir --force-reinstall git+https://github.com/LagPixelLOL/xformers.git@blackwell
}

build_nvidia_run_tests() {
    installed_pytorch_cuda_version=$("$FORGE_VENV_PYTHON" -c "import torch; print(torch.version.cuda)")
    if [[ "$CUDA_VERSION" != "$installed_pytorch_cuda"* ]]; then
        echo "Expected PyTorch CUDA ${CUDA_VERSION} but found ${installed_pytorch_cuda}\n"
        exit 1
    fi
}

build_nvidia_main "$@"