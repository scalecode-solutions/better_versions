cmake_minimum_required(VERSION 3.10)
project(runner LISTS VERSION 1.0.0)

add_definitions(-DAPP_VERSION="1.0.0" -DAPP_BUILD_NUMBER=1)

add_executable(${BINARY_NAME} WIN32 MACOSX_BUNDLE
  "main.cc"
  "my_application.cc"
)

set_target_properties(${BINARY_NAME} PROPERTIES
  VERSION 1.0.0
  SOVERSION 1
)
