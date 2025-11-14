default:
    @just -l

conan:
    conan install . --output-folder=build --build=missing --profile=default \
        -c tools.system.package_manager:mode=install -c \
        tools.system.package_manager:sudo=True

conan_debug:
    conan install . --output-folder=build --build=missing --profile=debug \
        -c tools.system.package_manager:mode=install -c \
        tools.system.package_manager:sudo=True
