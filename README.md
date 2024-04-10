# docker-np-editorgpu-build

docker build . -t ymiroshnyk/docker-np-editorgpu-build:latest

docker run -it --rm --privileged -v $(pwd)/../dev-all:/opt/dev-all -v $(pwd)/.conan2:/root/.conan2 -v $(pwd)/ccache:/ccache ymiroshnyk/docker-np-editorgpu-build:latest bash
