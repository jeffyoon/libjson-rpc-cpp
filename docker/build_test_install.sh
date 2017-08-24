set -v
set -e

CLIENT_LIBS="-ljsoncpp -lcurl -ljsonrpccpp-common -ljsonrpccpp-client"
SERVER_LIBS="-ljsoncpp -lmicrohttpd -ljsonrpccpp-common -ljsonrpccpp-server"
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release \
	-DBUILD_STATIC_LIBS=ON -DTCP_SOCKET_SERVER=YES -DTCP_SOCKET_CLIENT=YES \
	-DBUILD_SHARED_LIBS=ON ..
make -j$(nproc)
./bin/unit_testsuite
make install
ldconfig
cd ../src/examples
g++ -std=c++11 simpleclient.cpp $CLIENT_LIBS -o simpleclient
g++ -std=c++11 simpleserver.cpp $SERVER_LIBS -o simpleserver

mkdir gen && cd gen
jsonrpcstub ../spec.json --cpp-server=AbstractStubServer --cpp-client=StubClient
cd ..
g++ -std=c++11 stubclient.cpp $CLIENT_LIBS -o stubclient
g++ -std=c++11 stubserver.cpp $SERVER_LIBS -o stubserver

test -f simpleclient
test -f simpleserver
test -f stubserver
test -f stubclient